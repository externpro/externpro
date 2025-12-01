#!/usr/bin/env bash
cd "$( dirname "$0" )"
source ./.devcontainer/funcs.sh
BPROIMG=${BPROIMG:-${BPROIMG_DEFAULT}}
defOptions "$@"
