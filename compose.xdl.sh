#!/usr/bin/env bash
cd "$( dirname "$0" )"
source ./.devcontainer/funcs.sh
BPROIMG=rocky-pro
defOptions "$@"
# docker compose run
