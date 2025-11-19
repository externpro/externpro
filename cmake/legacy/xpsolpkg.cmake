########################################
# xpsolpkg.cmake
#  xp = intended to be used both internally (by externpro) and externally
#  sol = solaris
#  pkg = package
# cmake functions to aid in building Solaris 10 pkg installers
# (which are not supported natively by CPack)
# cmakeify off

if(NOT ${CMAKE_SYSTEM_NAME} STREQUAL SunOS)
  return() # xpsolpkg.cmake is Solaris (aka SunOS) only.
endif()

# cmakeify on
get_filename_component(cmakePath ${CMAKE_COMMAND} DIRECTORY)
find_program(XPKG_CPACK cpack ${cmakePath})
find_program(XPKG_PKGPROTO pkgproto)
find_program(XPKG_PKGMK pkgmk)
find_program(XPKG_PKGTRANS pkgtrans)
find_program(XPKG_ID /usr/xpg4/bin/id)
mark_as_advanced(XPKG_CPACK XPKG_PKGPROTO XPKG_PKGMK XPKG_PKGTRANS XPKG_ID)
if(NOT XPKG_CPACK OR NOT XPKG_PKGPROTO OR NOT XPKG_PKGMK OR NOT XPKG_PKGTRANS OR NOT XPKG_ID)
  message(SEND_ERROR "xpsolpkg: required programs not found")
endif()

function(xpkgGeneratePkginfo)
  file(WRITE ${pkginfo} "PKG=${pkg${COMP}}\n")
  if(COMP)
    string(TOUPPER "${COMP}" COMPCAPS)
    file(APPEND ${pkginfo} "NAME=\"${CPACK_COMPONENT_${COMPCAPS}_DISPLAY_NAME}\"\n")
  else()
    file(APPEND ${pkginfo} "NAME=\"${CPACK_PACKAGE_NAME}\"\n")
  endif()
  if(CPACK_PKG_PACKAGE_ARCH) # defaults to `uname -m` (see `man pkgmk`)
    file(APPEND ${pkginfo} "ARCH=\"${CPACK_PKG_PACKAGE_ARCH}\"\n")
  endif()
  file(APPEND ${pkginfo} "VERSION=${CPACK_PACKAGE_VERSION}\n") # required
  if(CPACK_PKG_PACKAGE_CATEGORY)
    file(APPEND ${pkginfo} "CATEGORY=\"${CPACK_PKG_PACKAGE_CATEGORY}\"\n")
  else()
    file(APPEND ${pkginfo} "CATEGORY=\"application\"\n") # provide a default
  endif()
  if(CPACK_PACKAGE_DESCRIPTION_SUMMARY)
    file(APPEND ${pkginfo} "VSTOCK=\"${CPACK_PACKAGE_DESCRIPTION_SUMMARY}\"\n") # optional
  endif()
  file(APPEND ${pkginfo} "VENDOR=\"${CPACK_PACKAGE_VENDOR}\"\n") # required
  if(CPACK_PKG_PACKAGE_EMAIL)
    file(APPEND ${pkginfo} "EMAIL=\"${CPACK_PKG_PACKAGE_EMAIL}\"\n") # optional
  endif()
  if(CPACK_PACKAGE_CONTACT)
    file(APPEND ${pkginfo} "HOTLINE=\"${CPACK_PACKAGE_CONTACT}\"\n") # optional
  endif()
  if(CPACK_PKG_INSTALL_PREFIX)
    file(APPEND ${pkginfo} "BASEDIR=\"${CPACK_PKG_INSTALL_PREFIX}\"\n")
  else()
    file(APPEND ${pkginfo} "BASEDIR=\"/opt\"\n") # provide a default
  endif()
  if(CPACK_PKG_PACKAGE_CLASSES)
    file(APPEND ${pkginfo} "CLASSES=\"${CPACK_PKG_PACKAGE_CLASSES}\"\n")
  else()
    file(APPEND ${pkginfo} "CLASSES=\"none\"\n") # provide a default
  endif()
endfunction()

function(xpkgGeneratePrototype)
  set(prototype ${CMAKE_CURRENT_BINARY_DIR}/prototype${COMP}Cmake)
  file(WRITE ${prototype} "i pkginfo=${pkginfo}\n")
  if(COMP)
    set(COMP_ ${COMP}_)
  else()
    set(COMP_)
  endif()
  if(CPACK_PKG_${COMP_}REQUEST_SCRIPT_FILE)
    file(APPEND ${prototype} "i request=${CPACK_PKG_${COMP_}REQUEST_SCRIPT_FILE}\n")
  endif()
  if(CPACK_PKG_${COMP_}CHECK_INSTALL_SCRIPT_FILE)
    file(APPEND ${prototype} "i checkinstall=${CPACK_PKG_${COMP_}CHECK_INSTALL_SCRIPT_FILE}\n")
  endif()
  if(CPACK_PKG_${COMP_}PRE_INSTALL_SCRIPT_FILE)
    file(APPEND ${prototype} "i preinstall=${CPACK_PKG_${COMP_}PRE_INSTALL_SCRIPT_FILE}\n")
  endif()
  if(CPACK_PKG_${COMP_}POST_INSTALL_SCRIPT_FILE)
    file(APPEND ${prototype} "i postinstall=${CPACK_PKG_${COMP_}POST_INSTALL_SCRIPT_FILE}\n")
  endif()
  if(CPACK_PKG_${COMP_}PRE_UNINSTALL_SCRIPT_FILE)
    file(APPEND ${prototype} "i preremove=${CPACK_PKG_${COMP_}PRE_UNINSTALL_SCRIPT_FILE}\n")
  endif()
  if(CPACK_PKG_${COMP_}POST_UNINSTALL_SCRIPT_FILE)
    file(APPEND ${prototype} "i postremove=${CPACK_PKG_${COMP_}POST_UNINSTALL_SCRIPT_FILE}\n")
  endif()
endfunction()

macro(xpkgGenerate)
  if(COMP)
    set(dashComp -${COMP})
  else()
    set(dashComp)
  endif()
  set(pkg${COMP} ${CPACK_PACKAGE_NAME_LOW}${dashComp})
  set(pkginfo ${CMAKE_CURRENT_BINARY_DIR}/pkginfo${COMP}) # needed for pkginfo and prototype
  xpkgGeneratePkginfo()
  xpkgGeneratePrototype()
  list(APPEND pkgtgzList ${outDir}/${CPACK_PKG_TGZ_NAME}${dashComp}.tar.gz)
  list(APPEND pkgList ${pkg${COMP}})
endmacro()

macro(xpkgCommands)
  set(prototype ${CMAKE_CURRENT_BINARY_DIR}/prototype${COMP})
  set(compDir ${CMAKE_BINARY_DIR}/_CPack_Packages/${CPACK_SYSTEM_NAME}/TGZ/${CPACK_PKG_TGZ_NAME}/${COMP})
  add_custom_command(OUTPUT pkgproto${COMP}Cmd
    COMMAND cat ${CMAKE_CURRENT_BINARY_DIR}/prototype${COMP}Cmake > ${prototype}
    COMMAND find . -print | ${XPKG_PKGPROTO} | ${modu} | ${modg} >> ${prototype}
    WORKING_DIRECTORY ${compDir}
    DEPENDS ${pkgtgzList}
    )
  add_custom_command(OUTPUT pkgmk${COMP}Cmd
    COMMAND ${XPKG_PKGMK} -o -b ${compDir} -d ${CMAKE_CURRENT_BINARY_DIR} -f prototype${COMP}
    DEPENDS pkgproto${COMP}Cmd
    )
  list(APPEND pkgmkCmds pkgmk${COMP}Cmd)
endmacro()
# cmakeify off

# cmakeify on
if(CPACK_OUTPUT_FILE_PREFIX)
  set(outDir ${CPACK_OUTPUT_FILE_PREFIX})
else()
  set(outDir ${CMAKE_BINARY_DIR})
endif()
string(TOLOWER "${CPACK_PACKAGE_NAME}" CPACK_PACKAGE_NAME_LOW)
if(CPACK_COMPONENTS_ALL)
  foreach(COMP ${CPACK_COMPONENTS_ALL})
    xpkgGenerate()
  endforeach()
else()
  xpkgGenerate()
endif()
add_custom_command(OUTPUT ${pkgtgzList}
  COMMAND ${XPKG_CPACK} -G TGZ  COMMENT "Executing cpack -G TGZ"
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
  )
execute_process(COMMAND ${XPKG_ID} -un OUTPUT_VARIABLE uid OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND ${XPKG_ID} -Gn OUTPUT_VARIABLE gid OUTPUT_STRIP_TRAILING_WHITESPACE)
set(modu gawk -v u=\"${uid}\" "'{gsub(u,\"root\")\;print}'")
set(modg gawk -v g=\"${gid}\" "'{gsub(g,\"bin\")\;print}'")
if(CPACK_COMPONENTS_ALL)
  foreach(COMP ${CPACK_COMPONENTS_ALL})
    xpkgCommands()
  endforeach()
else()
  xpkgCommands()
endif()
add_custom_command(OUTPUT ${outDir}/${CPACK_PACKAGE_FILE_NAME}.pkg
  COMMAND ${XPKG_PKGTRANS} -o -s
    ${CMAKE_CURRENT_BINARY_DIR} # device where pkg currently resides
    ${outDir}/${CPACK_PACKAGE_FILE_NAME}.pkg # device onto which translated pkg written
    ${pkgList} # one or more package abbreviations
    DEPENDS ${pkgmkCmds}
  )
add_custom_target(pkg DEPENDS ${outDir}/${CPACK_PACKAGE_FILE_NAME}.pkg)
