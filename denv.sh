#!/usr/bin/env bash
cd "$( dirname "$0" )"
pushd .. > /dev/null
source ./.devcontainer/funcs.sh
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
dkr="$(findVer 'FROM' .devcontainer/rocky85-bld.dockerfile .devcontainer/rocky85-pro.dockerfile)"
dkr=$(eval echo ${dkr}) # ghcr.io/externpro/buildpro/rocky85-[bld|pro]:TAG, where TAG=${BPROTAG}
hst=$(echo "${dkr}" | cut -d/ -f1) # ghcr.io
rel=$(echo "${dkr}" | cut -d- -f2) # bld:TAG
rel=${rel//:} # parameter expansion substitution
rel=bp${rel//./-}
display_host=$(echo ${DISPLAY} | cut -d: -f1)
if [[ -z "${display_host}" ]]; then
  display_env=${DISPLAY}
  xauth_env=
elif [[ "${display_host}" == "localhost" ]]; then
  echo "NOTE: X11UseLocalhost should be no in /etc/ssh/sshd_config or /etc/centrifydc/ssh/sshd_config"
else
  display_screen=$(echo $DISPLAY | cut -d: -f2)
  display_num=$(echo ${display_screen} | cut -d. -f1)
  magic_cookie=$(xauth list ${DISPLAY} | awk '{print $3}')
  xauth_file=/tmp/.X11-unix/docker.xauth
  docker_host=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')
  touch ${xauth_file}
  xauth -f ${xauth_file} add ${docker_host}:${display_num} . ${magic_cookie}
  display_env=${docker_host}:${display_screen}
  xauth_env=${xauth_file}
fi
env="BPROTAG=${BPROTAG}"
env="${env}\nHNAME=${rel}"
env="${env}\nUSERID=$(id -u ${USER})"
env="${env}\nGROUPID=$(id -g ${USER})"
if [[ -f /etc/timezone ]]; then
  env="${env}\nTZ=$(head -n 1 /etc/timezone)"
elif command -v timedatectl >/dev/null; then
  env="${env}\nTZ=$(timedatectl status | grep "zone" | sed -e 's/^[ ]*Time zone: \(.*\) (.*)$/\1/g')"
fi
env="${env}\nDISPLAY_ENV=${display_env}"
env="${env}\nXAUTH_ENV=${xauth_env}"
##############################
# NOTE: EXTERN_DIR and GCC_VER need to match buildpro's public/rocky85-pro.dockerfile
EXTERN_DIR=/opt/extern
GCC_VER=gcc921
urlPfx="https://isrhub.usurf.usu.edu"
##############################
wproVer="$(findVer 'set(webpro_REV' CMakeLists.txt */CMakeLists.txt */toplevel.cmake */*/toplevel.cmake .devcontainer/cmake/xptoplevel.cmake)"
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
  TOOLS="mkdir ${EXTERN_DIR}/CRTool \
&& ${CRTOOL_DL} \
&& ./CRTool-${crWrapVer}.sh --prefix=${EXTERN_DIR}/CRTool --exclude-subdir \
&& ./CRToolImpl-${crToolVer}.sh --prefix=${EXTERN_DIR} --include-subdir \
&& rm CRTool-${crWrapVer}.sh \
&& rm CRToolImpl-${crToolVer}.sh"
  TOOLS_PATH=:${EXTERN_DIR}/CRTool
fi
##############################
pemuVer="$(findVer 'set(PluginEmulatorRelease' PluginLibraries/CMakeLists.txt)"
ictVer="$(findVer 'set(ImageChangeToolRelease' PluginLibraries/CMakeLists.txt)"
if [[ -n "${pemuVer}" ]]; then
  pemuBase=SDLPluginSDK-v${pemuVer}-gcc931-64-$(uname -s)
  PEMU_DL="wget ${urlPfx}/PluginFramework/SDKSuper/releases/download/v${pemuVer}/${pemuBase}.tar.xz"
  TOOLS=${TOOLS:+${TOOLS} && }
  TOOLS=${TOOLS}"${PEMU_DL} -qO- | tar --no-same-owner -xJ -C ${EXTERN_DIR}"
  TOOLS_PATH=${TOOLS_PATH}:${EXTERN_DIR}/${pemuBase}/bin
fi
if [[ -n "${ictVer}" ]]; then
  ictBase=ImageChangeTool-${ictVer}-$(uname -s)
  ICT_DL="wget ${urlPfx}/VantagePlugins/ImageChangeTool/releases/download/v${ictVer}/${ictBase}-tool.tar.xz"
  TOOLS=${TOOLS:+${TOOLS} && }
  TOOLS=${TOOLS}"mkdir ${EXTERN_DIR}/${ictBase} && ${ICT_DL} -qO- | tar --no-same-owner -xJ -C ${EXTERN_DIR}/${ictBase}"
  TOOLS_PATH=${TOOLS_PATH}:${EXTERN_DIR}/${ictBase}
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
