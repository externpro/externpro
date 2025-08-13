#!/usr/bin/env bash
cd "$( dirname "$0" )"
pushd .. > /dev/null
source ./.devcontainer/funcs.sh
BPROIMG=${1:-rocky-pro}
if [[ $(basename -s .git `git config --get remote.origin.url`) == buildpro ]]; then
  BPROTAG=`git describe --tags`
  if [ -n "$(git status --porcelain --untracked=no)" ] || [[ ${BPROTAG} == *"-g"* ]]; then
    BPROTAG=latest
  fi
else
  BPROTAG="$(findVer 'set(buildpro_REV' CMakeLists.txt */toplevel.cmake */*/toplevel.cmake .devcontainer/cmake/xptoplevel.cmake)"
  if [ -z ${BPROTAG} ]; then
    echo "*** buildpro_REV should be set"
    BPROTAG=latest
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
  if [ FALSE && -z "${magic_cookie}" ]; then
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
# NOTE: EXTERN_DIR and GCC_VER need to match buildpro's public/rocky-pro.dockerfile
EXTERN_DIR=/opt/extern
GCC_VER=gcc921
urlPfx="https://isrhub.usurf.usu.edu"
##############################
wproVer="$(findVer 'set(webpro_REV' CMakeLists.txt */CMakeLists.txt */toplevel.cmake */*/toplevel.cmake)"
[[ "${wproVer}" == "NONE" ]] && wproVer=""
if [[ -n "${wproVer}" ]]; then
  wproBase=webpro-${wproVer}-${GCC_VER}-64-$(uname -s)
  if [[ ${wproVer} < "20.05.1" ]]; then
    WEBPRO_DL="wget -q \"${urlPfx}/webpro/webpro/releases/download/${wproVer}/${wproBase}.sh\" \
&& chmod 755 webpro*.sh "
    WEBPRO="${WEBPRO_DL} \
&& ./${wproBase}.sh --prefix=${EXTERN_DIR} --include-subdir \
&& rm ${wproBase}.sh"
  else
    WEBPRO_DL="wget ${urlPfx}/webpro/webpro/releases/download/${wproVer}/${wproBase}.tar.xz"
    WEBPRO="${WEBPRO_DL} -qO- | tar --no-same-owner -xJ -C ${EXTERN_DIR}"
  fi
fi
env="${env}\nWEBPRO=${WEBPRO}"
##############################
if [ -f .crtoolrc ]; then
  crtv=`grep version .crtoolrc`
fi
crToolVer=`echo ${crtv} | awk '{$1=$1};1' | cut -d " " -f2 | cut -d "\"" -f2`
crWrapVer=20.07.1
if [[ ${crToolVer} > "24.01" || ${crToolVer} == "24.01" ]]; then
  crToolVer=v${crToolVer}
fi
if [[ -n "${crToolVer}" && -n "${crWrapVer}" ]]; then
  CRTOOL_DL="wget -q \"${urlPfx}/CRTool/CRTool/releases/download/${crWrapVer}/CRTool-${crWrapVer}.sh\" \
&& wget -q \"${urlPfx}/CRTool/CRToolImpl/releases/download/${crToolVer}/CRToolImpl-${crToolVer}.sh\" \
&& chmod 755 CRTool*.sh"
  TOOLS="mkdir -p ${EXTERN_DIR}/CRTool \
&& ${CRTOOL_DL} \
&& ./CRTool-${crWrapVer}.sh --prefix=${EXTERN_DIR}/CRTool --exclude-subdir \
&& ./CRToolImpl-${crToolVer}.sh --prefix=${EXTERN_DIR} --include-subdir \
&& rm CRTool-${crWrapVer}.sh \
&& rm CRToolImpl-${crToolVer}.sh"
  TOOLS_PATH=:${EXTERN_DIR}/CRTool
fi
##############################
bmvVer="$(findVer 'set(BrokerMessageValidatorToolRelease' PluginLibraries/CMakeLists.txt)"
ictVer="$(findVer 'set(ImageChangeToolRelease' PluginLibraries/CMakeLists.txt)"
iqtVer="$(findVer 'set(ImageQualityToolRelease' PluginLibraries/CMakeLists.txt)"
pmuVer="$(findVer 'set(PluginEmulatorRelease' PluginLibraries/CMakeLists.txt)"
spvVer="$(findVer 'set(SARPyValidatorRelease' PluginLibraries/CMakeLists.txt)"
if [[ -n "${bmvVer}" ]]; then
  bmvBase=BrokerMessageValidatorTool-${bmvVer}-$(uname -s)
  bmvDl="wget ${urlPfx}/VantagePlugins/BrokerMessageValidatorTool/releases/download/v${bmvVer}/${bmvBase}-tool.tar.xz"
  TOOLS=${TOOLS:+${TOOLS} && }
  TOOLS=${TOOLS}"mkdir -p ${EXTERN_DIR}/${bmvBase} && ${bmvDl} -qO- | tar --no-same-owner -xJ -C ${EXTERN_DIR}/${bmvBase}"
  TOOLS_PATH=${TOOLS_PATH}:${EXTERN_DIR}/${bmvBase}
fi
if [[ -n "${ictVer}" ]]; then
  ictBase=ImageChangeTool-${ictVer}-$(uname -s)
  ictDl="wget ${urlPfx}/VantagePlugins/ImageChangeTool/releases/download/v${ictVer}/${ictBase}-tool.tar.xz"
  TOOLS=${TOOLS:+${TOOLS} && }
  TOOLS=${TOOLS}"mkdir -p ${EXTERN_DIR}/${ictBase} && ${ictDl} -qO- | tar --no-same-owner -xJ -C ${EXTERN_DIR}/${ictBase}"
  TOOLS_PATH=${TOOLS_PATH}:${EXTERN_DIR}/${ictBase}
fi
if [[ -n "${iqtVer}" ]]; then
  iqtBase=ImageQualityTool-${iqtVer}-$(uname -s)
  iqtDl="wget ${urlPfx}/VantagePlugins/ImageQualityTool/releases/download/v${iqtVer}/${iqtBase}-tool.tar.xz"
  TOOLS=${TOOLS:+${TOOLS} && }
  TOOLS=${TOOLS}"mkdir -p ${EXTERN_DIR}/${iqtBase} && ${iqtDl} -qO- | tar --no-same-owner -xJ -C ${EXTERN_DIR}/${iqtBase}"
  TOOLS_PATH=${TOOLS_PATH}:${EXTERN_DIR}/${iqtBase}
fi
if [[ -n "${pmuVer}" ]]; then
  pmuBase=SDLPluginSDK-v${pmuVer}-gcc931-64-$(uname -s)
  pmuDl="wget ${urlPfx}/PluginFramework/SDKSuper/releases/download/v${pmuVer}/${pmuBase}.tar.xz"
  TOOLS=${TOOLS:+${TOOLS} && }
  TOOLS=${TOOLS}"${pmuDl} -qO- | tar --no-same-owner -xJ -C ${EXTERN_DIR}"
  TOOLS_PATH=${TOOLS_PATH}:${EXTERN_DIR}/${pmuBase}/bin
fi
if [[ -n "${spvVer}" ]]; then
  spvBase=SARPyValidator-${spvVer}.0-$(uname -s)
  spvDl="wget ${urlPfx}/VantagePlugins/SARPyValidator/releases/download/v${spvVer}/${spvBase}-tool.tar.xz"
  TOOLS=${TOOLS:+${TOOLS} && }
  TOOLS=${TOOLS}"mkdir -p ${EXTERN_DIR}/${spvBase} && ${spvDl} -qO- | tar --no-same-owner -xJ -C ${EXTERN_DIR}/${spvBase}"
  TOOLS_PATH=${TOOLS_PATH}:${EXTERN_DIR}/${spvBase}
fi
##############################
env="${env}\nTOOLS=${TOOLS}\nTOOLS_PATH=${TOOLS_PATH}"
##############################
CERT_DIR=/etc/pki/ca-trust/source/anchors
TEMP_DIR=/usr/local/games # TRICKY: match use in dockergen/bit.user.dockerfile
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
