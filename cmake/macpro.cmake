########################################
# macpro.cmake
#  mac = macros
#  pro = meant for internal use by exdlpro
# macros should begin with pro prefix

macro(proInit) # NOTE: called by top-level CMakeLists.txt
  include(ExternalProject) # include cmake ExternalProject module
  mark_as_advanced(CMAKE_BUILD_TYPE) # this project doesn't build anything
  mark_as_advanced(CMAKE_INSTALL_PREFIX) # not applicable
  # Set configuration types
  if(CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_CONFIGURATION_TYPES "Release" CACHE STRING
      "Set the configurations to what we need" FORCE
      )
    mark_as_advanced(CMAKE_CONFIGURATION_TYPES)
  endif()
  # Set directory locations
  if(NOT DEFINED DWNLD_DIR)
    set(DWNLD_DIR ${CMAKE_BINARY_DIR}/../_bldpkgs)
  endif()
  if(NOT EXISTS ${DWNLD_DIR})
    execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${DWNLD_DIR})
  endif()
  set(MODULES_DIR ${CMAKE_SOURCE_DIR}/.devcontainer/cmake)
  set_property(DIRECTORY PROPERTY "EP_BASE" ${CMAKE_BINARY_DIR}/xpbase) # ExternalProject
  set(NULL_DIR ${CMAKE_BINARY_DIR}/xpbase/tmp/nulldir)
  # the following *_folder for TARGET PROPERTY FOLDER (MSVC organization)
  set(dwnld_folder "download")
  set(src_folder "source")
  set(bld_folder "build")
  set_property(GLOBAL PROPERTY USE_FOLDERS ON) # enables MSVC Solution Folders
  # Find git
  include(FindGit)
  if(NOT GIT_FOUND AND NOT UNIX)
    find_program(GIT_EXECUTABLE
      NAMES git.exe HINTS $ENV{SystemDrive}/cygwin/bin
      DOC "git command line client (cygwin)"
      )
    if(GIT_EXECUTABLE)
      find_package(Git)
    endif()
  endif()
  proSetOpts()
  proInitFunFiles()
endmacro()

macro(proSetOpts) # NOTE: called by proInit
  include(CMakeDependentOption)
  option(XP_DEFAULT "do the default projects" ON)
  if(NOT XP_STEP) # if not specified, default to "patch"
    set(XP_STEP "patch" CACHE STRING
      "Choose the steps to execute, options are: mkpatch download patch build."
      FORCE
      )
  else()
    set(XP_STEP ${XP_STEP} CACHE STRING
      "Choose the steps to execute, options are: mkpatch download patch build."
      FORCE
      )
  endif()
  message(STATUS "[mkpatch]  execute only task 0: clone, checkout, make patches")
  message(STATUS "[download] execute only step 1: download compressed archives")
  message(STATUS "           (suitable for light transport)")
  message(STATUS "[patch]    execute through step 2: expand and patch")
  message(STATUS "           (suitable for debug, step into source)")
  message(STATUS "[build]    execute through step 3: build the platform-specific binaries")
  set(XP_BUILD_RELEASE ON) # release is *always* built, debug is optional
  cmake_dependent_option(XP_BUILD_DEBUG "build debug" ON "XP_STEP STREQUAL build" OFF)
  cmake_dependent_option(XP_BUILD_DEBUG_ALL "build debug all (ON) or select (OFF) projects" ON "XP_BUILD_DEBUG" OFF)
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(XP_BUILD_64BIT ON)
    set(XP_BUILD_32BIT OFF)
  elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(XP_BUILD_64BIT OFF)
    set(XP_BUILD_32BIT ON)
  else()
    cmake_dependent_option(XP_BUILD_64BIT "build 64-bit" ON "XP_STEP STREQUAL build" ON)
    cmake_dependent_option(XP_BUILD_32BIT "build 32-bit" OFF "XP_STEP STREQUAL build" OFF)
  endif()
  cmake_dependent_option(XP_BUILD_VERBOSE "show build target details" OFF "XP_STEP STREQUAL build" OFF)
  if(MSVC)
    cmake_dependent_option(XP_BUILD_STATIC "build with static runtime (/MT), OFF: dynamic runtime (/MD)" ON
      "XP_STEP STREQUAL build" ON
      )
  endif()
endmacro()

macro(proInitFunFiles) # NOTE: called by proInit
  # cmake-generate the xpbase/pro/${XP_STEP}.cmake function files
  set(stepMkpatch ${CMAKE_BINARY_DIR}/xpbase/pro/mkpatch.cmake)
  set(stepDownload ${CMAKE_BINARY_DIR}/xpbase/pro/download.cmake)
  set(stepPatch ${CMAKE_BINARY_DIR}/xpbase/pro/patch.cmake)
  set(stepBuild ${CMAKE_BINARY_DIR}/xpbase/pro/build.cmake)
  ####
  file(WRITE ${stepMkpatch} "message(STATUS \"XP_STEP: mkpatch\")\n")
  file(WRITE ${stepDownload} "message(STATUS \"XP_STEP: download\")\n")
  ####
  file(WRITE ${stepPatch} "proGetBuildLists()\n")
  file(APPEND ${stepPatch} "message(STATUS \"XP_STEP: patch\")\n")
  ####
  file(WRITE ${stepBuild} "proGetBuildLists()\n")
  file(APPEND ${stepBuild} "message(STATUS \"[build] -- platform: \${BUILD_PLATFORM}-bit\")\n")
  file(APPEND ${stepBuild} "message(STATUS \"[build] -- configurations: \${BUILD_CONFIGS}\")\n")
  file(APPEND ${stepBuild} "message(STATUS \"XP_STEP: build\")\n")
  file(APPEND ${stepBuild} "proSetStageDir()\n")
endmacro()

macro(proAddProjectDir proDir) # NOTE: called by top-level CMakeLists.txt
  include(${MODULES_DIR}/xpfunmac.cmake)
  xpMarkdownReadmeInit()
  get_filename_component(PRO_DIR ${proDir} ABSOLUTE)
  get_filename_component(PATCH_DIR ${PRO_DIR}/../patches ABSOLUTE)
  file(GLOB projects ${PRO_DIR}/*.cmake)
  list(SORT projects) # sort list in-place alphabetically
  foreach(proj ${projects})
    include(${proj})
    # TRICKY: get_filename_component NAME_WE doesn't work as desired
    # (ex: foo.js.cmake returns foo, not foo.js)
    get_filename_component(pro ${proj} NAME)
    string(REPLACE ".cmake" "" pro ${pro}) # name w/o .cmake extension
    string(REPLACE "-" "_" cmdp ${pro})
    string(REPLACE "." "_" cmdp ${cmdp})
    string(TOUPPER ${pro} PRO)
    # mkpatch
    if(COMMAND mkpatch_${cmdp})
      file(APPEND ${stepMkpatch} "mkpatch_${cmdp}()\n")
    elseif(DEFINED PRO_${PRO})
      file(APPEND ${stepMkpatch} "xpCloneProject(\${PRO_${PRO}})\n")
    endif()
    # download
    if(COMMAND download_${cmdp})
      file(APPEND ${stepDownload} "download_${cmdp}()\n")
    elseif(DEFINED PRO_${PRO})
      file(APPEND ${stepDownload} "xpDownloadProject(\${PRO_${PRO}})\n")
    endif()
    # patch
    if(COMMAND patch_${cmdp})
      file(APPEND ${stepPatch} "patch_${cmdp}()\n")
    elseif(DEFINED PRO_${PRO})
      file(APPEND ${stepPatch} "xpPatchProject(\${PRO_${PRO}})\n")
    endif()
    # build
    if(COMMAND build_${cmdp})
      file(APPEND ${stepBuild} "build_${cmdp}()\n")
    elseif(DEFINED PRO_${PRO})
      proCustomBuild(${PRO_${PRO}})
    endif()
    xpMarkdownReadmeAppend(${pro})
  endforeach()
  file(GLOB xpfiles
    ${PROJECT_SOURCE_DIR}/README* ${PROJECT_SOURCE_DIR}/LICENSE* ${PROJECT_SOURCE_DIR}/*.cmake
    ${PRO_DIR}/README*
    ${CMAKE_BINARY_DIR}/xpbase/pro/*.cmake
    ${MODULES_DIR}/*.cmake ${MODULES_DIR}/*.in
    ${PRO_DIR}/use/usexp-*-config.cmake
    ${PATCH_DIR}/*.patch
    )
  list(APPEND xpfiles ${projects})
  xpSourceListAppend("${xpfiles}")
endmacro()

function(proCustomBuild)
  set(oneValueArgs BUILD_FUNC BUILD_FUNC_ARG)
  cmake_parse_arguments(X "" "${oneValueArgs}" "" ${ARGN})
  if(DEFINED X_BUILD_FUNC AND COMMAND ${X_BUILD_FUNC})
    if(DEFINED X_BUILD_FUNC_ARG)
      file(APPEND ${stepBuild} "${X_BUILD_FUNC}(${X_BUILD_FUNC_ARG})\n")
    else()
      file(APPEND ${stepBuild} "${X_BUILD_FUNC}()\n")
    endif()
  endif()
endfunction()

macro(proExecuteStep) # NOTE: called by top-level CMakeLists.txt
  if(${XP_STEP} STREQUAL "mkpatch")
    if(NOT GIT_EXECUTABLE)
      message(FATAL_ERROR "mkpatch step requires GIT_EXECUTABLE to be set")
    endif()
    include(${CMAKE_BINARY_DIR}/xpbase/pro/mkpatch.cmake)
    xpMarkdownReadmeFinalize()
  elseif(${XP_STEP} STREQUAL "download")
    include(${CMAKE_BINARY_DIR}/xpbase/pro/download.cmake)
    xpMarkdownReadmeFinalize()
  elseif(${XP_STEP} STREQUAL "patch")
    include(${CMAKE_BINARY_DIR}/xpbase/pro/patch.cmake)
    xpMarkdownReadmeFinalize()
  elseif(${XP_STEP} STREQUAL "build")
    include(${CMAKE_BINARY_DIR}/xpbase/pro/patch.cmake)
    include(${CMAKE_BINARY_DIR}/xpbase/pro/build.cmake)
    install(DIRECTORY ${STAGE_DIR}/ DESTINATION . USE_SOURCE_PERMISSIONS)
    include(CPack)
  else()
    message(AUTHOR_WARNING "Invalid XP_STEP specified.")
  endif()
endmacro()

macro(proGetBuildLists) # NOTE: called by cmake-generated xpbase/pro/[patch|build].cmake files
  # BUILD_PLATFORM
  if(NOT XP_BUILD_64BIT AND NOT XP_BUILD_32BIT) # at least one platform should be set
    message(FATAL_ERROR "neither XP_BUILD_64BIT or XP_BUILD_32BIT are set")
  endif()
  if(XP_BUILD_64BIT AND XP_BUILD_32BIT) # only one platform should be set
    message(FATAL_ERROR "must choose only one: XP_BUILD_64BIT or XP_BUILD_32BIT")
  endif()
  if(XP_BUILD_64BIT)
    set(BUILD_PLATFORM 64)
  elseif(XP_BUILD_32BIT)
    set(BUILD_PLATFORM 32)
  endif()
  # BUILD_CONFIGS
  if(NOT XP_BUILD_RELEASE AND NOT XP_BUILD_DEBUG)
    message(FATAL_ERROR "no build configuration (debug, release) is set")
  endif()
  if(XP_BUILD_RELEASE)
    xpListAppendIfDne(BUILD_CONFIGS Release)
  endif()
  if(XP_BUILD_DEBUG_ALL)
    xpListAppendIfDne(BUILD_CONFIGS Debug)
  endif()
endmacro()

macro(proSetStageDir) # NOTE: called by cmake-generated xpbase/pro/build.cmake file and xpInstallPro
  if(NOT DEFINED INSTALL_NAME)
    set(INSTALL_NAME ${PROJECT_NAME})
  endif()
  set(STAGE_DIR ${CMAKE_BINARY_DIR}/${INSTALL_NAME})
  if(GIT_FOUND AND EXISTS ${CMAKE_SOURCE_DIR}/.git)
    execute_process(COMMAND ${GIT_EXECUTABLE} describe --tags
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      OUTPUT_VARIABLE GIT_DESCRIBE
      OUTPUT_STRIP_TRAILING_WHITESPACE
      )
    if(GIT_DESCRIBE)
      option(XP_DIRTYREPO "mark stage directory with dirtyrepo" ON)
      mark_as_advanced(XP_DIRTYREPO)
      if(XP_DIRTYREPO)
        # add prefix if git repo is dirty
        execute_process(COMMAND ${GIT_EXECUTABLE} status --porcelain
          WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
          OUTPUT_VARIABLE dirty
          OUTPUT_STRIP_TRAILING_WHITESPACE
          )
        if(dirty)
          string(REPLACE "\n" ";" dirtyList ${dirty})
          list(LENGTH dirtyList len)
          if(${len} GREATER 1 OR NOT " M CMakePresetsBase.json" IN_LIST dirtyList)
            if(UNIX)
              set(PREFIX "$ENV{USER}-dirtyrepo-")
            elseif(WIN32)
              set(PREFIX "$ENV{USERNAME}-dirtyrepo-")
            endif()
          endif()
        endif()
      endif()
      xpGetCompilerPrefix(COMPILER)
      option(XP_MARKPARTIAL "mark stage directory with partial indicator" ON)
      mark_as_advanced(XP_MARKPARTIAL)
      if(XP_MARKPARTIAL AND NOT XP_DEFAULT)
        set(PARTIAL "-p")
      endif()
      set(GIT_REV ${PREFIX}${GIT_DESCRIBE}${PARTIAL}-${COMPILER}-${BUILD_PLATFORM})
      set(STAGE_DIR ${STAGE_DIR}_${GIT_REV})
      set(XP_INFOFILE ${STAGE_DIR}/${INSTALL_NAME}_${GIT_REV}.txt)
      file(WRITE ${XP_INFOFILE} "${GIT_REV}\n")
      execute_process(COMMAND uname -a
        OUTPUT_VARIABLE sysinfo
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE unameErr
        )
      if(NOT unameErr)
        file(APPEND ${XP_INFOFILE} "${sysinfo}\n")
      endif()
      execute_process(COMMAND lsb_release --description
        OUTPUT_VARIABLE lsbDesc # LSB (Linux Standard Base)
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
        )
      if(NOT lsbDesc STREQUAL "")
        file(APPEND ${XP_INFOFILE} "lsb_release ${lsbDesc}\n")
      endif()
      if(DEFINED MSVC_VERSION)
        file(APPEND ${XP_INFOFILE} "MSVC_VERSION ${MSVC_VERSION}\n")
      endif()
    endif()
  endif()
  if(GIT_REV)
    set(CPACK_PACKAGE_VERSION ${GIT_REV})
  else()
    set(CPACK_PACKAGE_VERSION "unknown-version")
  endif()
  if(NOT DEFINED CPACK_PACKAGE_VENDOR)
    if(DEFINED PACKAGE_VENDOR)
      set(CPACK_PACKAGE_VENDOR "${PACKAGE_VENDOR}")
    else()
      set(CPACK_PACKAGE_VENDOR "smanders")
    endif()
  endif()
  if(NOT DEFINED CPACK_GENERATOR)
    set(CPACK_GENERATOR TXZ)
    if(TRUE) # match xpPackageDevel() devel package
      set(CMAKE_INSTALL_DEFAULT_COMPONENT_NAME devel)
      set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
      list(APPEND CPACK_COMPONENTS_ALL devel)
      set(CPACK_COMPONENT_INCLUDE_TOPLEVEL_DIRECTORY ON)
      unset(CPACK_PACKAGING_INSTALL_PREFIX)
      if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64|ARM64)$")
        set(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}-${CMAKE_SYSTEM_NAME}-arm64")
      endif()
      string(TOUPPER ${CMAKE_PROJECT_NAME} PRJ)
      string(TOLOWER ${CMAKE_PROJECT_NAME} NAME)
      set(VER ${CPACK_PACKAGE_VERSION})
      string(JOIN "\n" EXT1
        "get_filename_component(moduleDir \${CMAKE_CURRENT_LIST_DIR} ABSOLUTE)"
        "list(APPEND XP_MODULE_PATH \${moduleDir})"
        "list(APPEND reqVars XP_MODULE_PATH)"
        ""
        )
      set(xpuseFile ${STAGE_DIR}/share/cmake/xpuse-${CMAKE_PROJECT_NAME}-config.cmake)
      configure_file(${MODULES_DIR}/xpuse.cmake.in ${xpuseFile} @ONLY NEWLINE_STYLE LF)
    endif()
  endif()
  # configure_file to STAGE_DIR, set CMAKE_DIR
  configure_file(${MODULES_DIR}/Findscript.cmake.in
    ${STAGE_DIR}/share/cmake/Find${CMAKE_PROJECT_NAME}.cmake
    @ONLY NEWLINE_STYLE LF
    )
  if(${CMAKE_PROJECT_NAME} STREQUAL exdlpro)
    configure_file(${MODULES_DIR}/xpopts.cmake.in
      ${STAGE_DIR}/share/cmake/xpopts.cmake
      @ONLY NEWLINE_STYLE LF
      )
    set(CMAKE_DIR ${STAGE_DIR}/share/cmake)
  elseif(DEFINED exdlpro_DIR)
    set(CMAKE_DIR ${exdlpro_DIR}/share/cmake)
  endif()
endmacro()
