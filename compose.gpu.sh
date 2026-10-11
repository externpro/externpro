#!/usr/bin/env bash
cd "$( dirname "$0" )"
source ./.externpro/funcs.sh
function usage
{
  echo "`basename -- $0` usage:"
  echo " -h      display this help message"
  echo "         run the build container (no switches)"
  echo " -b      build docker image(s)"
  echo " -g      GPU container"
}
BPROIMG=rocky-pin
if [ $# -eq 0 ]; then
  buildreq
  init
  bakebuild --profile pbld
  docker compose run --rm bld
  deinit
  exit 0
fi
while getopts "bgh" opt
do
  case ${opt} in
    b )
      buildreq
      init
      bakebuild --profile pbld --profile pgpu
      deinit
      exit 0
      ;;
    g )
      BPROIMG=rocky-pdv
      gpureq
      buildreq
      init
      bakebuild --profile pgpu
      docker compose run --rm gpu
      deinit
      exit 0
      ;;
    h )
      usage
      exit 0
      ;;
    \? )
      usage
      exit 1
      ;;
  esac
done
