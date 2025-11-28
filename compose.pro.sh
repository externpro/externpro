#!/usr/bin/env bash
cd "$( dirname "$0" )"
source ./.devcontainer/funcs.sh
BPROIMG=rocky8-gcc9
defOptions "$@"
# docker compose run
