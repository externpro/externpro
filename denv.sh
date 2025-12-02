#!/usr/bin/env bash
cd "$( dirname "$0" )"
pushd .. > /dev/null
source ./.devcontainer/funcs.sh
BPROIMG=${1:-${BPROIMG_DEFAULT}}
if [[ $(basename -s .git `git config --get remote.origin.url`) == buildpro ]]; then
  BPROTAG=`git describe --tags`
  if [ -n "$(git status --porcelain --untracked=no)" ] || [[ ${BPROTAG} == *"-g"* ]]; then
    BPROTAG=latest
  fi
else
  BPROTAG="$(findVer 'set(buildpro_REV' CMakeLists.txt */toplevel.cmake */*/toplevel.cmake)"
  if [ -z ${BPROTAG} ]; then
    # echo "*** buildpro_REV not set, defaulting to BPROTAG_DEFAULT=${BPROTAG_DEFAULT}"
    BPROTAG=${BPROTAG_DEFAULT}
  fi
fi
dkr="$(findVer 'FROM' .devcontainer/local.dockerfile)"
dkr=$(eval echo ${dkr}) # ghcr.io/externpro/buildpro/${BPROIMG}:${BPROTAG}
hst=$(echo "${dkr}" | cut -d/ -f1) # ghcr.io
rel=$(echo "${dkr}" | cut -d/ -f4) # ${BPROIMG}:${BPROTAG}
rel=${rel//:/-} # parameter expansion substitution
rel=${rel//./-}
display_host=$(echo ${DISPLAY} | cut -d: -f1)
if [[ -z "${display_host}" ]]; then
  display_env=${DISPLAY}
  xauth_env=
elif [[ "${display_host}" == "localhost" ]]; then
  echo "NOTE: X11UseLocalhost should be no in /etc/ssh/sshd_config or /etc/centrifydc/ssh/sshd_config"
else
  # determine DISPLAY environment variable
  display_screen=$(echo $DISPLAY | cut -d: -f2)
  display_num=$(echo ${display_screen} | cut -d. -f1)
  if ! ip a show docker0 >/dev/null 2>&1 || ! docker_host=$(ip -4 addr show docker0 2>/dev/null | grep -o 'inet [0-9.]*' | cut -d' ' -f2); then
    docker_host=host.docker.internal
  fi
  display_env=${docker_host}:${display_screen}
  # determine XAUTHORITY environment variable
  magic_cookie=$(xauth list ${DISPLAY} 2>/dev/null | awk '{print $3}')
  if false && [ -z "${magic_cookie}" ]; then
    alt_display=$(xauth list 2>/dev/null | grep -m 1 '\.local:0\s' | awk '{print $1}')
    if [ -n "${alt_display}" ]; then
      magic_cookie=$(xauth list "${alt_display}" 2>/dev/null | awk '{print $3}')
    fi
  fi
  if [ -n "${magic_cookie}" ]; then
    xauth_file=/tmp/.X11-unix/docker.xauth
    touch ${xauth_file}
    chmod 600 ${xauth_file}
    # Ensure display_num is a valid number, default to 0 if not
    if ! [[ "${display_num}" =~ ^[0-9]+$ ]]; then
      display_num=0
    fi
    # Try different display formats if the first attempt fails
    for display_format in "${docker_host}:${display_num}" "${docker_host}/unix:${display_num}" ":${display_num}"; do
      if xauth -f "${xauth_file}" add "${display_format}" . "${magic_cookie}" 2>/dev/null; then
        break # Successfully added xauth entry
      fi
    done || echo "Warning: Failed to add xauth entry for ${docker_host}:${display_num}" >&2
    xauth_env=${xauth_file}
  else
    xauth_env=
  fi
fi
env="BPROIMG=${BPROIMG}"
env="${env}\nBPROTAG=${BPROTAG}"
env="${env}\nHNAME=${rel}"
env="${env}\nUSERID=$(id -u ${USER})"
env="${env}\nGROUPID=$(id -g ${USER})"
if [[ -f /etc/timezone ]]; then
  env="${env}\nTZ=$(head -n 1 /etc/timezone)"
elif command -v timedatectl >/dev/null; then
  env="${env}\nTZ=$(timedatectl status | grep "zone" | sed -e 's/^[ ]*Time zone: \(.*\) (.*)$/\1/g')"
elif [[ -f /etc/localtime ]]; then
  env="${env}\nTZ=$(readlink /etc/localtime | sed 's#/var/db/timezone/zoneinfo/##g')"
fi
env="${env}\nDISPLAY_ENV=${display_env}"
env="${env}\nXAUTH_ENV=${xauth_env}"
##############################
# populate env variables TOOLS, TOOLS_PATH
source ./.devcontainer/tools.sh
##############################
CERT_DIR=/etc/pki/ca-trust/source/anchors
TEMP_DIR=/usr/local/games # TRICKY: match use in local.dockerfile
XFER_DIR=_bldtmp # TRICKY: match use in funcs.sh deinit
SECURE=isrhub.sdl.secure
if command -v host >/dev/null && host ${SECURE} | grep "has address" >/dev/null; then
  isSecure=true
fi
if [[ -d ${CERT_DIR} && ${isSecure} ]]; then
  mkdir -p .devcontainer/${XFER_DIR} && cp ${CERT_DIR}/* .devcontainer/${XFER_DIR}
  COPY_IT="${XFER_DIR}/*"
  RUN_IT="mkdir -p ${CERT_DIR} && cp ${TEMP_DIR}/* ${CERT_DIR} && rm ${TEMP_DIR}/* && update-ca-trust"
else
  COPY_IT="LICENSE*"
  RUN_IT="rm ${TEMP_DIR}/LICENSE"
fi
env="${env}\nCOPY_IT=${COPY_IT}\nRUN_IT=${RUN_IT}"
##############################
echo -e "${env}" > .env
popd > /dev/null
