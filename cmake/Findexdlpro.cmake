# - Find exdlpro installation
# exdlpro_DIR
################################################################################
# TRICKY: clear cached variables each time we cmake so we can change
# exdlpro_REV and reuse the same build directory
unset(exdlpro_DIR CACHE)
################################################################################
include(xpfunmac)
xpGetCompilerPrefix(COMPILER)
xpGetNumBits(BITS)
# projects using exdlpro: set(exdlpro_REV `git describe --tags`)
set(exdlpro_SIG ${exdlpro_REV}-${COMPILER}-${BITS})
xpGetSysName(XP_SYSTEM_NAME)
set(XP_DEV_BUILD_NAME "exdlpro_${exdlpro_SIG}")
set(XP_INSTALLED_NAME "exdlpro-${exdlpro_SIG}-${XP_SYSTEM_NAME}")
# NOTE: environment variable setting examples:
# set(ENV{exdlpro_BUILD_DIR} /bpvol/src/pros/exdlpro/_bld)
# set(ENV{extern_DIR} ~/extern)
find_path(exdlpro_DIR
  NAMES
    exdlpro_${exdlpro_SIG}.txt
  PATHS
    # developer/build versions
    "$ENV{exdlpro_BUILD_DIR}/${XP_DEV_BUILD_NAME}"
    # installed versions
    "$ENV{extern_DIR}/${XP_INSTALLED_NAME}"
    "~/extern/${XP_INSTALLED_NAME}"
    "/opt/extern/${XP_INSTALLED_NAME}"
    "C:/opt/extern/${XP_INSTALLED_NAME}"
    "C:/dev/extern/${XP_INSTALLED_NAME}"
  DOC "exdlpro directory"
  )
if(exdlpro_DIR)
  if(EXISTS ${exdlpro_DIR}/share/cmake/xpuse-exdlpro-config.cmake)
    include(${exdlpro_DIR}/share/cmake/xpuse-exdlpro-config.cmake)
  endif()
  if(COMMAND xpCheckInstall)
    xpCheckInstall(exdlpro)
  endif()
endif()
