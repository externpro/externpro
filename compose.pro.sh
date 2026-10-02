#!/usr/bin/env bash
cd "$( dirname "$0" )"
source ./.externpro/funcs.sh
BPROIMG=${BPROIMG:-${BPROIMG_DEFAULT}}
defOptions "$@"
