{ lib
, stdenv
, fetchurl
, fetchzip
, fetchsvn
, fetchgit
, fetchfossil
, fetchcvs
, fetchhg
, fetchFromGitea
, fetchFromGitHub
, fetchFromGitLab
, fetchFromGitiles
, fetchFromBitbucket
, fetchFromSavannah
, fetchFromRepoOrCz
, fetchFromSourcehut
}:

srcData:

let
  info = lib.importJSON srcData;

  projectSrc =
    if info.fetcher == "fetchurl" then fetchurl info.args
    else if info.fetcher == "fetchzip" then fetchzip info.args
    else if info.fetcher == "fetchsvn" then fetchsvn info.args
    else if info.fetcher == "fetchgit" then fetchgit info.args
    else if info.fetcher == "fetchfossil" then fetchfossil info.args
    else if info.fetcher == "fetchcvs" then fetchcvs info.args
    else if info.fetcher == "fetchhg" then fetchhg info.args
    else if info.fetcher == "fetchFromGitea" then fetchFromGitea info.args
    else if info.fetcher == "fetchFromGitHub" then fetchFromGitHub info.args
    else if info.fetcher == "fetchFromGitLab" then fetchFromGitLab info.args
    else if info.fetcher == "fetchFromGitiles" then fetchFromGitiles info.args
    else if info.fetcher == "fetchFromBitbucket" then fetchFromBitbucket info.args
    else if info.fetcher == "fetchFromSavannah" then fetchFromSavannah info.args
    else if info.fetcher == "fetchFromRepoOrCz" then fetchFromRepoOrCz info.args
    else if info.fetcher == "fetchFromSourcehut" then fetchFromSourcehut info.args
    else abort "Invalid fetcher: ${info.fetcher}";
in
{
  inherit (info) version;
  src = projectSrc;
}
