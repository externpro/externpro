# @param[in] CPACK_COMPONENTS_ALL - list of components (example: server tool)
# @param[in] CPACK_WIX_UPGRADE_GUID - unique product GUID (example: F06A4693-34EF-4695-B6B2-9E89A070CF2F)
#
# @param[in,optional] CPACK_PACKAGE_NAME - package name (default: CMAKE_PROJECT_NAME)
# @param[in,optional] PACKAGE_VENDOR - sets CPACK_PACKAGE_VENDOR
# @param[in,optional] XP_INSTALLDIR - modify the default install directory
# @param[in,optional] XP_RPM_OWNER - RPM daemon user (default: daemon)
# @param[in,optional] XP_RPM_UMASK - RPM daemon umask (default: 0002)
# @param[in,optional] XP_RPM_UNIT_FILE - RPM daemon unit file (default: all-lowercase ${CPACK_PACKAGE_NAME}.service)
# @param[in,optional] XP_RPM_UNIT_ADDITIONS - Additions to the [Unit] section of the service file (default: none)
# @param[in,optional] XP_RPM_STOP_EXECUTABLE - RPM daemon unit file stop command, aka ExecStop (default: none)
# @param[in,optional] XP_SERVER_EXECUTABLE - windows service, unix daemon (default: ${CPACK_PACKAGE_NAME})
# @param[in,optional] XP_WIX_SHORTCUTS - list of pairs [executable "label"] for Desktop, Start Menu shortcuts
# @param[in,optional] XP_WIX_SERVER_RUNAPP - application to launch when installer exits
#
# [optional] CPACK_PACKAGE_CONTACT
# [optional] CPACK_PACKAGE_HOMEPAGE_URL
# [optional] CPACK_RESOURCE_FILE_LICENSE - license embedded in the installer
# [optional] CPACK_RPM_PACKAGE_LICENSE
# [optional] CPACK_WIX_PRODUCT_ICON - Control Panel "Programs and Features" icon
# [optional] CPACK_WIX_UI_BANNER - bitmap at top of installer pages
# [optional] CPACK_WIX_UI_DIALOG - background bitmap on welcome & completion dialogs
#
# NOTE: xpGenerateRevision() should be called before including this file, so ${CMAKE_BINARY_DIR}/revision.txt exists
if(NOT DEFINED CPACK_PACKAGE_NAME)
  set(CPACK_PACKAGE_NAME ${CMAKE_PROJECT_NAME})
endif()
if(NOT DEFINED XP_SERVER_EXECUTABLE)
  set(XP_SERVER_EXECUTABLE ${CPACK_PACKAGE_NAME})
endif()
if(DEFINED PACKAGE_VENDOR)
  set(CPACK_PACKAGE_VENDOR ${PACKAGE_VENDOR})
endif()
set(CPACK_PACKAGE_DESCRIPTION "${CPACK_PACKAGE_NAME} package")
if(EXISTS ${CMAKE_BINARY_DIR}/revision.txt) # created by xpGenerateRevision()
  file(READ ${CMAKE_BINARY_DIR}/revision.txt revNum)
  string(STRIP ${revNum} revNum)
  set(revString " Revision ${revNum}")
endif()
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${CPACK_PACKAGE_NAME}${revString}")
set(CPACK_PACKAGE_VERSION ${CMAKE_PROJECT_VERSION})
set(CPACK_PACKAGE_VERSION_MAJOR ${CMAKE_PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${CMAKE_PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${CMAKE_PROJECT_VERSION_PATCH})
set(CPACK_PACKAGE_VERSION_TWEAK ${CMAKE_PROJECT_VERSION_TWEAK})
# use all available CPU cores when performing parallelized operations, such as compressing the installer package
set(CPACK_THREADS 0)
###############################
# Component Install with CPack
# https://gitlab.kitware.com/cmake/community/-/wikis/doc/cpack/Component-Install-With-CPack
foreach(cmp client plugin server test tool)
  string(TOUPPER ${cmp} CMP)
  set(CPACK_COMPONENT_${CMP}_DISPLAY_NAME "${CPACK_PACKAGE_NAME} ${cmp}")
  set(CPACK_COMPONENT_${CMP}_DESCRIPTION "${CPACK_COMPONENT_${CMP}_DISPLAY_NAME}")
endforeach()
set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
if(WIN32)
  set(CPACK_GENERATOR ZIP)
  if(DEFINED CPACK_COMPONENTS_ALL)
    if(("client" IN_LIST CPACK_COMPONENTS_ALL) OR ("server" IN_LIST CPACK_COMPONENTS_ALL))
      list(APPEND CPACK_GENERATOR WIX)
    endif()
  endif()
  if("WIX" IN_LIST CPACK_GENERATOR)
    if(DEFINED XP_WIX_SHORTCUTS)
      set(CPACK_CREATE_DESKTOP_LINKS ${XP_WIX_SHORTCUTS}) # Desktop shortcuts
      set(CPACK_PACKAGE_EXECUTABLES ${XP_WIX_SHORTCUTS}) # Start Menu shortcuts
    endif()
    if(DEFINED XP_INSTALLDIR)
      set(CPACK_PACKAGE_INSTALL_DIRECTORY "${XP_INSTALLDIR}")
    endif()
    include(xpmswwix)
    # NOTE: main.wxs.in is a slightly modified copy of CMake's WIX.template.in
    # with the ability to define XP_WIX_INSTALL_SCOPE, XP_WIX_PRODUCT_INJECT
    set(XP_WIX_INSTALL_SCOPE " InstallScope=\"perMachine\"") # sets ALLUSERS property to 1
    xpCpackWixDisableRM(XP_WIX_PRODUCT_INJECT) # disable restart manager - runs before custom actions (server shutdown)
    # upgrade path based on version, downgrade disabled:
    xpCpackWixUpgradeReplace(XP_WIX_PRODUCT_INJECT ${CPACK_WIX_UPGRADE_GUID} ${CPACK_PACKAGE_VERSION})
    if("server" IN_LIST CPACK_COMPONENTS_ALL)
      xpCpackWixCAFeature(XP_WIX_PRODUCT_INJECT) # requires xpCpackWixCAGroup
      # CustomAction and InstallExecuteSequence (INS: install, SILENT_INS: silent install, UNINS: uninstall)
      if(DEFINED XP_WIX_SERVER_RUNAPP)
        xpCpackWixRunApp(acts server.bin.${XP_WIX_SERVER_RUNAPP}.exe "Launch ${XP_WIX_SERVER_RUNAPP} when installer exits")
      endif()
      xpCpackWixCASetQt(svcInstall server.bin.${XP_SERVER_EXECUTABLE}.exe --install INS acts seqs)
      xpCpackWixCASetQt(svcUninstall server.bin.${XP_SERVER_EXECUTABLE}.exe --uninstall UNINS acts seqs)
      xpCpackWixCAGroup(${CMAKE_CURRENT_BINARY_DIR}/ca.wxs "${acts}" "${seqs}")
      # NOTE: can have multiple extra sources (.wxs)
      set(CPACK_WIX_EXTRA_SOURCES # list of extra sources
        "${CMAKE_CURRENT_BINARY_DIR}/ca.wxs"
        )
      set(CPACK_WIX_LIGHT_EXTENSIONS WixUtilExtension) # required by xpCpackWixCASetQt (CAQuietExec)
    endif()
    configure_file(${CMAKE_SOURCE_DIR}/.devcontainer/cmake/main.wxs.in ${CMAKE_CURRENT_BINARY_DIR})
    set(CPACK_WIX_TEMPLATE ${CMAKE_CURRENT_BINARY_DIR}/main.wxs.in)
    set(CPACK_WIX_CANDLE_EXTRA_FLAGS "-fips") # federal information processing standards (security policy)
  endif()
elseif(CMAKE_SYSTEM_NAME STREQUAL Linux)
  set(CPACK_GENERATOR TXZ)
  if(DEFINED CPACK_COMPONENTS_ALL)
    if(("client" IN_LIST CPACK_COMPONENTS_ALL) OR ("server" IN_LIST CPACK_COMPONENTS_ALL))
      list(APPEND CPACK_GENERATOR RPM)
    endif()
  endif()
  if("RPM" IN_LIST CPACK_GENERATOR)
    set(CPACK_RPM_COMPONENT_INSTALL ON)
    set(CPACK_RPM_PACKAGE_RELOCATABLE FALSE)
    set(CPACK_RPM_SPEC_MORE_DEFINE "%define _build_id_links none")
    if(NOT DEFINED XP_RPM_OWNER)
      set(XP_RPM_OWNER daemon)
    endif()
    if(NOT DEFINED XP_RPM_UMASK)
      set(XP_RPM_UMASK 0002)
    endif()
    if(NOT DEFINED XP_RPM_UNIT_FILE)
      string(TOLOWER ${CPACK_PACKAGE_NAME}.service XP_RPM_UNIT_FILE)
    endif()
    if(DEFINED XP_INSTALLDIR)
      set(XP_RPM_INSTALLDIR "/opt/${XP_INSTALLDIR}")
    else()
      set(XP_RPM_INSTALLDIR "/opt/${CPACK_PACKAGE_NAME}")
    endif()
    if(DEFINED XP_RPM_STOP_EXECUTABLE)
      set(XP_RPM_EXECSTOP "\nExecStop=${XP_RPM_INSTALLDIR}/bin/${XP_RPM_STOP_EXECUTABLE}\n")
    endif()
    configure_file(${CMAKE_CURRENT_LIST_DIR}/cpack/scripts.postinstall.client.in cpack.scripts/postinstall.client @ONLY)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/cpack/scripts.preinstall.in cpack.scripts/preinstall @ONLY)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/cpack/scripts.postinstall.in cpack.scripts/postinstall @ONLY)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/cpack/scripts.preremove.in cpack.scripts/preremove @ONLY)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/cpack/scripts.service.in cpack.scripts/${XP_RPM_UNIT_FILE} @ONLY)
    # TRICKY: case-sensitive component for CPACK_RPM here (not all CAPS like above)
    set(CPACK_RPM_client_POST_INSTALL_SCRIPT_FILE ${CMAKE_CURRENT_BINARY_DIR}/cpack.scripts/postinstall.client)
    set(CPACK_RPM_server_PRE_INSTALL_SCRIPT_FILE ${CMAKE_CURRENT_BINARY_DIR}/cpack.scripts/preinstall)
    set(CPACK_RPM_server_POST_INSTALL_SCRIPT_FILE ${CMAKE_CURRENT_BINARY_DIR}/cpack.scripts/postinstall)
    set(CPACK_RPM_server_PRE_UNINSTALL_SCRIPT_FILE ${CMAKE_CURRENT_BINARY_DIR}/cpack.scripts/preremove)
    if("server" IN_LIST CPACK_COMPONENTS_ALL)
      install(FILES ${CMAKE_CURRENT_BINARY_DIR}/cpack.scripts/${XP_RPM_UNIT_FILE} DESTINATION .init COMPONENT server)
    endif()
  endif()
endif()
configure_file(${CMAKE_CURRENT_LIST_DIR}/cpack/scripts.cpackcond.in cpack.scripts/cpackcond.cmake @ONLY)
set(CPACK_PROJECT_CONFIG_FILE ${CMAKE_CURRENT_BINARY_DIR}/cpack.scripts/cpackcond.cmake)
include(CPack)
