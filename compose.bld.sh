#!/usr/bin/env bash
cd "$( dirname "$0" )"
source ./.devcontainer/funcs.sh
function usage
{
  echo "`basename -- $0` usage:"
  echo " -h      display this help message"
  echo "         run the build container (no switches)"
  echo " -b      build docker image(s)"
}
if [ $# -eq 0 ]; then
  buildreq
  init
  docker compose --profile pbld build
  docker compose run --rm bld
  exit 0
fi
while getopts "bh" opt
do
  case ${opt} in
    b )
      buildreq
      init
      docker compose --profile pbld build
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
