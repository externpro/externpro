#!/usr/bin/env bash
cd "$( dirname "$0" )"
source ./.devcontainer/funcs.sh
BPROIMG=rocky85-ci
defOptions "$@"
# docker compose run
