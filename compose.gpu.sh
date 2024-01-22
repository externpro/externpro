#!/usr/bin/env bash
cd "$( dirname "$0" )"
source ./.devcontainer/funcs.sh
function usage
{
  echo "`basename -- $0` usage:"
  echo " -h      display this help message"
  echo "         run the build container (no switches)"
  echo " -b      build docker image(s)"
  echo " -c      create offline container bundle"
  echo " -g      GPU container"
}
if [ $# -eq 0 ]; then
  buildreq
  init
  docker compose --profile pbld build
  docker compose run --rm bld
  exit 0
fi
while getopts "bcgh" opt
do
  case ${opt} in
    b )
      buildreq
      init
      docker compose --profile pbld --profile pgpu build
      exit 0
      ;;
    c )
      offlinereq
      createContainerBundle
      exit 0
      ;;
    g )
      gpureq
      buildreq
      init
      docker compose --profile pgpu build
      docker compose run --rm gpu
      exit 0
      ;;
    h )
      usage
      exit 0
      ;;
    \? )
      usage
      exit 0
      ;;
  esac
done
