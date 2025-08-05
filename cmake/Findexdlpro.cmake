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
# TRICKY: match what is done in cmake's Modules/CPack.cmake, setting CPACK_SYSTEM_NAME
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(XP_SYSTEM_NAME win${BITS})
else()
  set(XP_SYSTEM_NAME ${CMAKE_SYSTEM_NAME})
endif()
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
if(NOT exdlpro_DIR)
  if(EXISTS $ENV{extern_DIR})
    set(archive_name "${XP_INSTALLED_NAME}.tar.xz")
    message(STATUS "${XP_INSTALLED_NAME} not found.")
    message(STATUS "Attempting download of ${archive_name} ...")
    file(DOWNLOAD https://github.com/externpro/exdlpro/releases/download/${exdlpro_REV}/${archive_name}
      $ENV{extern_DIR}/${archive_name}
      )
    message(STATUS "Attempting extraction of ${archive_name} ...")
    file(ARCHIVE_EXTRACT
      INPUT $ENV{extern_DIR}/${archive_name}
      DESTINATION $ENV{extern_DIR}
      )
    message(STATUS "Attempting to remove ${archive_name}")
    file(REMOVE $ENV{extern_DIR}/${archive_name})
    if(EXISTS $ENV{extern_DIR}/${XP_INSTALLED_NAME})
      set(exdlpro_DIR $ENV{extern_DIR}/${XP_INSTALLED_NAME})
    else()
      message(AUTHOR_WARNING "Automatic download and extraction failed. Verify https://github.com/externpro/exdlpro/releases/download/${exdlpro_REV}/${archive_name} exists and can be accessed.")
    endif()
  endif()
endif()
if(NOT exdlpro_DIR)
  set(exdlpro_INSTALL_INFO ".\n Installers located at https://github.com/externpro/exdlpro/releases\n tar -xf /path/to/exdlpro*.tar.xz --directory=/path/to/install/\n ** or set extern_DIR in ENV for automatic download and extraction\n") # exdlpro can set(XP_INSTALL_INFO) to define this
  if(DEFINED exdlpro_INSTALLER_LOCATION) # defined by project using exdlpro
    message(FATAL_ERROR "exdlpro ${exdlpro_SIG} not found.\n${exdlpro_INSTALLER_LOCATION}")
  else()
    message(FATAL_ERROR "exdlpro ${exdlpro_SIG} not found${exdlpro_INSTALL_INFO}")
  endif()
else()
  message(STATUS "Found exdlpro: ${exdlpro_DIR}")
  set(moduleDir ${exdlpro_DIR}/share/cmake)
  list(APPEND XP_MODULE_PATH ${moduleDir})
  set(FPHSA_NAME_MISMATCHED TRUE) # find_package_handle_standard_args NAME_MISMATCHED (prefix usexp-)
  if(EXISTS ${moduleDir}/xpfunmac.cmake)
    include(${moduleDir}/xpfunmac.cmake)
  endif()
  if(COMMAND xpCheckInstall)
    xpCheckInstall(exdlpro)
  endif()
endif()
