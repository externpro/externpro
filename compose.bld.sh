#!/usr/bin/env bash
cd "$( dirname "$0" )"
source ./.devcontainer/funcs.sh
BPROIMG=rocky-mdv
defOptions "$@"
# docker compose run
