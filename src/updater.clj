(require '[cheshire.core :as json])
(require '[babashka.process :refer [shell]])
(require '[babashka.http-client :as http])
(require '[clojure.string :as string])


(defn get-data
  [src-file]
  (json/parse-string (slurp src-file) true))


(defn parse-version
  [version]
  (if (string/starts-with? version "v")
    (subs version 1)
    version))


(defmulti get-new-version
  "Returns the latest version. If there is no new version return nil"
  :fetcher)

(defmethod get-new-version "fetchFromGitHub"
  [{:keys [args]}]
  (let [{:keys [owner repo]} args
        new-version (-> (format "https://api.github.com/repos/%s/%s/releases/latest" owner repo)
                        http/get
                        :body
                        (json/parse-string true)
                        :tag_name)]
    (when (not= (:rev args) new-version)
      new-version)))


(defmulti nurl (fn [src-data _]
                 (:fetcher src-data)))

(defmethod nurl "fetchFromGitHub"
  [{:keys [args]} version]
  (let [{:keys [owner repo]} args
        repo-url (format "https://github.com/%s/%s" owner repo)
        cmd (cond-> ["nurl" repo-url version "--json"]
              (:fetchSubmodules args) (conj "-S"))]
    (-> (apply shell {:out :string} cmd)
        :out
        (json/parse-string true))))


(defn- map-comparator
  [a b]
  (let [m {:version 1
           :fetcher 2
           :args 3

           :owner 10
           :repo 11
           :rev 12
           :hash 13}]
    (compare (get m a 1000)
             (get m b 1000))))

(defn update-src
  [src-file]
  (let [src-data (get-data src-file)
        new-version (get-new-version src-data)]
    (if-not new-version
      (println "Already at latest version")
      (-> (nurl src-data new-version)
          (assoc :version (parse-version new-version))
          (as-> $
            ; Sort root
            (into (sorted-map-by map-comparator) $)
            ; Sort inner :args map
            (assoc $ :args (into (sorted-map-by map-comparator) (:args $))))
          (json/generate-string {:pretty true})
          (->> (spit src-file))))))

(defn -main
  [args]
  (update-src (first args)))

(comment
  (update-src "resources/src.json"))
