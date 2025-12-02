EXTERN_DIR=/opt/extern
urlPfx="https://isrhub.usurf.usu.edu"
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