{ lib, babashka, nurl, writeShellScript }:

let
  bb-script = ../src/updater.clj;
  runtimeInputs = [ babashka nurl ];
in

writeShellScript
  "nix-updater"
  ''
    export PATH="${lib.makeBinPath runtimeInputs}"
    bb --init ${bb-script} -e '(-main *command-line-args*)' "$@"
  ''
