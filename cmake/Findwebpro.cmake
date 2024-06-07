# - Find webpro installation
# webpro_DIR
################################################################################
# TRICKY: clear cached variables each time we cmake so we can change
# webpro_REV and reuse the same build directory
unset(webpro_DIR CACHE)
################################################################################
include(xpfunmac)
xpGetCompilerPrefix(COMPILER)
xpGetNumBits(BITS)
# projects using webpro: set(webpro_REV `git describe --tags`)
set(webpro_SIG ${webpro_REV}-${COMPILER}-${BITS})
# TRICKY: match what is done in cmake's Modules/CPack.cmake, setting CPACK_SYSTEM_NAME
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(XP_SYSTEM_NAME win${BITS})
else()
  set(XP_SYSTEM_NAME ${CMAKE_SYSTEM_NAME})
endif()
set(XP_DEV_BUILD_NAME "webpro_${webpro_SIG}")
set(XP_INSTALLED_NAME "webpro-${webpro_SIG}-${XP_SYSTEM_NAME}")
# NOTE: environment variable setting examples:
# set(ENV{webpro_BUILD_DIR} /bpvol/src/pros/webpro/_bld)
# set(ENV{extern_DIR} ~/extern)
find_path(webpro_DIR
  NAMES
    webpro_${webpro_SIG}.txt
  PATHS
    # developer/build versions
    "$ENV{webpro_BUILD_DIR}/${XP_DEV_BUILD_NAME}"
    # installed versions
    "$ENV{extern_DIR}/${XP_INSTALLED_NAME}"
    "~/extern/${XP_INSTALLED_NAME}"
    "/opt/extern/${XP_INSTALLED_NAME}"
    "C:/opt/extern/${XP_INSTALLED_NAME}"
    "C:/dev/extern/${XP_INSTALLED_NAME}"
  DOC "webpro directory"
  )
if(NOT webpro_DIR)
  if(EXISTS $ENV{extern_DIR})
    set(archive_name "${XP_INSTALLED_NAME}.tar.xz")
    message(STATUS "${XP_INSTALLED_NAME} not found.")
    message(STATUS "Attempting download of ${archive_name} ...")
    file(DOWNLOAD https://isrhub.usurf.usu.edu/webpro/webpro/releases/download/${webpro_REV}/${archive_name}
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
      set(webpro_DIR $ENV{extern_DIR}/${XP_INSTALLED_NAME})
    else()
      message(AUTHOR_WARNING "Automatic download and extraction failed. Verify https://isrhub.usurf.usu.edu/webpro/webpro/releases/download/${webpro_REV}/${archive_name} exists and can be accessed.")
    endif()
  endif()
endif()
if(NOT webpro_DIR)
  set(webpro_INSTALL_INFO ".\n Installers located at https://isrhub.usurf.usu.edu/webpro/webpro/releases\n tar -xf /path/to/webpro*.tar.xz --directory=/path/to/install/\n ** or set extern_DIR in ENV for automatic download and extraction\n") # webpro can set(XP_INSTALL_INFO) to define this
  if(DEFINED webpro_INSTALLER_LOCATION) # defined by project using webpro
    message(FATAL_ERROR "webpro ${webpro_SIG} not found.\n${webpro_INSTALLER_LOCATION}")
  else()
    message(FATAL_ERROR "webpro ${webpro_SIG} not found${webpro_INSTALL_INFO}")
  endif()
else()
  message(STATUS "Found webpro: ${webpro_DIR}")
  set(moduleDir ${webpro_DIR}/share/cmake)
  list(APPEND XP_MODULE_PATH ${moduleDir})
  set(FPHSA_NAME_MISMATCHED TRUE) # find_package_handle_standard_args NAME_MISMATCHED (prefix usexp-)
  if(EXISTS ${moduleDir}/wpfuncmac.cmake)
    include(${moduleDir}/wpfuncmac.cmake)
  endif()
  if(COMMAND xpCheckInstall)
    xpCheckInstall(webpro)
  endif()
endif()
