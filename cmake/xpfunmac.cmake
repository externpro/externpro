########################################
# xpfunmac.cmake
#  xp prefix = intended to be used both internally (by externpro) and externally
#  ip prefix = intended to be used only internally by externpro
#  fun = functions
#  mac = macros
# functions and macros should begin with xp or ip prefix
# functions create a local scope for variables, macros use the global scope
# cmakeify off

set(xpThisDir ${CMAKE_CURRENT_LIST_DIR})
include(CheckCCompilerFlag)
include(CheckCXXCompilerFlag)
include(CMakeDependentOption)

# cmakeify on
macro(xpProOption prj)
  string(TOUPPER "${prj}" PRJ)
  cmake_dependent_option(XP_PRO_${PRJ} "include ${prj}" OFF "NOT XP_DEFAULT" OFF)
  set(extraArgs ${ARGN})
  if(extraArgs)
    if(extraArgs STREQUAL DBG)
      cmake_dependent_option(XP_PRO_${PRJ}_BUILD_DBG "build debug ${prj}" OFF
        "XP_BUILD_DEBUG;NOT XP_BUILD_DEBUG_ALL" OFF
        )
    elseif(extraArgs STREQUAL DBG_MSVC AND MSVC)
      cmake_dependent_option(XP_PRO_${PRJ}_BUILD_DBG "build debug ${prj}" OFF
        "XP_BUILD_DEBUG;NOT XP_BUILD_DEBUG_ALL" OFF
        )
    endif()
  endif()
endmacro()

function(xpGetArgValue)
  set(oneValueArgs ARG VALUE NEXT)
  set(multiValueArgs VALUES)
  cmake_parse_arguments(P1 "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  if(P1_ARG AND P1_VALUE AND P1_UNPARSED_ARGUMENTS)
    cmake_parse_arguments(P2 "" "${P1_ARG}" "" ${P1_UNPARSED_ARGUMENTS})
    if(P2_${P1_ARG})
      set(${P1_VALUE} "${P2_${P1_ARG}}" PARENT_SCOPE)
    else()
      set(${P1_VALUE} "unknown" PARENT_SCOPE)
    endif()
  elseif(P1_ARG AND P1_VALUES AND P1_UNPARSED_ARGUMENTS)
    if(P1_NEXT)
      cmake_parse_arguments(P3 "" "${P1_NEXT}" "${P1_ARG}" ${P1_UNPARSED_ARGUMENTS})
    else()
      cmake_parse_arguments(P3 "" "" "${P1_ARG}" ${P1_UNPARSED_ARGUMENTS})
    endif()
    if(P3_${P1_ARG})
      set(${P1_VALUES} "${P3_${P1_ARG}}" PARENT_SCOPE)
    else()
      set(${P1_VALUES} "unknown" PARENT_SCOPE)
    endif()
  else()
    message(AUTHOR_WARNING "incorrect usage of xpGetArgValue")
  endif()
endfunction()

function(ipCloneRepoCmakeTime)
  set(oneValueArgs NAME GIT_ORIGIN GIT_UPSTREAM GIT_TRACKING_BRANCH GIT_TAG GIT_REF PATCH)
  cmake_parse_arguments(P "" "${oneValueArgs}" "" ${ARGN})
  string(TOLOWER ${P_NAME} prj)
  set(fcName xp_repo_${prj})
  if(DEFINED P_GIT_ORIGIN AND NOT TARGET ${fcName})
    if(DEFINED P_PATCH AND DEFINED P_GIT_REF)
      set(patchCmd ${GIT_EXECUTABLE} diff --ignore-submodules ${P_GIT_REF} -- > ${P_PATCH})
    else()
      set(patchCmd ${CMAKE_COMMAND} -E echo "no patch for ${prj}")
    endif()
    if(DEFINED P_GIT_UPSTREAM)
      if(DEFINED P_GIT_TRACKING_BRANCH)
        set(tb ${P_GIT_TRACKING_BRANCH})
      else()
        set(tb master)
      endif()
      set(gitUpstream && ${GIT_EXECUTABLE} branch --set-upstream-to=upstream/${tb} ${tb})
      # git remote add upstream ${P_GIT_UPSTREAM}
      set(gitRemote GIT_CONFIG remote.upstream.url=${P_GIT_UPSTREAM}
        remote.upstream.fetch=+refs/heads/*:refs/remotes/upstream/*
        )
    endif()
    include(FetchContent)
    FetchContent_Declare(${fcName}
      GIT_REPOSITORY ${P_GIT_ORIGIN} GIT_TAG ${P_GIT_TAG} ${gitRemote}
      GIT_PROGRESS TRUE
      #DOWNLOAD_COMMAND # tricky: must not be defined for git clone to happen
      UPDATE_COMMAND ${GIT_EXECUTABLE} fetch --all ${gitUpstream}
      PATCH_COMMAND ${patchCmd}
      SOURCE_SUBDIR foo # point to a directory that dne, avoid top-level CMakeLists.txt
      )
    FetchContent_MakeAvailable(${fcName})
  endif()
endfunction()

function(ipCloneRepo)
  set(oneValueArgs NAME GIT_ORIGIN GIT_UPSTREAM GIT_TRACKING_BRANCH GIT_TAG GIT_REF PATCH)
  cmake_parse_arguments(P "" "${oneValueArgs}" "" ${ARGN})
  string(TOLOWER ${P_NAME} prj)
  if(DEFINED P_GIT_ORIGIN AND NOT TARGET ${prj}_repo)
    if(DEFINED P_PATCH AND DEFINED P_GIT_REF)
      set(patchCmd ${GIT_EXECUTABLE} diff --ignore-submodules ${P_GIT_REF} -- > ${P_PATCH})
    else()
      set(patchCmd ${CMAKE_COMMAND} -E echo "no patch for ${prj}")
    endif()
    ExternalProject_Add(${prj}_repo
      GIT_REPOSITORY ${P_GIT_ORIGIN} GIT_TAG ${P_GIT_TAG}
      #DOWNLOAD_COMMAND # tricky: must not be defined for git clone to happen
      PATCH_COMMAND ""
      UPDATE_COMMAND ${GIT_EXECUTABLE} fetch --all
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ${patchCmd}
      INSTALL_COMMAND ""
      BUILD_IN_SOURCE 1 # <BINARY_DIR>==<SOURCE_DIR>
      DOWNLOAD_DIR ${NULL_DIR} INSTALL_DIR ${NULL_DIR}
      )
    if(DEFINED P_GIT_UPSTREAM)
      if(DEFINED P_GIT_TRACKING_BRANCH)
        set(trackingBranch ${P_GIT_TRACKING_BRANCH})
      else()
        set(trackingBranch master)
      endif()
      if(GIT_VERSION_STRING VERSION_LESS 1.8)
        set(upstreamCmd --set-upstream ${trackingBranch} upstream/${trackingBranch})
      else()
        set(upstreamCmd --set-upstream-to=upstream/${trackingBranch} ${trackingBranch})
      endif()
      ExternalProject_Add_Step(${prj}_repo remote_add_upstream
        COMMAND ${GIT_EXECUTABLE} remote add upstream ${P_GIT_UPSTREAM}
        WORKING_DIRECTORY <SOURCE_DIR>
        DEPENDEES download DEPENDERS update INDEPENDENT TRUE
        )
      ExternalProject_Add_Step(${prj}_repo set_upstream
        COMMAND ${GIT_EXECUTABLE} branch ${upstreamCmd}
        WORKING_DIRECTORY <SOURCE_DIR>
        DEPENDEES update DEPENDERS build INDEPENDENT TRUE
        )
    endif()
  endif()
endfunction()

function(xpCloneProject)
  set(options CMAKE_TIME)
  set(oneValueArgs NAME SUPERPRO)
  set(multiValueArgs SUBPRO)
  cmake_parse_arguments(R "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  if(DEFINED R_SUPERPRO)
    return() # we'll clone subprojects as part of their superproject
  endif()
  string(TOUPPER ${R_NAME} PRJ)
  if(XP_DEFAULT OR XP_PRO_${PRJ})
    if(R_CMAKE_TIME)
      ipCloneRepoCmakeTime(${ARGN})
    else()
      ipCloneRepo(${ARGN})
    endif()
    foreach(sub ${R_SUBPRO})
      string(TOUPPER ${sub} SUB)
      if(R_CMAKE_TIME)
        ipCloneRepoCmakeTime(${PRO_${SUB}})
      else()
        ipCloneRepo(${PRO_${SUB}})
      endif()
    endforeach()
  endif()
endfunction()

function(xpDownload pkg_url pkg_md5 download_path)
  if(IS_DIRECTORY ${download_path})
    get_filename_component(fn ${pkg_url} NAME)
    set(pkg_path ${download_path}/${fn})
  else()
    get_filename_component(fn ${download_path} NAME)
    set(pkg_path ${download_path})
  endif()
  add_custom_target(download_${fn} ALL)
  add_custom_command(TARGET download_${fn}
    COMMAND ${CMAKE_COMMAND} -Dpkg_url:STRING="${pkg_url}" -Dpkg_md5:STRING=${pkg_md5}
      -Dpkg_dir:STRING=${pkg_path}
      -P ${MODULES_DIR}/cmsdownload.cmake
    COMMENT "Downloading ${fn}..."
    )
  set_property(TARGET download_${fn} PROPERTY FOLDER ${dwnld_folder})
endfunction()

function(ipDownload)
  set(oneValueArgs DLURL DLMD5 DLNAME DLDIR)
  cmake_parse_arguments(P "" "${oneValueArgs}" "" ${ARGN})
  if(DEFINED P_DLNAME)
    set(fn ${P_DLNAME})
  else()
    get_filename_component(fn ${P_DLURL} NAME)
  endif()
  if(DEFINED P_DLDIR)
    if(IS_ABSOLUTE ${P_DLDIR})
      set(pkgPath ${P_DLDIR}/${fn})
    else()
      set(pkgPath ${DWNLD_DIR}/${P_DLDIR}/${fn})
    endif()
  else()
    set(pkgPath ${DWNLD_DIR}/${fn})
  endif()
  if(NOT TARGET download_${fn})
    add_custom_target(download_${fn} ALL)
    add_custom_command(TARGET download_${fn}
      COMMAND ${CMAKE_COMMAND} -Dpkg_url:STRING="${P_DLURL}" -Dpkg_md5:STRING=${P_DLMD5}
        -Dpkg_dir:STRING=${pkgPath}
        -P ${MODULES_DIR}/cmsdownload.cmake
      COMMENT "Downloading ${fn}..."
      )
    set_property(TARGET download_${fn} PROPERTY FOLDER ${dwnld_folder})
  endif()
endfunction()

function(ipDownloadAdditional add)
  set(oneValueArgs DLURL${add} DLMD5${add} DLDIR${add})
  cmake_parse_arguments(X "" "${oneValueArgs}" "" ${ARGN})
  if(DEFINED X_DLURL${add} AND DEFINED X_DLMD5${add})
    if(DEFINED X_DLDIR${add})
      set(downloadDir DLDIR ${X_DLDIR${add}})
    endif()
    ipDownload(DLURL ${X_DLURL${add}} DLMD5 ${X_DLMD5${add}} ${downloadDir})
  endif()
endfunction()

function(xpDownloadProject)
  set(oneValueArgs DLURL DLMD5)
  set(multiValueArgs DLADD)
  cmake_parse_arguments(R "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  if(DEFINED R_DLURL AND DEFINED R_DLMD5)
    ipDownload(${ARGN})
  endif()
  if(DEFINED R_DLADD)
    foreach(add ${R_DLADD})
      ipDownloadAdditional(${add} ${ARGN})
    endforeach()
  endif()
endfunction()

function(ipPatch)
  set(oneValueArgs NAME PARENT SUBDIR PATCH PATCH_STRIP DLURL DLMD5 DLNAME)
  set(multiValueArgs SIBLINGS DLADD)
  cmake_parse_arguments(P "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  string(TOLOWER ${P_NAME} prj)
  if(DEFINED P_PARENT)
    set(tgt ${P_PARENT}_${prj})
  else()
    set(tgt ${prj})
  endif()
  if(TARGET ${tgt})
    return()
  endif()
  # unless there's a package to extract or a patch to apply,
  # there's no reason to create a target with ExternalProject_Add()
  if(NOT DEFINED P_DLURL AND NOT DEFINED P_PATCH)
    return()
  endif()
  if(DEFINED P_PATCH)
    if(COMMAND patch_patch)
      if(NOT TARGET patch)
        patch_patch()
      endif()
      set(depsOpt DEPENDS)
      list(APPEND depsList patch)
    else()
      xpGetPkgVar(patch CMD)
    endif()
    if(DEFINED P_PATCH_STRIP)
      set(patchCmd ${PATCH_CMD} -p${P_PATCH_STRIP} < ${P_PATCH})
    else()
      set(patchCmd ${PATCH_CMD} -p1 < ${P_PATCH})
    endif()
  else()
    set(patchCmd ${CMAKE_COMMAND} -E echo "no patch for ${prj}")
  endif()
  if(DEFINED P_PARENT)
    set(depsOpt DEPENDS)
    list(APPEND depsList ${P_PARENT} ${P_SIBLINGS})
    set(srcDirOpt SOURCE_DIR)
    ExternalProject_Get_Property(${P_PARENT} SOURCE_DIR)
    if(DEFINED P_SUBDIR)
      set(srcDir ${SOURCE_DIR}/${P_SUBDIR})
    else()
      set(srcDir ${SOURCE_DIR}/${prj})
    endif()
  endif()
  if(DEFINED P_DLNAME)
    set(dlnOpt DOWNLOAD_NAME)
  endif()
  if(DEFINED P_DLURL AND DEFINED P_DLMD5)
    set(urlOpt DOWNLOAD_EXTRACT_TIMESTAMP true URL)
    set(md5Opt URL_MD5)
  elseif(NOT DEFINED P_DLURL AND NOT DEFINED P_DLMD5)
    set(urlOpt DOWNLOAD_COMMAND)
    set(md5Opt ${CMAKE_COMMAND} -E echo "no download for ${prj}")
  endif()
  ExternalProject_Add(${tgt} ${depsOpt} ${depsList}
    ${urlOpt} ${P_DLURL} ${md5Opt} ${P_DLMD5}
    DOWNLOAD_DIR ${DWNLD_DIR} ${dlnOpt} ${P_DLNAME}
    ${srcDirOpt} ${srcDir}
    PATCH_COMMAND ${patchCmd}
    UPDATE_COMMAND "" CONFIGURE_COMMAND "" BUILD_COMMAND "" INSTALL_COMMAND ""
    BINARY_DIR ${NULL_DIR} INSTALL_DIR ${NULL_DIR}
    )
  set_property(TARGET ${tgt} PROPERTY FOLDER ${src_folder})
  # additional things to download (no extract/patch support, yet)
  if(DEFINED P_DLADD)
    foreach(add ${P_DLADD})
      ipPatchAdditional(${tgt} ${add} ${ARGN})
    endforeach()
  endif()
endfunction()

function(ipPatchAdditional tgt add)
  set(oneValueArgs DLURL${add} DLMD5${add} DLDIR${add} DLNAME${add})
  cmake_parse_arguments(X "" "${oneValueArgs}" "" ${ARGN})
  if(DEFINED X_DLURL${add} AND DEFINED X_DLMD5${add})
    if(DEFINED X_DLNAME${add})
      set(fn ${X_DLNAME${add}})
    else()
      get_filename_component(fn ${X_DLURL${add}} NAME)
    endif()
    if(DEFINED X_DLDIR${add})
      if(IS_ABSOLUTE ${X_DLDIR${add}})
        set(pkgPath ${X_DLDIR${add}}/${fn})
      else()
        set(pkgPath ${DWNLD_DIR}/${X_DLDIR${add}}/${fn})
      endif()
    else()
      set(pkgPath ${DWNLD_DIR}/${fn})
    endif()
    ExternalProject_Add_Step(${tgt} ${tgt}_download_${fn}
      COMMAND ${CMAKE_COMMAND} -Dpkg_url:STRING=${X_DLURL${add}}
        -Dpkg_md5:STRING=${X_DLMD5${add}}
        -Dpkg_dir:STRING=${pkgPath}
        -P ${MODULES_DIR}/cmsdownload.cmake
      DEPENDEES download DEPENDERS patch INDEPENDENT TRUE
      )
  endif()
endfunction()

function(xpPatchProject)
  set(oneValueArgs NAME SUPERPRO)
  set(multiValueArgs SUBPRO)
  cmake_parse_arguments(R "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  if(DEFINED R_SUPERPRO)
    return() # we'll patch subprojects as part of their superproject
  endif()
  string(TOUPPER ${R_NAME} PRJ)
  if(XP_DEFAULT OR XP_PRO_${PRJ})
    ipPatch(${ARGN})
    foreach(sub ${R_SUBPRO})
      string(TOUPPER ${sub} SUB)
      string(TOLOWER ${R_NAME} super)
      ipPatch(${PRO_${SUB}} PARENT ${super} SIBLINGS ${siblings})
      string(TOLOWER ${super}_${sub} sibling)
      list(APPEND siblings ${sibling})
    endforeach()
  endif()
endfunction()

function(xpBuildDeps depTargets)
  set(options GRAPH)
  set(oneValueArgs NAME DESC VER GRAPH_NODE GRAPH_SHAPE GRAPH_LABEL)
  set(multiValueArgs REPO BUILD_DEPS)
  cmake_parse_arguments(P "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  foreach(dep ${P_BUILD_DEPS})
    set(buildDep ${CMAKE_BINARY_DIR}/xpbase/pro/builddep.cmake)
    string(TOUPPER ${dep} DEP)
    if(NOT (XP_DEFAULT OR XP_PRO_${DEP}))
      message(STATUS "${P_NAME} requires ${dep}")
      set(XP_PRO_${DEP} ON CACHE BOOL "include ${dep}" FORCE)
      xpPatchProject(${PRO_${DEP}})
    endif()
    xpGetArgValue(${PRO_${DEP}} ARG DEPS_FUNC VALUE DEPS_FUNC)
    file(WRITE ${buildDep} "${DEPS_FUNC}(${dep}Tgts)\n")
    include(${buildDep})
    list(APPEND targets ${${dep}Tgts})
    # some projects have variables that need to be passed up
    xpGetArgValue(${PRO_${DEP}} ARG DEPS_VARS VALUES DEPS_VARS)
    if(NOT DEPS_VARS STREQUAL "unknown")
      foreach(var ${DEPS_VARS})
        set(${var} ${${var}} PARENT_SCOPE)
      endforeach()
    endif()
  endforeach()
  file(REMOVE ${buildDep})
  set(${depTargets} ${targets} PARENT_SCOPE)
endfunction()

function(xpCmakeBuild XP_DEPENDS)
  cmake_parse_arguments(P NO_INSTALL "TGT;BUILD_TARGET" "" ${ARGN})
  string(TOUPPER ${XP_DEPENDS} PRJ)
  if(XP_PRO_${PRJ}_BUILD_DBG)
    xpListAppendIfDne(BUILD_CONFIGS Debug)
  endif()
  if(ARGV1) # ADDITIONAL_DEPENDS...
    foreach(dep ${ARGV1})
      list(APPEND ADDITIONAL_DEPENDS ${dep})
    endforeach()
  endif()
  if(ARGV2) # XP_CONFIGURE...
    foreach(def ${ARGV2})
      list(APPEND XP_CONFIGURE_APPEND ${def})
    endforeach()
  endif()
  if(WIN32)
    set(XP_CONFIGURE_GEN ${CMAKE_GENERATOR})
    if(NOT CMAKE_GENERATOR_PLATFORM STREQUAL "")
      set(XP_CONFIGURE_GEN_PLATFORM CMAKE_GENERATOR_PLATFORM ${CMAKE_GENERATOR_PLATFORM})
    endif()
    if(CMAKE_GENERATOR_PLATFORM STREQUAL "x64")
      set(CMAKE_GENERATOR_TOOLSET host=x64)
    endif()
    if(NOT CMAKE_GENERATOR_TOOLSET STREQUAL "")
      set(XP_CONFIGURE_GEN_TOOLSET CMAKE_GENERATOR_TOOLSET ${CMAKE_GENERATOR_TOOLSET})
    endif()
    set(XP_CONFIGURE_CMD
      -DCMAKE_MODULE_PATH:PATH=${MODULES_DIR}
      -DCMAKE_INSTALL_PREFIX:PATH=${STAGE_DIR}
      )
    set(XP_BUILD_CONFIGS_MSG " [${BUILD_CONFIGS}]")
    # BUILD and INSTALL commands broken into additional steps
    # (see foreach in ipAddProject below)
    set(XP_BUILD_CMD ${CMAKE_COMMAND} -E echo "Build MSVC...")
    set(XP_INSTALL_CMD ${CMAKE_COMMAND} -E echo "Install MSVC...")
    if(DEFINED P_TGT)
      set(XP_BUILD_TGT ${XP_DEPENDS}${P_TGT}_msvc)
    else()
      set(XP_BUILD_TGT ${XP_DEPENDS}_msvc)
    endif()
    ipAddProject(${XP_BUILD_TGT})
    list(APPEND ADDITIONAL_DEPENDS ${XP_BUILD_TGT}) # serialize the build
  else()
    set(XP_CONFIGURE_GEN "")
    if(DEFINED P_BUILD_TARGET)
      set(XP_BUILD_CMD ${CMAKE_COMMAND} --build <BINARY_DIR> --target ${P_BUILD_TARGET})
    else()
      set(XP_BUILD_CMD) # use default
    endif()
    if(P_NO_INSTALL)
      set(XP_INSTALL_CMD ${CMAKE_COMMAND} -E echo "No install")
    elseif(DEFINED P_BUILD_TARGET)
      set(XP_INSTALL_CMD ${XP_BUILD_CMD} --target install)
    else()
      set(XP_INSTALL_CMD) # use default
    endif()
    foreach(cfg ${BUILD_CONFIGS})
      set(XP_CONFIGURE_CMD
        -DCMAKE_MODULE_PATH:PATH=${MODULES_DIR}
        -DCMAKE_INSTALL_PREFIX:PATH=${STAGE_DIR}
        -DCMAKE_BUILD_TYPE:STRING=${cfg}
        )
      if(DEFINED P_TGT)
        set(XP_BUILD_TGT ${XP_DEPENDS}${P_TGT}_${cfg})
      else()
        set(XP_BUILD_TGT ${XP_DEPENDS}_${cfg})
      endif()
      ipAddProject(${XP_BUILD_TGT})
      list(APPEND ADDITIONAL_DEPENDS ${XP_BUILD_TGT}) # serialize the build
    endforeach()
  endif()
  if(ARGV3)
    if(ARGV1)
      list(REMOVE_ITEM ADDITIONAL_DEPENDS ${ARGV1})
    endif()
    set(${ARGV3} "${ADDITIONAL_DEPENDS}" PARENT_SCOPE)
  endif()
endfunction()

function(ipAddProject XP_TARGET)
  if(NOT TARGET ${XP_TARGET})
    set(XP_DEPS ${XP_DEPENDS})
    if(DEFINED XP_CONFIGURE_APPEND)
      list(APPEND XP_CONFIGURE_CMD ${XP_CONFIGURE_APPEND})
    endif()
    if(XP_BUILD_VERBOSE)
      message(STATUS "target ${XP_TARGET}${XP_BUILD_CONFIGS_MSG}")
      xpVerboseListing("[CONFIGURE]" "${XP_CONFIGURE_CMD}")
      if(NOT "${XP_CONFIGURE_GEN}" STREQUAL "")
        xpVerboseListing("[CMAKE_GENERATOR]" "${XP_CONFIGURE_GEN}")
      endif()
      if(NOT "${XP_CONFIGURE_GEN_PLATFORM}" STREQUAL "")
        xpVerboseListing("[CMAKE_GENERATOR_PLATFORM]" "${CMAKE_GENERATOR_PLATFORM}")
      endif()
      if(NOT "${XP_CONFIGURE_GEN_TOOLSET}" STREQUAL "")
        xpVerboseListing("[CMAKE_GENERATOR_TOOLSET]" "${CMAKE_GENERATOR_TOOLSET}")
      endif()
      if(NOT "${ADDITIONAL_DEPENDS}" STREQUAL "")
        xpVerboseListing("[DEPS]" "${ADDITIONAL_DEPENDS}")
      endif()
    else()
      message(STATUS "target ${XP_TARGET}${XP_BUILD_CONFIGS_MSG}")
    endif()
    ExternalProject_Get_Property(${XP_DEPS} SOURCE_DIR)
    ExternalProject_Add(${XP_TARGET} DEPENDS ${XP_DEPS} ${ADDITIONAL_DEPENDS}
      DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
      SOURCE_DIR ${SOURCE_DIR}
      CMAKE_GENERATOR ${XP_CONFIGURE_GEN} ${XP_CONFIGURE_GEN_PLATFORM} ${XP_CONFIGURE_GEN_TOOLSET}
      CMAKE_ARGS ${XP_CONFIGURE_CMD}
      BUILD_COMMAND ${XP_BUILD_CMD}
      INSTALL_COMMAND ${XP_INSTALL_CMD} INSTALL_DIR ${NULL_DIR}
      )
    set_property(TARGET ${XP_TARGET} PROPERTY FOLDER ${bld_folder})
    if(WIN32)
      ExternalProject_Add_Step(${XP_TARGET} bugworkaround
        # work around a cmake bug: run cmake again for changes to
        # CMAKE_CONFIGURATION_TYPES to take effect (see modules/flags.cmake)
        COMMAND ${CMAKE_COMMAND} <BINARY_DIR>
        DEPENDEES configure DEPENDERS build #INDEPENDENT TRUE
        )
      if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(pfstr x64)
      elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
        set(pfstr Win32)
      endif()
      foreach(cfg ${BUILD_CONFIGS})
        # Run cmake --build with no options for quick help
        if(DEFINED P_BUILD_TARGET)
          set(build_cmd ${CMAKE_COMMAND} --build <BINARY_DIR> --config ${cfg} --target ${P_BUILD_TARGET})
        else()
          set(build_cmd ${CMAKE_COMMAND} --build <BINARY_DIR> --config ${cfg})
        endif()
        if(P_NO_INSTALL)
          set(install_cmd ${CMAKE_COMMAND} -E echo "No install")
        else()
          set(install_cmd ${build_cmd} --target install)
        endif()
        if(NOT MSVC10 OR ${CMAKE_MAJOR_VERSION} GREATER 2)
          # needed for cmake builds which use include_external_msproject
          list(APPEND build_cmd -- /property:Platform=${pfstr})
          list(APPEND install_cmd -- /property:Platform=${pfstr})
        endif()
        ExternalProject_Add_Step(${XP_TARGET} build_${cfg}_${pfstr}
          COMMAND ${build_cmd} DEPENDEES build DEPENDERS install #INDEPENDENT TRUE
          )
        ExternalProject_Add_Step(${XP_TARGET} install_${cfg}_${pfstr}
          COMMAND ${install_cmd} DEPENDEES install #INDEPENDENT TRUE
          )
        if(XP_BUILD_VERBOSE)
          string(REPLACE ";" " " build_cmd "${build_cmd}")
          string(REPLACE ";" " " install_cmd "${install_cmd}")
          message(STATUS "  [BUILD]")
          message(STATUS "  ${build_cmd}")
          message(STATUS "  [INSTALL]")
          message(STATUS "  ${install_cmd}")
        endif()
      endforeach()
    endif(WIN32)
  endif()
endfunction()

function(xpCmakePackage XP_TGTS)
  find_program(XP_FIND_RPMBUILD rpmbuild)
  mark_as_advanced(XP_FIND_RPMBUILD)
  if(XP_FIND_RPMBUILD)
    list(APPEND cpackGen RPM)
  endif()
  #####
  find_program(XP_FIND_DPKGDEB dpkg-deb)
  mark_as_advanced(XP_FIND_DPKGDEB)
  if(XP_FIND_DPKGDEB)
    list(APPEND cpackGen DEB)
  endif()
  #####
  if(${CMAKE_SYSTEM_NAME} STREQUAL SunOS)
    list(APPEND cpackGen PKG)
  endif()
  #####
  get_filename_component(cmakePath ${CMAKE_COMMAND} DIRECTORY)
  find_program(XP_CPACK_CMD cpack ${cmakePath})
  mark_as_advanced(XP_CPACK_CMD)
  if(NOT XP_CPACK_CMD)
    message(SEND_ERROR "xpCmakePackage: cpack not found")
  endif()
  #####
  foreach(tgt ${XP_TGTS})
    ExternalProject_Get_Property(${tgt} SOURCE_DIR)
    ExternalProject_Get_Property(${tgt} BINARY_DIR)
    foreach(gen ${cpackGen})
      if(NOT TARGET ${tgt}${gen})
        if(${gen} STREQUAL PKG)
          ExternalProject_Add(${tgt}${gen} DEPENDS ${tgt} ${pkgTgts}
            DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
            SOURCE_DIR ${SOURCE_DIR} BINARY_DIR ${BINARY_DIR}
            BUILD_COMMAND ${CMAKE_COMMAND} --build ${BINARY_DIR} --target pkg
            INSTALL_COMMAND "" INSTALL_DIR ${NULL_DIR}
            )
        else()
          ExternalProject_Add(${tgt}${gen} DEPENDS ${tgt} ${pkgTgts}
            DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
            SOURCE_DIR ${SOURCE_DIR} BINARY_DIR ${BINARY_DIR}
            BUILD_COMMAND ${XP_CPACK_CMD} -G ${gen} -D CPACK_OUTPUT_FILE_PREFIX=${STAGE_DIR}/pkg
            INSTALL_COMMAND "" INSTALL_DIR ${NULL_DIR}
            )
        endif()
        set_property(TARGET ${tgt}${gen} PROPERTY FOLDER ${bld_folder})
        message(STATUS "target ${tgt}${gen}")
      endif() # NOT TARGET
      list(APPEND pkgTgts ${tgt}${gen})
    endforeach() # gen
  endforeach() # tgt
  if(ARGV1)
    set(${ARGV1} "${pkgTgts}" PARENT_SCOPE)
  endif()
endfunction()

function(ipMarkdownLink var _ret)
  list(LENGTH var len)
  if(NOT ${len} EQUAL 3)
    message(AUTHOR_WARNING "incorrect usage of ipMarkdownLink: ${var}")
  endif()
  list(GET var 0 text)
  list(GET var 1 url)
  list(GET var 2 title)
  set(${_ret} "[${text}](${url} '${title}')" PARENT_SCOPE)
endfunction()
# cmakeify off

set(g_README ${CMAKE_BINARY_DIR}/xpbase/pro/README.md)
set(g_READMEsub ${CMAKE_BINARY_DIR}/xpbase/pro/README.sub.md)
set(g_READMEdep ${CMAKE_BINARY_DIR}/xpbase/pro/deps.dot)

# cmakeify on
function(xpMarkdownReadmeInit)
  file(WRITE ${g_README}
    "# projects\n\n"
    "|project|license|description|version|repository|patch/diff|\n"
    "|-------|-------|-----------|-------|----------|----------|\n"
    )
  if(EXISTS ${g_READMEsub})
    file(REMOVE ${g_READMEsub})
  endif()
  if(EXISTS ${g_READMEdep})
    file(REMOVE ${g_READMEdep})
  endif()
endfunction()

function(xpMarkdownReadmeAppend proj)
  string(TOUPPER "${proj}" PROJ)
  if(DEFINED PRO_${PROJ})
    ipMarkdownPro(${PRO_${PROJ}})
  endif()
endfunction()

function(ipMarkdownPro)
  set(options GRAPH NO_README)
  set(oneValueArgs NAME DESC VER GIT_REF GIT_TAG SUPERPRO DIFF PATCH GRAPH_NODE GRAPH_SHAPE GRAPH_LABEL)
  set(multiValueArgs WEB LICENSE REPO BUILD_DEPS)
  cmake_parse_arguments(P "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  if(DEFINED P_WEB)
    ipMarkdownLink("${P_WEB}" web)
  else()
    set(web ${proj})
  endif()
  if(DEFINED P_LICENSE)
    ipMarkdownLink("${P_LICENSE}" lic)
  else()
    set(lic "unknown")
  endif()
  if(DEFINED P_DESC)
    set(desc ${P_DESC})
  else()
    set(desc "project needs description")
  endif()
  if(DEFINED P_VER)
    set(ver ${P_VER})
  else()
    set(ver "unknown")
  endif()
  if(DEFINED P_REPO)
    ipMarkdownLink("${P_REPO}" repo)
  else()
    set(repo "none")
  endif()
  if(DEFINED P_DIFF AND DEFINED P_GIT_REF AND DEFINED P_GIT_TAG)
    string(FIND ${P_GIT_REF} "/" slash) # strip off "origin/" from REF
    if(NOT ${slash} EQUAL -1)
      math(EXPR loc "${slash} + 1")
      string(SUBSTRING ${P_GIT_REF} ${loc} -1 P_GIT_REF)
    endif()
    set(diff "[diff](${P_DIFF}${P_GIT_REF}...${P_GIT_TAG} 'patch/diff')")
  elseif(DEFINED P_PATCH)
    file(RELATIVE_PATH relpath ${PRO_DIR} ${P_PATCH})
    set(diff "[patch](${relpath} 'patch')")
  else()
    set(diff "none")
  endif()
  if(DEFINED P_SUPERPRO)
    if(NOT EXISTS ${g_READMEsub})
      file(WRITE ${g_READMEsub}
        "\n## subprojects\n\n"
        "|project|sub|description|version|repository|patch/diff|\n"
        "|-------|---|-----------|-------|----------|----------|\n"
        )
    endif()
    file(APPEND ${g_READMEsub} "|${P_SUPERPRO}|${web}|${desc}|${ver}|${repo}|${diff}|\n")
  elseif(NOT P_NO_README)
    file(APPEND ${g_README} "|${web}|${lic}|${desc}|${ver}|${repo}|${diff}|\n")
  endif()
  if(P_GRAPH)
    if(NOT EXISTS ${g_READMEdep})
      file(WRITE ${g_READMEdep}
        "digraph GG {\n"
        "  node [fontsize=12];\n"
        )
    endif()
    if(NOT DEFINED P_GRAPH_NODE)
      set(P_GRAPH_NODE ${P_NAME})
    endif()
    ipSanitizeGraph(P_GRAPH_NODE)
    file(APPEND ${g_READMEdep} "  ${P_GRAPH_NODE} [")
    if(DEFINED P_GRAPH_LABEL)
      file(APPEND ${g_READMEdep} "label=\"${P_GRAPH_LABEL}\" ")
    endif()
    if(DEFINED P_GRAPH_SHAPE)
      file(APPEND ${g_READMEdep} "shape=${P_GRAPH_SHAPE}];\n")
    else()
      file(APPEND ${g_READMEdep} "shape=diamond];\n")
    endif()
    if(DEFINED P_BUILD_DEPS)
      foreach(dep ${P_BUILD_DEPS})
        ipSanitizeGraph(dep)
        file(APPEND ${g_READMEdep} "  ${P_GRAPH_NODE} -> ${dep};\n")
      endforeach()
    endif()
  endif()
endfunction()

function(ipSanitizeGraph node)
  string(REGEX REPLACE "([.-]+)" "_" sanitized ${${node}})
  if(NOT sanitized STREQUAL ${${node}})
    set(P_GRAPH_LABEL ${${node}} PARENT_SCOPE)
    set(${node} ${sanitized} PARENT_SCOPE)
  endif()
endfunction()

function(xpMarkdownReadmeFinalize)
  if(EXISTS ${g_READMEsub})
    file(READ ${g_READMEsub} sub)
    file(APPEND ${g_README} ${sub})
    file(REMOVE ${g_READMEsub})
  endif()
  if(EXISTS ${g_READMEdep})
    file(APPEND ${g_READMEdep} "}\n")
    configure_file(${g_READMEdep} ${g_READMEdep}.txt NEWLINE_STYLE LF)
    file(MD5 ${g_READMEdep}.txt hash)
    file(READ ${g_READMEdep}.txt depsDotDot)
    file(REMOVE ${g_READMEdep} ${g_READMEdep}.txt)
    set(user smanders)
    set(branch dev)
    set(mark depgraph_${hash})
    set(url "https://raw.githubusercontent.com/${user}/externpro/${branch}/projects/README.md")
    string(REPLACE "/" "%2F" url ${url})
    string(REPLACE ":" "%3A" url ${url})
    file(APPEND ${g_README}
      "\n## dependency graph\n\n"
      "![deps.dot graph](https://g.gravizo.com/source/${mark}?${url})\n"
      "<details>\n"
      "<summary></summary>\n"
      "${mark}\n"
      )
    file(APPEND ${g_README}
      "${depsDotDot}"
      "${mark}\n"
      "</details>\n"
      )
  endif()
  configure_file(${g_README} ${PRO_DIR}/README.md NEWLINE_STYLE LF)
endfunction()

function(xpGetCompilerPrefix _ret)
  set(options GCC_TWO_VER)
  cmake_parse_arguments(X "${options}" "" "" ${ARGN})
  if(MSVC)
    set(prefix vc${MSVC_TOOLSET_VERSION})
  elseif((CMAKE_CXX_COMPILER_ID STREQUAL GNU) OR (CMAKE_C_COMPILER_ID STREQUAL GNU))
    if(X_GCC_TWO_VER)
      set(digits "\\1\\2")
    else()
      set(digits "\\1\\2\\3")
    endif()
    if(DEFINED CMAKE_CXX_COMPILER_VERSION)
      set(compilerVersion ${CMAKE_CXX_COMPILER_VERSION})
    elseif(DEFINED CMAKE_C_COMPILER_VERSION)
      set(compilerVersion ${CMAKE_C_COMPILER_VERSION})
    else()
      message(SEND_ERROR "xpfunmac.cmake: unknown CMAKE_<LANG>_COMPILER_VERSION")
    endif()
    string(REGEX REPLACE "([0-9]+)\\.([0-9]+)\\.([0-9]+)?"
      "gcc${digits}"
      prefix ${compilerVersion}
      )
  elseif(${CMAKE_CXX_COMPILER_ID} MATCHES "Clang") # LLVM/Apple Clang (clang.llvm.org)
    if(${CMAKE_SYSTEM_NAME} STREQUAL Darwin)
      execute_process(COMMAND ${CMAKE_CXX_COMPILER} ${CMAKE_CXX_COMPILER_ARG1} -dumpversion
        OUTPUT_VARIABLE CLANG_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )
      string(REGEX REPLACE "([0-9]+)\\.([0-9]+)(\\.[0-9]+)?"
        "clang-darwin\\1\\2" # match boost naming
        prefix ${CLANG_VERSION}
        )
    else()
      string(REGEX REPLACE "([0-9]+)\\.([0-9]+)(\\.[0-9]+)?"
        "clang\\1\\2" # match boost naming
        prefix ${CMAKE_CXX_COMPILER_VERSION}
        )
    endif()
  else()
    message(SEND_ERROR "xpfunmac.cmake: compiler support lacking: ${CMAKE_CXX_COMPILER_ID}")
  endif()
  set(${_ret} ${prefix} PARENT_SCOPE)
endfunction()

function(xpGetNumBits _ret)
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(numBits 64)
  elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(numBits 32)
  else()
    message(FATAL_ERROR "numBits not 64 or 32")
  endif()
  set(${_ret} ${numBits} PARENT_SCOPE)
endfunction()

function(xpInstallPro)
  if(NOT EXISTS ${CMAKE_SOURCE_DIR}/.git)
    return()
  endif()
  if(NOT DEFINED BUILD_PLATFORM)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
      set(BUILD_PLATFORM 64)
    elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
      set(BUILD_PLATFORM 32)
    endif()
  endif()
  if(NOT GIT_FOUND)
    include(FindGit)
    find_package(Git)
  endif()
  set(XP_DEFAULT ON) # avoid PARTIAL marker
  set(MODULES_DIR ${moduleDir}) # moduleDir from Findexternpro.cmake
  include(${MODULES_DIR}/macpro.cmake)
  proSetStageDir()
  set(CMAKE_INSTALL_PREFIX ${STAGE_DIR} CACHE PATH
    "Install path prefix, prepended onto install directories." FORCE
    )
  install(FILES ${XP_INFOFILE} DESTINATION .)
  install(FILES ${STAGE_DIR}/share/cmake/Find${CMAKE_PROJECT_NAME}.cmake DESTINATION share/cmake)
  include(CPack)
endfunction()

function(xpListAppendTrailingSlash var)
  set(listVar)
  foreach(f ${ARGN})
    if(IS_DIRECTORY ${f})
      list(APPEND listVar "${f}/")
    else()
      list(APPEND listVar "${f}")
    endif()
  endforeach()
  set(${var} "${listVar}" PARENT_SCOPE)
endfunction()

function(xpListRemoveFromAll var match replace)
  set(listVar)
  foreach(f ${ARGN})
    string(REPLACE "${match}" "${replace}" f ${f})
    list(APPEND listVar ${f})
  endforeach()
  set(${var} "${listVar}" PARENT_SCOPE)
endfunction()

function(xpListAppendIfDne appendTo items)
  foreach(item ${items} ${ARGN})
    list(FIND ${appendTo} ${item} index)
    if(index EQUAL -1)
      list(APPEND ${appendTo} ${item})
    endif()
  endforeach()
  set(${appendTo} ${${appendTo}} PARENT_SCOPE)
endfunction()

function(xpListRemoveIfExists removeFrom items)
  foreach(item ${items})
    list(FIND ${removeFrom} ${item} index)
    if(NOT index EQUAL -1)
      list(REMOVE_AT ${removeFrom} ${index})
    endif()
  endforeach()
  set(${removeFrom} ${${removeFrom}} PARENT_SCOPE)
endfunction()

function(xpStringTrim str)
  if("${${str}}" STREQUAL "")
    return()
  endif()
  # remove leading and trailing spaces with STRIP
  string(STRIP ${${str}} stripped)
  set(${str} ${stripped} PARENT_SCOPE)
endfunction()

function(xpStringAppend appendTo str)
  if("${${appendTo}}" STREQUAL "")
    set(${appendTo} ${str} PARENT_SCOPE)
  else()
    set(${appendTo} "${${appendTo}} ${str}" PARENT_SCOPE)
  endif()
endfunction()

function(xpStringAppendIfDne appendTo str)
  if("${${appendTo}}" STREQUAL "")
    set(${appendTo} ${str} PARENT_SCOPE)
  else()
    string(FIND ${${appendTo}} ${str} pos)
    if(${pos} EQUAL -1)
      set(${appendTo} "${${appendTo}} ${str}" PARENT_SCOPE)
    endif()
  endif()
endfunction()

function(xpStringRemoveIfExists removeFrom str)
  if("${${removeFrom}}" STREQUAL "")
    return()
  endif()
  string(FIND ${${removeFrom}} ${str} pos)
  if(${pos} EQUAL -1)
    return()
  endif()
  string(REPLACE " ${str}" "" res ${${removeFrom}})
  string(REPLACE "${str} " "" res ${${removeFrom}})
  string(REPLACE ${str} "" res ${${removeFrom}})
  xpStringTrim(res)
  set(${removeFrom} ${res} PARENT_SCOPE)
endfunction()

function(xpGetConfigureFlags cpprefix _ret)
  include(${MODULES_DIR}/flags.cmake) # populates CMAKE_*_FLAGS
  if(XP_BUILD_VERBOSE AND XP_FLAGS_VERBOSE)
    message(STATUS "  CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
    message(STATUS "  CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}")
    message(STATUS "  CMAKE_EXE_LINKER_FLAGS: ${CMAKE_EXE_LINKER_FLAGS}")
  endif()
  if(${ARGC} EQUAL 3 AND ARGV2)
    foreach(it ${ARGV2})
      xpStringRemoveIfExists(CMAKE_CXX_FLAGS "${it}")
      xpStringRemoveIfExists(CMAKE_C_FLAGS "${it}")
      xpStringRemoveIfExists(CMAKE_EXE_LINKER_FLAGS "${it}")
    endforeach()
  endif()
  set(CFG_FLAGS)
  if(NOT "${CMAKE_CXX_FLAGS}" STREQUAL "" AND NOT ${cpprefix} STREQUAL "NONE")
    list(APPEND CFG_FLAGS "${cpprefix}FLAGS=${CMAKE_CXX_FLAGS}")
    if(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
      list(APPEND CFG_FLAGS "OBJCXXFLAGS=${CMAKE_CXX_FLAGS}")
    endif()
  endif()
  if(NOT "${CMAKE_C_FLAGS}" STREQUAL "")
    list(APPEND CFG_FLAGS "CFLAGS=${CMAKE_C_FLAGS}")
    if(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
      list(APPEND CFG_FLAGS "OBJCFLAGS=${CMAKE_C_FLAGS}")
    endif()
  endif()
  if(NOT "${CMAKE_EXE_LINKER_FLAGS}" STREQUAL "" AND NOT "${CMAKE_EXE_LINKER_FLAGS}" STREQUAL " ")
    list(APPEND CFG_FLAGS "LDFLAGS=${CMAKE_EXE_LINKER_FLAGS}")
  endif()
  set(${_ret} ${CFG_FLAGS} PARENT_SCOPE)
endfunction()

function(xpGitIgnoredDirs var dir)
  if(NOT GIT_FOUND)
    include(FindGit)
    find_package(Git)
  endif()
  execute_process(
    COMMAND ${GIT_EXECUTABLE} ls-files --exclude-standard --ignored --others --directory
    WORKING_DIRECTORY ${dir}
    ERROR_QUIET
    OUTPUT_VARIABLE ignoredDirs
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  string(REPLACE ";" "\\\\;" ignoredDirs "${ignoredDirs}")
  string(REPLACE "\n" ";" ignoredDirs "${ignoredDirs}")
  list(APPEND ignoredDirs ${ARGN})
  list(TRANSFORM ignoredDirs PREPEND ${dir}/)
  set(${var} "${ignoredDirs}" PARENT_SCOPE)
endfunction()

function(xpGitIgnoredFiles var dir)
  if(NOT GIT_FOUND)
    include(FindGit)
    find_package(Git)
  endif()
  execute_process(
    COMMAND ${GIT_EXECUTABLE} ls-files --exclude-standard --ignored --others
    WORKING_DIRECTORY ${dir}
    ERROR_QUIET
    OUTPUT_VARIABLE ignoredFiles
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  string(REPLACE ";" "\\\\;" ignoredFiles "${ignoredFiles}")
  string(REPLACE "\n" ";" ignoredFiles "${ignoredFiles}")
  list(TRANSFORM ignoredFiles PREPEND ${dir}/)
  set(${var} "${ignoredFiles}" PARENT_SCOPE)
endfunction()

function(xpGitUntrackedFiles var dir)
  if(NOT GIT_FOUND)
    include(FindGit)
    find_package(Git)
  endif()
  execute_process(
    COMMAND ${GIT_EXECUTABLE} ls-files --exclude-standard --others
    WORKING_DIRECTORY ${dir}
    ERROR_QUIET
    OUTPUT_VARIABLE untrackedFiles
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  string(REPLACE ";" "\\\\;" untrackedFiles "${untrackedFiles}")
  string(REPLACE "\n" ";" untrackedFiles "${untrackedFiles}")
  list(TRANSFORM untrackedFiles PREPEND ${dir}/)
  set(${var} "${untrackedFiles}" PARENT_SCOPE)
endfunction()

function(xpGlobFiles var item)
  set(globexpr ${ARGN})
  if(IS_DIRECTORY ${item})
    string(REGEX REPLACE "/$" "" item ${item}) # remove trailing slash
    list(TRANSFORM globexpr PREPEND ${item}/)
    # NOTE: By default GLOB_RECURSE omits directories from result list
    file(GLOB_RECURSE dirFiles ${globexpr})
    xpGitUntrackedFiles(untrackedFiles ${item})
    xpGitIgnoredFiles(ignoredFiles ${item})
    list(APPEND untrackedFiles ${ignoredFiles})
    if(dirFiles AND untrackedFiles)
      list(REMOVE_ITEM dirFiles ${untrackedFiles})
    endif()
    list(APPEND listVar ${dirFiles})
  else()
    get_filename_component(dir ${item} DIRECTORY)
    list(TRANSFORM globexpr PREPEND ${dir}/)
    file(GLOB match ${globexpr})
    list(FIND match ${item} idx)
    if(NOT ${idx} EQUAL -1)
      list(APPEND listVar ${item})
    endif()
  endif()
  set(${var} ${${var}} ${listVar} PARENT_SCOPE)
endfunction()

function(ipParseDir dir group)
  file(GLOB items LIST_DIRECTORIES true RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${dir}/*)
  list(SORT items)
  set(files)
  if(group)
    set(group "${group}\\\\")
  endif()
  foreach(item ${items})
    if(IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${item})
      get_filename_component(dirName ${item} NAME)
      ipParseDir(${item} "${group}${dirName}")
    else()
      list(APPEND files ${item})
    endif()
  endforeach()
  if(files)
    source_group("${group}" FILES ${files})
    list(APPEND ${projectName}_srcs ${files})
  endif()
  set(${projectName}_srcs ${${projectName}_srcs} PARENT_SCOPE)
endfunction()

function(xpAddSubdirectoryProject dir)
  cmake_parse_arguments(P "" "PROJECT_NAME" "" ${ARGN})
  if(DEFINED P_PROJECT_NAME)
    set(projectName ${P_PROJECT_NAME})
  else()
    get_filename_component(projectName ${dir} NAME)
  endif()
  ipParseDir(${dir} "")
  add_custom_target(${projectName} SOURCES ${${projectName}_srcs}) # creates utility project in MSVC
  set_property(TARGET ${projectName} PROPERTY FOLDER ${folder})
  xpSourceListAppend(${${projectName}_srcs})
endfunction()

macro(xpSourceListAppend)
  set(_dir ${CMAKE_CURRENT_SOURCE_DIR})
  if(EXISTS ${_dir}/CMakeLists.txt)
    list(APPEND masterSrcList ${_dir}/CMakeLists.txt)
  endif()
  if(DEFINED unclassifiedSrcList)
    list(APPEND masterSrcList ${unclassifiedSrcList})
  endif()
  if(${ARGC} GREATER 0)
    foreach(f ${ARGN})
      # remove any relative parts with get_filename_component call
      # as this will help REMOVE_DUPLICATES
      if(IS_ABSOLUTE ${f})
        get_filename_component(f ${f} ABSOLUTE)
      else()
        get_filename_component(f ${_dir}/${f} ABSOLUTE)
      endif()
      list(APPEND masterSrcList ${f})
    endforeach()
  endif()
  file(GLOB miscFiles LIST_DIRECTORIES false
    ${_dir}/.git*
    ${_dir}/*clang-format
    ${_dir}/*.json
    ${_dir}/.*rc
    ${_dir}/*.md
    )
  if(miscFiles)
    list(APPEND masterSrcList ${miscFiles})
    file(GLOB composeFiles ${_dir}/docker-compose.*)
    if(composeFiles)
      list(APPEND masterSrcList ${composeFiles})
      foreach(f ${composeFiles})
        if(NOT EXISTS ${f}) # remove what dne
          list(REMOVE_ITEM composeFiles ${f})
        endif()
      endforeach()
    endif()
    file(RELATIVE_PATH relPath ${CMAKE_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR})
    string(REPLACE "/" "" custTgt .CMake${relPath})
    if(NOT TARGET ${custTgt})
      if(EXISTS ${_dir}/.codereview)
        file(GLOB_RECURSE crFiles "${_dir}/.codereview/*")
        source_group(".codereview" FILES ${crFiles})
        list(APPEND masterSrcList ${crFiles})
      endif()
      if(EXISTS ${_dir}/.devcontainer)
        file(GLOB_RECURSE dcFiles "${_dir}/.devcontainer/*")
        source_group(".devcontainer" FILES ${dcFiles})
        list(APPEND masterSrcList ${dcFiles})
      endif()
      if(EXISTS ${_dir}/.github)
        file(GLOB_RECURSE githubFiles "${_dir}/.github/*")
        source_group(".github" FILES ${githubFiles})
        list(APPEND masterSrcList ${githubFiles})
      endif()
      add_custom_target(${custTgt} SOURCES ${miscFiles} ${composeFiles} ${crFiles} ${dcFiles} ${githubFiles})
      set_property(TARGET ${custTgt} PROPERTY FOLDER ${folder})
    endif()
  endif()
  if(NOT ${CMAKE_BINARY_DIR} STREQUAL ${CMAKE_CURRENT_BINARY_DIR})
    set(masterSrcList "${masterSrcList}" PARENT_SCOPE)
    set(XP_SOURCE_DIR_IGNORE ${XP_SOURCE_DIR_IGNORE} PARENT_SCOPE)
  else()
    list(REMOVE_DUPLICATES masterSrcList)
    if(EXISTS ${CMAKE_SOURCE_DIR}/.git)
      if(NOT GIT_FOUND)
        include(FindGit)
        find_package(Git)
      endif()
      xpGitIgnoredDirs(ignoredDirs ${CMAKE_SOURCE_DIR} .git/)
      xpGitUntrackedFiles(untrackedFiles ${CMAKE_SOURCE_DIR})
      file(GLOB topdir ${_dir}/*)
      xpListAppendTrailingSlash(topdir ${topdir})
      list(REMOVE_ITEM topdir ${ignoredDirs} ${untrackedFiles})
      list(SORT topdir) # sort list in-place alphabetically
      foreach(item ${topdir})
        xpGlobFiles(repoFiles ${item} *)
      endforeach()
      foreach(item ${XP_SOURCE_DIR_IGNORE})
        xpGlobFiles(ignoreFiles ${item} *)
      endforeach()
      list(REMOVE_ITEM repoFiles ${masterSrcList} ${ignoreFiles})
      if(DEFINED NV_CMAKE_REPO_INSYNC)
        option(XP_CMAKE_REPO_INSYNC "cmake error if repo and cmake are not in sync" ${NV_CMAKE_REPO_INSYNC})
      else()
        option(XP_CMAKE_REPO_INSYNC "cmake error if repo and cmake are not in sync" OFF)
      endif()
      mark_as_advanced(XP_CMAKE_REPO_INSYNC)
      if(repoFiles)
        string(REPLACE ";" "\n" repoFilesTxt "${repoFiles}")
        file(WRITE ${CMAKE_BINARY_DIR}/notincmake.txt ${repoFilesTxt}\n)
        list(APPEND masterSrcList ${CMAKE_BINARY_DIR}/notincmake.txt)
        if(XP_CMAKE_REPO_INSYNC)
          message("")
          message(STATUS "***** FILE(S) IN REPO, BUT NOT IN CMAKE *****")
          foreach(abs ${repoFiles})
            string(REPLACE ${CMAKE_SOURCE_DIR}/ "" rel ${abs})
            message(STATUS ${rel})
          endforeach()
          message("")
          message(FATAL_ERROR "repo and cmake are out of sync, see file(s) listed above. "
            "See also \"${CMAKE_BINARY_DIR}/notincmake.txt\"."
            )
        endif()
      elseif(EXISTS ${CMAKE_BINARY_DIR}/notincmake.txt)
        file(REMOVE ${CMAKE_BINARY_DIR}/notincmake.txt)
      endif()
    endif() # is a .git repo
    find_program(XP_DOT_EXE "dot")
    mark_as_advanced(XP_DOT_EXE)
    if(XP_DOT_EXE)
      option(XP_GRAPHVIZ "create a \${CMAKE_BINARY_DIR}/CMakeGraphVizOptions.cmake file" ON)
      mark_as_advanced(XP_GRAPHVIZ)
      if(NOT DEFINED XP_GRAPHVIZ_PRIVATE_DEPS)
        set(NV_GRAPHVIZ_PRIVATE_DEPS ON) # (NV: normal variable)
      else()
        set(NV_GRAPHVIZ_PRIVATE_DEPS ${XP_GRAPHVIZ_PRIVATE_DEPS})
        unset(XP_GRAPHVIZ_PRIVATE_DEPS)
      endif()
      cmake_dependent_option(XP_GRAPHVIZ_PRIVATE_DEPS
        "keep private dependencies in graph" ${NV_GRAPHVIZ_PRIVATE_DEPS}
        "XP_GRAPHVIZ" ON
        )
      mark_as_advanced(XP_GRAPHVIZ_PRIVATE_DEPS)
      if(XP_GRAPHVIZ)
        if(NOT XP_GRAPHVIZ_PRIVATE_DEPS)
          configure_file(${xpThisDir}/graphPvtClean.sh.in graphPvtClean.sh
            @ONLY NEWLINE_STYLE LF
            )
          set(graphPvtClean COMMAND ./graphPvtClean.sh)
        endif()
        if(NOT TARGET graph)
          add_custom_command(OUTPUT graph_cmake
            COMMAND ${CMAKE_COMMAND} --graphviz=${CMAKE_PROJECT_NAME}.dot .
            ${graphPvtClean}
            COMMAND dot -Tpng -o${CMAKE_PROJECT_NAME}.png ${CMAKE_PROJECT_NAME}.dot
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            COMMENT "Generating ${CMAKE_PROJECT_NAME}.dot and ${CMAKE_PROJECT_NAME}.png..."
            )
          add_custom_target(graph SOURCES ${CMAKE_BINARY_DIR}/CMakeGraphVizOptions.cmake DEPENDS graph_cmake)
          set_property(TARGET graph PROPERTY FOLDER CMakeTargets)
        endif()
        set(opts "# Generating Dependency Graphs with CMake\n")
        set(opts "${opts}# https://gitlab.kitware.com/cmake/community/-/wikis/doc/cmake/Graphviz\n")
        set(opts "${opts}# https://cmake.org/cmake/help/latest/module/CMakeGraphVizOptions.html\n")
        set(opts "${opts}# cmake --graphviz=${CMAKE_PROJECT_NAME}.dot ..\n")
        set(opts "${opts}# dot -Tpng -o${CMAKE_PROJECT_NAME}.png ${CMAKE_PROJECT_NAME}.dot\n")
        foreach(stringOpt GRAPH_NAME GRAPH_HEADER NODE_PREFIX IGNORE_TARGETS)
          if(DEFINED GRAPHVIZ_${stringOpt})
            set(opts "${opts}set(GRAPHVIZ_${stringOpt}")
            foreach(str ${GRAPHVIZ_${stringOpt}})
              set(opts "${opts} \"${str}\"")
            endforeach()
            set(opts "${opts})\n")
          endif()
        endforeach()
        foreach(boolOpt EXECUTABLES STATIC_LIBS SHARED_LIBS MODULE_LIBS INTERFACE_LIBS OBJECT_LIBS UNKNOWN_LIBS
                        EXTERNAL_LIBS CUSTOM_TARGETS GENERATE_PER_TARGET GENERATE_DEPENDERS
          )
          if(DEFINED GRAPHVIZ_${boolOpt})
            set(opts "${opts}set(GRAPHVIZ_${boolOpt} ${GRAPHVIZ_${boolOpt}})\n")
          endif()
        endforeach()
        file(WRITE ${CMAKE_BINARY_DIR}/CMakeGraphVizOptions.cmake ${opts})
      endif() # XP_GRAPHVIZ
    endif() # XP_DOT_EXE
  endif()
endmacro()

function(xpSourceDirIgnore)
  set(ignoredDirs ${ARGN})
  list(TRANSFORM ignoredDirs PREPEND ${CMAKE_CURRENT_SOURCE_DIR}/)
  list(APPEND XP_SOURCE_DIR_IGNORE ${ignoredDirs})
  set(XP_SOURCE_DIR_IGNORE ${XP_SOURCE_DIR_IGNORE} PARENT_SCOPE)
endfunction()

function(xpTouchFiles fileList)
  option(XP_TOUCH_FILES "touch files with known warnings" OFF)
  if(NOT XP_TOUCH_FILES)
    return()
  endif()
  foreach(f ${fileList})
    execute_process(COMMAND ${CMAKE_COMMAND} -E touch_nocreate ${f}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      )
  endforeach()
endfunction()

function(xpCheckInstall cmakeProjectName)
  set(findFile ${moduleDir}/Find${cmakeProjectName}.cmake)
  execute_process(COMMAND ${CMAKE_COMMAND} -E compare_files ${CMAKE_CURRENT_LIST_FILE} ${findFile}
    RESULT_VARIABLE filesDiff
    OUTPUT_QUIET
    ERROR_QUIET
    )
  if(filesDiff)
    message(AUTHOR_WARNING "Find scripts don't match. "
      "You may want to update the local with the ${cmakeProjectName} version. "
      "local: ${CMAKE_CURRENT_LIST_FILE}. "
      "${cmakeProjectName}: ${findFile}."
      )
  endif()
  file(GLOB txtFiles ${${cmakeProjectName}_DIR}/${cmakeProjectName}_*.txt)
  list(GET txtFiles 0 infoFile)
  execute_process(COMMAND lsb_release --description
    OUTPUT_VARIABLE lsbDesc # LSB (Linux Standard Base)
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
    )
  if(NOT lsbDesc STREQUAL "")
    set(lsbString "^lsb_release Description:[ \t]+(.*)")
    file(STRINGS ${infoFile} LSB REGEX "${lsbString}")
    string(REGEX REPLACE "${lsbString}" "\\1" xpLSB ${LSB})
    string(REGEX REPLACE "Description:[ \t]+(.*)" "\\1" thisLSB ${lsbDesc})
    if(NOT xpLSB STREQUAL thisLSB)
      message(AUTHOR_WARNING "linux distribution mismatch: "
        "${cmakeProjectName} built on \"${xpLSB}\", "
        "building ${PROJECT_NAME} on \"${thisLSB}\"."
        )
    endif()
  endif()
  if(DEFINED MSVC_VERSION)
    set(msvcString "^MSVC_VERSION[ \t]+(.*)")
    file(STRINGS ${infoFile} MSVC_VER REGEX "${msvcString}")
    string(REGEX REPLACE "${msvcString}" "\\1" xpMsvcVer ${MSVC_VER})
    if(NOT MSVC_VERSION EQUAL xpMsvcVer)
      message(AUTHOR_WARNING "MSVC_VERSION mismatch: "
        "${cmakeProjectName} built on \"${xpMsvcVer}\", "
        "building ${PROJECT_NAME} on \"${MSVC_VERSION}\"."
        )
    endif()
  endif()
endfunction()

function(ipGetPrefixPath pfx pth)
  if(DEFINED ENV{XPX})
    set(SYS_NAME $ENV{XPX})
  elseif(CPack_CMake_INCLUDED EQUAL 1)
    set(SYS_NAME ${CPACK_SYSTEM_NAME})
  elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
      set(SYS_NAME win64)
    else()
      set(SYS_NAME win32)
    endif()
  else()
    set(SYS_NAME ${CMAKE_SYSTEM_NAME})
  endif()
  set(options XP_MODULE)
  set(oneValueArgs PKG BASE BRANCH DESC DIST_DIR LICENSE REPO TAG UPSTREAM VER WEB SHA256_JetPack SHA256_Linux SHA256_win64 URL_JetPack URL_Linux URL_win64 SHA256_utres)
  set(multiValueArgs DEPS EXE_DEPS)
  cmake_parse_arguments(P "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  if(P_XP_MODULE)
    set(pfx usexp)
    set(pth ${XP_MODULE_PATH})
  elseif(DEFINED P_DIST_DIR)
    set(pfx xpuse)
    set(pth ${P_DIST_DIR}/share/cmake)
  elseif(DEFINED P_URL_${SYS_NAME} AND DEFINED P_SHA256_${SYS_NAME})
    set(url ${P_URL_${SYS_NAME}})
    set(sha ${P_SHA256_${SYS_NAME}})
  elseif(DEFINED P_REPO AND DEFINED P_TAG AND DEFINED P_SHA256_${SYS_NAME})
    string(REGEX REPLACE ".*/" "" PKG_NAME ${P_REPO})
    set(url https://${P_REPO}/releases/download/${P_TAG}/${PKG_NAME}-${P_TAG}-${SYS_NAME}-devel.tar.xz)
    set(sha ${P_SHA256_${SYS_NAME}})
  elseif(DEFINED P_PKG)
    message(FATAL_ERROR "ipFindPkg: error in xp_${P_PKG}")
  else()
    message(FATAL_ERROR "ipFindPkg: unexpected error")
  endif()
  if(DEFINED url AND DEFINED sha)
    get_filename_component(txz ${url} NAME)
    string(REPLACE "-devel.tar.xz" "" pkgdir ${txz})
    set(fcName xp_${P_PKG})
    include(FetchContent)
    cmake_policy(SET CMP0168 OLD)
    # DOWNLOAD_NO_EXTRACT because extractfile discards a single top level directory
    # https://discourse.cmake.org/t/how-to-tell-fetchcontent-to-keep-archive-directory-structure/8012
    FetchContent_Declare(${fcName} URL ${url} URL_HASH SHA256=${sha} DOWNLOAD_NO_EXTRACT TRUE)
    FetchContent_MakeAvailable(${fcName})
    # Only extract the package if it hasn't been extracted before
    # This approach requires that a developer doesn't modify anything in the
    # FETCHCONTENT_BASE_DIR (default: `_deps`) of the build directory
    if(${${fcName}_SOURCE_DIR}/${txz} IS_NEWER_THAN ${FETCHCONTENT_BASE_DIR})
      file(ARCHIVE_EXTRACT INPUT ${${fcName}_SOURCE_DIR}/${txz} DESTINATION ${FETCHCONTENT_BASE_DIR})
      file(TOUCH_NOCREATE ${FETCHCONTENT_BASE_DIR})
      string(TOUPPER ${fcName} fcName)
      mark_as_advanced(FETCHCONTENT_SOURCE_DIR_${fcName} FETCHCONTENT_UPDATES_DISCONNECTED_${fcName})
    endif()
    set(pfx xpuse)
    set(pth ${FETCHCONTENT_BASE_DIR}/${pkgdir}/share/cmake)
  endif()
  set(pfx ${pfx} PARENT_SCOPE)
  set(pth ${pth} PARENT_SCOPE)
endfunction()

function(xpFindPkg)
  cmake_parse_arguments(FP "" "" PKGS ${ARGN})
  foreach(pkg ${FP_PKGS})
    string(TOUPPER ${pkg} PKG)
    string(TOLOWER ${pkg} pkg)
    if(DEFINED xp_${pkg})
      ipGetPrefixPath(pfx pth PKG ${pkg} ${xp_${pkg}})
    else()
      set(pfx usexp)
      set(pth ${XP_MODULE_PATH})
    endif()
    unset(${pfx}-${pkg}_DIR CACHE)
    find_package(${pfx}-${pkg} REQUIRED PATHS ${pth} NO_DEFAULT_PATH)
    mark_as_advanced(${pfx}-${pkg}_DIR)
    if(DEFINED ${PKG}_FOUND)
      list(APPEND reqVars ${PKG}_FOUND)
    else()
      message(AUTHOR_WARNING "${pkg}: no ${PKG}_FOUND defined")
    endif()
    foreach(var ${reqVars})
      set(${var} ${${var}} PARENT_SCOPE)
    endforeach()
  endforeach()
endfunction()

function(xpGetPkgVar pkg)
  xpFindPkg(PKGS ${pkg})
  string(TOUPPER ${pkg} PKG)
  if(${PKG}_FOUND)
    foreach(var ${ARGN})
      string(TOUPPER ${var} VAR)
      if(DEFINED ${PKG}_${VAR})
        set(${PKG}_${VAR} ${${PKG}_${VAR}} PARENT_SCOPE)
        set(${pkg}_${VAR} ${${PKG}_${VAR}} PARENT_SCOPE)
      elseif(DEFINED ${pkg}_${VAR})
        set(${pkg}_${VAR} ${${pkg}_${VAR}} PARENT_SCOPE)
      elseif(DEFINED ${PKG}_${var})
        set(${PKG}_${var} ${${PKG}_${var}} PARENT_SCOPE)
        set(${pkg}_${var} ${${PKG}_${var}} PARENT_SCOPE)
      elseif(DEFINED ${pkg}_${var})
        set(${pkg}_${var} ${${pkg}_${var}} PARENT_SCOPE)
      endif()
    endforeach()
  endif()
endfunction()

function(ipAppendPkgVars pkg _lib _inc _def)
  string(TOUPPER ${pkg} PKG)
  if(${PKG}_FOUND)
    if(TE_HEADER_ONLY)
      set(${_lib} ${${_lib}} PARENT_SCOPE)
    elseif(DEFINED TE_LIBS)
      set(${_lib} ${${_lib}} "${TE_LIBS}" PARENT_SCOPE)
    elseif(DEFINED ${PKG}_LIBRARIES)
      set(${_lib} ${${_lib}} "${${PKG}_LIBRARIES}" PARENT_SCOPE)
    endif()
    if(DEFINED ${PKG}_INCLUDE_DIR)
      foreach(idir ${${PKG}_INCLUDE_DIR})
        list(APPEND pkginc "$<BUILD_INTERFACE:${idir}>")
      endforeach()
      set(${_inc} ${${_inc}} ${pkginc} PARENT_SCOPE)
    endif()
    if(DEFINED ${PKG}_DEFINITIONS)
      set(${_def} ${${_def}} "${${PKG}_DEFINITIONS}" PARENT_SCOPE)
    endif()
  endif()
endfunction()

# get the external include directories and library list
# given the PUBLIC and PRIVATE packages passed in
function(xpGetExtern _incDirs _libList)
  set(multiValueArgs PUBLIC PRIVATE)
  cmake_parse_arguments(GE "" "" "${multiValueArgs}" ${ARGN})
  xpFindPkg(PKGS ${GE_PUBLIC} ${GE_PRIVATE})
  list(APPEND incdirs SYSTEM)
  if(DEFINED GE_PUBLIC)
    list(APPEND incdirs PUBLIC)
  endif()
  foreach(pkg ${GE_PUBLIC})
    ipAppendPkgVars(${pkg} liblist incdirs deflist)
  endforeach()
  if(DEFINED GE_PRIVATE)
    list(APPEND incdirs PRIVATE)
  endif()
  foreach(pkg ${GE_PRIVATE})
    ipAppendPkgVars(${pkg} liblist incdirs deflist)
  endforeach()
  if(DEFINED incdirs)
    list(REMOVE_DUPLICATES incdirs)
  endif()
  set(${_libList} ${liblist} PARENT_SCOPE)
  set(${_incDirs} ${incdirs} PARENT_SCOPE)
endfunction()

function(xpTargetExtern tgt)
  set(multiValueArgs PUBLIC PRIVATE LIBS)
  cmake_parse_arguments(TE HEADER_ONLY "" "${multiValueArgs}" ${ARGN})
  xpFindPkg(PKGS ${TE_PUBLIC} ${TE_PRIVATE})
  foreach(pkg ${TE_PUBLIC})
    ipAppendPkgVars(${pkg} publib pubinc pubdef)
  endforeach()
  foreach(pub publib pubinc pubdef)
    if(${pub})
      list(REMOVE_DUPLICATES ${pub})
      set(_${pub} PUBLIC ${${pub}})
    endif()
  endforeach()
  foreach(pkg ${TE_PRIVATE})
    ipAppendPkgVars(${pkg} pvtlib pvtinc pvtdef)
  endforeach()
  foreach(pvt pvtlib pvtinc pvtdef)
    if(${pvt})
      list(REMOVE_DUPLICATES ${pvt})
      set(_${pvt} PRIVATE ${${pvt}})
    endif()
  endforeach()
  if(_publib OR _pvtlib)
    if(XP_CMAKE_VERBOSE)
      message(STATUS "${tgt} libs: ${_publib} ${_pvtlib}")
    endif()
    target_link_libraries(${tgt} ${_publib} ${_pvtlib})
  endif()
  if(_pubinc OR _pvtinc)
    if(XP_CMAKE_VERBOSE)
      message(STATUS "${tgt} incs: SYSTEM ${_pubinc} ${_pvtinc}")
    endif()
    # cmakeify off
    target_include_directories(${tgt} SYSTEM ${_pubinc} ${_pvtinc})
    # cmakeify on
  endif()
  if(_pubdef OR _pvtdef)
    if(XP_CMAKE_VERBOSE)
      message(STATUS "${tgt} defs: ${_pubdef} ${_pvtdef}")
    endif()
    target_compile_definitions(${tgt} ${_pubdef} ${_pvtdef})
  endif()
endfunction()

function(xpLibdepTest libName)
  if(MSVC)
    option(XP_GENERATE_LIBDEPS "include library dependency projects" OFF)
  else()
    return()
  endif()
  if(XP_GENERATE_LIBDEPS)
    set(depsName ${libName}Deps)
    set(fileName ${CMAKE_CURRENT_BINARY_DIR}/${libName}Deps.cpp)
    file(WRITE ${fileName}
      "// This target/project and file exist to help verify that all dependencies\n"
      "// are included in ${libName} and that there are no unresolved external symbols.\n"
      "//\n"
      "// Searching the code for 'pragma comment' (with a comment-type of lib) will\n"
      "// turn up a list of libraries passed to the linker (it's an MSVC way to\n"
      "// specify additional libraries to link in).\n"
      )
    source_group("" FILES ${fileName})
    add_library(${depsName} MODULE ${fileName})
    add_dependencies(${depsName} ${libName})
    target_link_libraries(${depsName} ${libName})
    set_property(TARGET ${depsName} PROPERTY FOLDER "${folder}/LibDeps")
  endif()
endfunction()

function(xpVerboseListing label thelist)
  message(STATUS "  ${label}")
  foreach(param ${thelist})
    message(STATUS "  ${param}")
  endforeach()
endfunction()

function(xpGenerateRevision)
  set(oneValueArgs SOURCE_DIR)
  cmake_parse_arguments(P "" "${oneValueArgs}" "" ${ARGN})
  if(NOT DEFINED P_SOURCE_DIR)
    set(P_SOURCE_DIR ${CMAKE_SOURCE_DIR})
  endif()
  set(xpSourceDir ${P_SOURCE_DIR})
  include(${xpThisDir}/revision.cmake)
endfunction()

macro(xpCreateVersionString prefix)
  math(EXPR MAJOR "${${prefix}_VERSION_MAJOR} * 1000000")
  math(EXPR MINOR "${${prefix}_VERSION_MINOR} * 10000")
  math(EXPR PATCH "${${prefix}_VERSION_PATCH} * 100")
  math(EXPR ${prefix}_VERSION_NUM "${MAJOR} + ${MINOR} + ${PATCH} + ${${prefix}_VERSION_TWEAK}")
  set(${prefix}_STR "${${prefix}_VERSION_MAJOR}.${${prefix}_VERSION_MINOR}.${${prefix}_VERSION_PATCH}.${${prefix}_VERSION_TWEAK}")
endmacro()

# cmake-generates Version.hpp, resource.rc, resource.h in ${CMAKE_CURRENT_BINARY_DIR}${versionDir}
function(xpGenerateResources iconPath generatedFiles)
  include(${xpThisDir}/version.cmake)
  string(TIMESTAMP PACKAGE_CURRENT_YEAR %Y)
  # Creates PACKAGE_VERSION_NUM and PACKAGE_STR
  xpCreateVersionString(PACKAGE)
  # Creates FILE_VERSION_NUM and FILE_STR
  xpCreateVersionString(FILE)
  set(ICON_PATH ${iconPath})
  if(NOT DEFINED FILE_DESC)
    if(DEFINED PACKAGE_NAME AND DEFINED exe_name)
      set(FILE_DESC "${PACKAGE_NAME} ${exe_name}")
    elseif(DEFINED PROJECT_NAME AND NOT PACKAGE_NAME STREQUAL PROJECT_NAME)
      set(FILE_DESC "${PACKAGE_NAME} ${PROJECT_NAME}")
    elseif(DEFINED PACKAGE_NAME)
      set(FILE_DESC "${PACKAGE_NAME}")
    endif()
  endif()
  # NOTE: it appears that configure_file is smart enough that only if the input
  # file (or substituted variables) are modified does it re-configure the output
  # file; in other words, running cmake shouldn't cause needless rebuilds because
  # these files shouldn't be touched by cmake unless they need to be...
  configure_file(${xpThisDir}/Version.hpp.in ${CMAKE_CURRENT_BINARY_DIR}${versionDir}/Version.hpp)
  configure_file(${xpThisDir}/resource.rc.in ${CMAKE_CURRENT_BINARY_DIR}${versionDir}/resource.rc)
  configure_file(${xpThisDir}/resource.h.in ${CMAKE_CURRENT_BINARY_DIR}${versionDir}/resource.h)
  set(${generatedFiles}
    ${CMAKE_CURRENT_BINARY_DIR}${versionDir}/resource.h
    ${CMAKE_CURRENT_BINARY_DIR}${versionDir}/resource.rc
    ${CMAKE_CURRENT_BINARY_DIR}${versionDir}/Version.hpp
    PARENT_SCOPE
    )
endfunction()

function(xpVersionLib)
  set(BUILD_TARGET ${ARGV0})
  set(verLib ${BUILD_TARGET}Version)
  set(reqArgs ICON)
  set(oneValueArgs ${reqArgs} FILE_DESC PACKAGE_NAME START_YEAR)
  cmake_parse_arguments(P "" "${oneValueArgs}" "" ${ARGN})
  foreach(arg ${reqArgs})
    if(NOT DEFINED P_${arg})
      message(FATAL_ERROR "xpVersionLib: missing required argument: ${arg}")
    endif()
  endforeach()
  if(NOT IS_ABSOLUTE ${P_ICON} AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${P_ICON})
    get_filename_component(P_ICON ${CMAKE_CURRENT_SOURCE_DIR}/${P_ICON} ABSOLUTE)
  endif()
  if(NOT EXISTS ${P_ICON})
    message(FATAL_ERROR "xpVersionLib: icon does not exist: ${P_ICON}")
  endif()
  if(DEFINED P_FILE_DESC)
    set(FILE_DESC ${P_FILE_DESC})
  endif()
  if(DEFINED P_PACKAGE_NAME)
    set(PACKAGE_NAME ${P_PACKAGE_NAME})
  endif()
  if(DEFINED P_START_YEAR)
    set(PACKAGE_START_YEAR ${P_START_YEAR})
  endif()
  get_filename_component(iconFile ${P_ICON} NAME)
  get_filename_component(iconDir ${P_ICON} DIRECTORY)
  set(versionDir "/VersionLib")
  xpGenerateResources(${iconFile} cmakeGenerated_srcs)
  source_group("" FILES ${cmakeGenerated_srcs})
  add_library(${verLib} INTERFACE ${cmakeGenerated_srcs})
  target_include_directories(${verLib} INTERFACE ${CMAKE_CURRENT_BINARY_DIR}${versionDir} ${iconDir})
  if(DEFINED folder)
    set_property(TARGET ${verLib} PROPERTY FOLDER ${folder})
  endif()
  target_sources(${BUILD_TARGET} PRIVATE ${CMAKE_CURRENT_BINARY_DIR}${versionDir}/resource.rc)
  target_link_libraries(${BUILD_TARGET} PRIVATE ${verLib})
endfunction()

function(xpCreateHeaderResource _output) # .hrc
  xpGetPkgVar(wxInclude EXE) # sets WXINCLUDE_EXE
  foreach(in ${ARGN})
    if(NOT IS_ABSOLUTE ${in})
      get_filename_component(in ${CMAKE_CURRENT_SOURCE_DIR}/${in} ABSOLUTE)
    endif()
    if(EXISTS ${in})
      get_filename_component(of ${in} NAME_WE)
      get_filename_component(nm ${in} NAME)
      get_filename_component(dr ${in} DIRECTORY)
      set(op ${CMAKE_CURRENT_BINARY_DIR}/Resources/${of}.hrc)
      set(options --const --appendtype --wxnone --quiet --respectcase)
      add_custom_command(OUTPUT ${op}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/Resources
        COMMAND $<TARGET_FILE:${WXINCLUDE_EXE}> ${options} --output-file=${op} ${nm}
        WORKING_DIRECTORY ${dr} DEPENDS ${in}
        )
      list(APPEND outList ${op})
    else()
      message(FATAL_ERROR "resource not found: ${in}")
    endif()
  endforeach()
  set(${_output} ${outList} PARENT_SCOPE)
endfunction()

function(xpGitCheckout url hash dir)
  if(NOT GIT_FOUND)
    include(FindGit)
    find_package(Git)
  endif()
  if(NOT GIT_FOUND)
    message(FATAL_ERROR "git not detected")
  endif()
  # if local git repo doesn't yet exist, clone, else fetch
  if(NOT EXISTS ${dir}/.git)
    message(STATUS "Cloning ${url} to ${dir}")
    execute_process(
      COMMAND ${GIT_EXECUTABLE} clone ${url} ${dir}
      ERROR_QUIET
      )
  else()
    message(STATUS "Fetching ${url} in ${dir}")
    execute_process(
      COMMAND ${GIT_EXECUTABLE} fetch --all
      WORKING_DIRECTORY ${dir}
      ERROR_QUIET
      )
  endif()
  # checkout specific hash
  message(STATUS "Checkout hash '${hash}'")
  execute_process(
    COMMAND ${GIT_EXECUTABLE} checkout ${hash}
    WORKING_DIRECTORY ${dir}
    ERROR_QUIET
    RESULT_VARIABLE result
    )
  if(result) # if hash is invalid...
    message(FATAL_ERROR "Failed to checkout: verify hash correct")
  endif()
  # warn developer if git repo is dirty
  execute_process(
    COMMAND ${GIT_EXECUTABLE} status --porcelain
    WORKING_DIRECTORY ${dir}
    ERROR_QUIET
    OUTPUT_VARIABLE dirty
    )
  if(dirty)
    message(AUTHOR_WARNING "git repo @ ${dir} dirty:\n${dirty}")
  endif()
endfunction()

function(xpClassifiedRepo)
  set(options VERBOSE)
  set(oneValueArgs REPO HASH WORKING_TREE PATH_UNIX PATH_MSW PATH_URL)
  cmake_parse_arguments(P "${options}" "${oneValueArgs}" "" ${ARGN})
  if(NOT DEFINED P_REPO OR NOT DEFINED P_HASH OR NOT DEFINED P_WORKING_TREE)
    message(FATAL_ERROR "xpClassifiedRepo: REPO, HASH, and WORKING_TREE must be specified")
  endif()
  if(DEFINED P_PATH_URL)
    set(repoPath https://${P_PATH_URL}/${P_REPO})
    xpGetPkgVar(cURL EXE) # sets CURL_EXE
    if(DEFINED CURL_EXE)
      get_target_property(curlExe ${CURL_EXE} IMPORTED_LOCATION_RELEASE)
      execute_process(
        COMMAND ${curlExe} -k -s -o /dev/null -w "%{http_code}" ${repoPath}
        OUTPUT_VARIABLE statusCode ERROR_QUIET
        )
      if(statusCode EQUAL 200)
        set(repoFound TRUE)
      endif()
    endif()
  elseif(WIN32 OR CYGWIN)
    if(NOT DEFINED P_PATH_MSW)
      message(FATAL_ERROR "xpClassifiedRepo: PATH_URL or PATH_MSW must be specified")
    endif()
    set(repoPath ${P_PATH_MSW}/${P_REPO}.git)
    if(EXISTS ${repoPath} AND IS_DIRECTORY ${repoPath})
      set(repoFound TRUE)
    endif()
  else()
    if(NOT DEFINED P_PATH_UNIX)
      message(FATAL_ERROR "xpClassifiedRepo: PATH_URL or PATH_UNIX must be specified")
    endif()
    set(repoPath ${P_PATH_UNIX}/${P_REPO}.git)
    if(EXISTS ${repoPath} AND IS_DIRECTORY ${repoPath})
      set(repoFound TRUE)
    endif()
  endif()
  if(repoFound)
    if(P_VERBOSE)
      message(STATUS "=====================================================================")
      message(STATUS " Classified repo found. Classified build configuration proceeding... ")
      message(STATUS "=====================================================================")
    endif()
    xpGitCheckout(${repoPath} ${P_HASH} ${P_WORKING_TREE})
    # make XP_CLAS_REPO available to xpClassifiedSrc and xpClassifiedSrcExc via PARENT_SCOPE
    set(XP_CLAS_REPO ${P_WORKING_TREE} PARENT_SCOPE)
  elseif(P_VERBOSE)
    message(STATUS "Unclassified build, repo not accessible: ${repoPath}")
  endif()
endfunction()

function(xpClassifiedSrc srcGroup srcList)
  file(RELATIVE_PATH relPath ${CMAKE_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR})
  foreach(f ${srcList})
    if(DEFINED XP_CLAS_REPO AND EXISTS ${XP_CLAS_REPO}/${relPath}/${f})
      list(APPEND ${srcGroup} ${XP_CLAS_REPO}/${relPath}/${f})
      message(STATUS " CLAS: ${XP_CLAS_REPO}/${relPath}/${f}")
      list(APPEND unclassifiedSrcList ${CMAKE_CURRENT_SOURCE_DIR}/${f})
    else()
      list(APPEND ${srcGroup} ${f})
      if(DEFINED XP_CLAS_REPO AND EXISTS ${XP_CLAS_REPO})
        message(STATUS " UNCLAS: ${CMAKE_CURRENT_SOURCE_DIR}/${f}")
      endif()
    endif()
  endforeach()
  set(${srcGroup} ${${srcGroup}} PARENT_SCOPE)
  set(unclassifiedSrcList ${unclassifiedSrcList} PARENT_SCOPE)
endfunction()

# exclusive: source only in classified repo, no unclassified version
function(xpClassifiedSrcExc srcGroup srcList)
  file(RELATIVE_PATH relPath ${CMAKE_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR})
  if(DEFINED XP_CLAS_REPO AND EXISTS ${XP_CLAS_REPO}/${relPath} AND IS_DIRECTORY ${XP_CLAS_REPO}/${relPath})
    include_directories(${XP_CLAS_REPO}/${relPath})
  endif()
  foreach(f ${srcList})
    if(EXISTS ${XP_CLAS_REPO}/${relPath}/${f})
      list(APPEND ${srcGroup} ${XP_CLAS_REPO}/${relPath}/${f})
      message(STATUS " CLAS_EXCL: ${XP_CLAS_REPO}/${relPath}/${f}")
    elseif(EXISTS ${XP_CLAS_REPO})
      message(STATUS " MISSING: ${XP_CLAS_REPO}/${relPath}/${f}")
    endif()
  endforeach()
  set(${srcGroup} ${${srcGroup}} PARENT_SCOPE)
endfunction()

function(xpPostBuildCopy theTarget copyList toPath)
  if(IS_ABSOLUTE ${toPath}) # absolute toPath
    set(dest ${toPath})
  else() # toPath is relative to target location
    set(dest $<TARGET_FILE_DIR:${theTarget}>/${toPath})
  endif()
  add_custom_command(TARGET ${theTarget} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory ${dest}
    )
  foreach(_item ${copyList})
    # Handle target separately.
    if(TARGET ${_item})
      set(_item $<TARGET_FILE:${_item}>)
    endif()
    if(${_item} STREQUAL optimized)
      if(CMAKE_CONFIGURATION_TYPES)
        set(CONDITION1 IF $(Configuration)==Release)
        set(CONDITION2 IF $(Configuration)==RelWithDebInfo)
      endif()
    elseif(${_item} STREQUAL debug)
      if(CMAKE_CONFIGURATION_TYPES)
        set(CONDITION1 IF $(Configuration)==Debug)
      endif()
    else()
      if(IS_DIRECTORY ${_item})
        get_filename_component(dir ${_item} NAME)
        add_custom_command(TARGET ${theTarget} POST_BUILD
          COMMAND ${CMAKE_COMMAND} -E copy_directory ${_item} ${dest}/${dir}
          )
      else()
        if(NOT IS_ABSOLUTE ${_item})
          if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_item})
            set(_item ${CMAKE_CURRENT_SOURCE_DIR}/${_item})
          elseif(EXISTS ${CMAKE_CURRENT_BINARY_DIR}/${_item})
            set(_item ${CMAKE_CURRENT_BINARY_DIR}/${_item})
          endif()
        endif()
        set(COPY_CMD ${CMAKE_COMMAND} -E copy_if_different ${_item} ${dest})
        if(CONDITION2)
          list(APPEND CONDITION1 "(")
          set(ELSECONDITION ")" ELSE "(" ${CONDITION2} "(" ${COPY_CMD} "))")
          set(CONDITION2)
        else()
          set(ELSECONDITION)
        endif()
        add_custom_command(TARGET ${theTarget} POST_BUILD
          COMMAND ${CONDITION1} ${COPY_CMD} ${ELSECONDITION}
          )
      endif()
      set(CONDITION1)
    endif()
  endforeach()
endfunction()

function(xpPostBuildCopyDllLib theTarget toPath)
  if(IS_ABSOLUTE ${toPath}) # absolute toPath
    set(dest ${toPath})
  else() # toPath is relative to target location
    get_target_property(targetLoc ${theTarget} LOCATION)
    get_filename_component(dest ${targetLoc} DIRECTORY)
    set(dest ${dest}/${toPath})
  endif()
  if(NOT EXISTS ${dest})
    add_custom_command(TARGET ${theTarget} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E make_directory ${dest}
      )
  endif()
  add_custom_command(TARGET ${theTarget} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
      $<TARGET_FILE:${theTarget}> ${dest}
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
      $<TARGET_LINKER_FILE:${theTarget}> ${dest}
    )
endfunction()

macro(xpPackageDevel)
  set(oneValueArgs EXE EXE_PATH TARGETS_FILE)
  set(multiValueArgs DEPS LIBRARIES)
  cmake_parse_arguments(P "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  set(CMAKE_INSTALL_DEFAULT_COMPONENT_NAME devel)
  set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
  list(APPEND CPACK_COMPONENTS_ALL devel)
  set(gitDescribe ${CMAKE_PROJECT_VERSION})
  if(EXISTS ${CMAKE_SOURCE_DIR}/.git)
    execute_process(COMMAND git describe --tags
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      OUTPUT_VARIABLE gitDescribe
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_VARIABLE gitErr
      )
    execute_process(COMMAND git status --porcelain
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      OUTPUT_VARIABLE dirty
      OUTPUT_STRIP_TRAILING_WHITESPACE
      )
    if(dirty)
      string(REPLACE "\n" ";" dirtyList ${dirty})
      list(LENGTH dirtyList len)
      if(${len} GREATER 1 OR NOT " M CMakePresetsBase.json" IN_LIST dirtyList)
        set(gitDescribe ${gitDescribe}-dr)
      endif()
    endif()
  endif()
  set(CPACK_PACKAGE_VERSION ${gitDescribe})
  set(CPACK_COMPONENT_INCLUDE_TOPLEVEL_DIRECTORY ON)
  unset(CPACK_PACKAGING_INSTALL_PREFIX)
  set(CPACK_GENERATOR TXZ)
  if(DEFINED ENV{XPX})
    set(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}-$ENV{XPX}")
  endif()
  include(CPack)
  string(TOUPPER ${CMAKE_PROJECT_NAME} PRJ)
  string(TOLOWER ${CMAKE_PROJECT_NAME} NAME)
  set(VER ${gitDescribe})
  if(DEFINED P_DEPS)
    list(JOIN P_DEPS " " deps) # list to string with spaces
    set(FIND_DEPS "xpFindPkg(PKGS ${deps}) # dependencies\n")
  endif()
  if(DEFINED P_TARGETS_FILE)
    set(TARGETS_FILE "include(\${CMAKE_CURRENT_LIST_DIR}/${P_TARGETS_FILE}.cmake)\n")
  endif()
  if(DEFINED P_LIBRARIES)
    list(JOIN P_LIBRARIES " " libs) # list to string with spaces
    string(JOIN "\n" LIBS
      "set(${PRJ}_LIBRARIES ${libs})"
      "list(APPEND reqVars ${PRJ}_LIBRARIES)"
      ""
      )
  endif()
  if(DEFINED P_EXE)
    if(DEFINED P_EXE_PATH)
      message(FATAL_ERROR "xpPackageDevel: can only define EXE or EXE_PATH, not both")
    endif()
    string(JOIN "\n" EXE
      "set(${PRJ}_EXE ${P_EXE})"
      "list(APPEND reqVars ${PRJ}_EXE)"
      ""
      )
  elseif(DEFINED P_EXE_PATH)
    string(JOIN "\n" EXE
      "get_filename_component(PKG_ROOTDIR \${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)"
      "get_filename_component(PKG_ROOTDIR \${PKG_ROOTDIR} ABSOLUTE) # remove relative parts"
      "set(${PRJ}_EXE \${PKG_ROOTDIR}/${P_EXE_PATH}${CMAKE_EXECUTABLE_SUFFIX})"
      "list(APPEND reqVars ${PRJ}_EXE)"
      ""
      )
  endif()
  set(xpuseFile ${CMAKE_CURRENT_BINARY_DIR}/xpuse-${NAME}-config.cmake)
  configure_file(${xpThisDir}/xpuse.cmake.in ${xpuseFile} @ONLY NEWLINE_STYLE LF)
  set(xpinfoFile ${CMAKE_CURRENT_BINARY_DIR}/sysinfo.txt)
  file(WRITE ${xpinfoFile} "${CPACK_PACKAGE_VERSION}\n")
  execute_process(COMMAND uname -a
    OUTPUT_VARIABLE uname
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_VARIABLE unameErr
    )
  if(NOT unameErr)
    file(APPEND ${xpinfoFile} "${uname}\n")
  endif()
  execute_process(COMMAND lsb_release --description
    OUTPUT_VARIABLE lsbDesc # LSB (Linux Standard Base)
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
    )
  if(NOT lsbDesc STREQUAL "")
    file(APPEND ${xpinfoFile} "lsb_release ${lsbDesc}\n")
  endif()
  if(DEFINED MSVC_VERSION)
    file(APPEND ${xpinfoFile} "MSVC_VERSION ${MSVC_VERSION}\n")
  endif()
  xpGetCompilerPrefix(compilerPrefix)
  file(APPEND ${xpinfoFile} "COMPILER_PREFIX: ${compilerPrefix}\n")
  install(FILES ${xpinfoFile} ${xpuseFile} DESTINATION ${XP_INSTALL_CMAKEDIR})
endmacro()

function(xpProjectInstall)
  set(options DISABLE_MD5_WARNING)
  set(reqArgs TARGET COMPONENT)
  set(optArgs VER DLORG)
  set(oneValueArgs ${reqArgs} ${optArgs} DLURL DLMD5 DLURL_${CPACK_SYSTEM_NAME} DLMD5_${CPACK_SYSTEM_NAME} DESTINATION)
  cmake_parse_arguments(P "${options}" "${oneValueArgs}" "" ${ARGN})
  foreach(arg ${reqArgs})
    if(NOT DEFINED P_${arg})
      message(FATAL_ERROR "xpProjectInstall: missing required argument: ${arg}")
    endif()
  endforeach()
  if(TARGET ${P_TARGET})
    message(FATAL_ERROR "xpProjectInstall: TARGET ${P_TARGET} exists elsewhere")
  endif()
  if(NOT DEFINED P_DLURL AND DEFINED P_DLURL_${CPACK_SYSTEM_NAME})
    set(P_DLURL ${P_DLURL_${CPACK_SYSTEM_NAME}})
  endif()
  if(NOT DEFINED P_DLURL)
    foreach(arg ${optArgs})
      if(NOT DEFINED P_${arg})
        message(FATAL_ERROR "xpProjectInstall: missing argument: ${arg} -or- DLURL[_${CPACK_SYSTEM_NAME}]")
      endif()
    endforeach()
    set(FILENAME ${P_TARGET}-${P_VER}-${CPACK_SYSTEM_NAME}-${P_COMPONENT})
    if(WIN32)
      set(EXT zip)
    else()
      set(EXT tar.xz)
    endif()
    set(P_DLURL ${P_DLORG}/${P_TARGET}/releases/download/v${P_VER}/${FILENAME}.${EXT})
  endif()
  if(DEFINED P_DLMD5)
    set(checkMd5 URL_MD5 ${P_DLMD5})
  elseif(DEFINED P_DLMD5_${CPACK_SYSTEM_NAME})
    set(checkMd5 URL_MD5 ${P_DLMD5_${CPACK_SYSTEM_NAME}})
  elseif(NOT P_DISABLE_MD5_WARNING)
    message(AUTHOR_WARNING "xpProjectInstall: provide argument DLMD5[_${CPACK_SYSTEM_NAME}] to ensure integrity of download")
  endif()
  include(ExternalProject)
  ExternalProject_Add(${P_TARGET} URL ${P_DLURL} ${checkMd5}
    DOWNLOAD_NO_EXTRACT TRUE
    CONFIGURE_COMMAND "" BUILD_COMMAND "" INSTALL_COMMAND ""
    )
  if(DEFINED folder)
    set_property(TARGET ${P_TARGET} PROPERTY FOLDER ${folder})
  endif()
  ExternalProject_Get_Property(${P_TARGET} DOWNLOADED_FILE)
  ExternalProject_Get_Property(${P_TARGET} SOURCE_DIR)
  ExternalProject_Get_Property(${P_TARGET} STAMP_DIR)
  set(extractScript ${STAMP_DIR}/custom-extract-${P_TARGET}.cmake)
  set(options "") # extract_timestamp/DOWNLOAD_EXTRACT_TIMESTAMP true
  _ep_write_extractfile_script("${extractScript}" "${P_TARGET}" "${DOWNLOADED_FILE}" "${SOURCE_DIR}" "${options}")
  file(READ ${extractScript} customExtract)
  string(REPLACE "NOT n EQUAL 1" "1) #" customExtract ${customExtract})
  file(WRITE ${extractScript} ${customExtract})
  ExternalProject_Add_Step(${P_TARGET} custom-extract
    COMMAND ${CMAKE_COMMAND} -P ${extractScript}
    DEPENDEES download
    )
  if(NOT DEFINED P_DESTINATION)
    set(P_DESTINATION .)
  endif()
  if(P_COMPONENT STREQUAL "none")
    ExternalProject_Add_Step(${P_TARGET} custom-copy
      COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> ${P_DESTINATION}
      COMMENT "Copying extracted directory to ${P_DESTINATION}"
      DEPENDEES custom-extract
      )
  else()
    install(DIRECTORY ${SOURCE_DIR}/ DESTINATION ${P_DESTINATION} USE_SOURCE_PERMISSIONS COMPONENT ${P_COMPONENT})
  endif()
endfunction()

function(xpTestEnv)
  if(XP_SANITIZER STREQUAL "ASAN" AND CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(optional PRELOAD_ASAN)
    # PRELOAD_ASAN: specify this option if running the test results in the error:
    #  ASan runtime does not come first in initial library list; you should either
    #  link runtime to your application or manually preload it with LD_PRELOAD
    set(oneValueArgs TEST_TARGET)
    # TEST_TARGET: the NAME argument used in add_test() call
    set(multiValueArgs LEAK_SUPPRESSIONS)
    # LEAK_SUPPRESSIONS: list of patterns to suppress in leak report
    cmake_parse_arguments(P "${optional}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    if(NOT DEFINED P_TEST_TARGET)
      message(FATAL_ERROR "xpTestEnv: TEST_TARGET must be defined")
    elseif(NOT TEST ${P_TEST_TARGET})
      # TRICKY: this may happen when XP_GENERATE_UNITTESTS is OFF
      if(XP_VERBOSE)
        message(STATUS "xpTestEnv TEST_TARGET ${P_TEST_TARGET} not a TEST")
      endif()
      return()
    endif()
    if(P_PRELOAD_ASAN)
      execute_process(COMMAND ${CMAKE_C_COMPILER} -print-file-name=libasan.so
        ERROR_QUIET OUTPUT_VARIABLE libasanPath OUTPUT_STRIP_TRAILING_WHITESPACE
        )
      if(EXISTS ${libasanPath})
        # libasan.so may be a text file
        execute_process(COMMAND file ${libasanPath}
          ERROR_QUIET OUTPUT_VARIABLE fileType OUTPUT_STRIP_TRAILING_WHITESPACE
          )
        if(XP_VERBOSE)
          message(STATUS "xpTestEnv fileType: ${fileType}")
        endif()
        # https://bugzilla.redhat.com/show_bug.cgi?id=1923196
        if(fileType MATCHES "ASCII text")
          file(STRINGS ${libasanPath} inputLine REGEX ^INPUT)
          # https://stackoverflow.com/a/70153202
          # https://regex101.com/r/POlV37/1
          string(REGEX MATCH "\\(([^()]*)\\)" _ "${inputLine}")
          string(STRIP ${CMAKE_MATCH_1} libasanPath)
        endif()
      endif()
      if(EXISTS ${libasanPath})
        set(env "LD_PRELOAD=${libasanPath}")
      endif()
    endif()
    if(DEFINED P_LEAK_SUPPRESSIONS)
      if(NOT "${env}" STREQUAL "")
        set(env "${env};")
      endif()
      # https://github.com/google/sanitizers/wiki/AddressSanitizerLeakSanitizer#suppressions
      foreach(sup ${P_LEAK_SUPPRESSIONS})
        set(allSups "${allSups}leak:${sup}\n")
      endforeach()
      set(asanSupFile ${CMAKE_CURRENT_BINARY_DIR}/asan_suppressions.txt)
      file(WRITE ${asanSupFile} "${allSups}")
      set(env "${env}LSAN_OPTIONS=suppressions=${asanSupFile}")
    endif()
    if(NOT "${env}" STREQUAL "")
      if(XP_VERBOSE)
        message(STATUS "xpTestEnv ENVIRONMENT: ${env}")
      endif()
      set_property(TEST ${P_TEST_TARGET} PROPERTY ENVIRONMENT "${env}")
    endif()
  endif()
endfunction()

# CPP - Whether or not it has C++
# CSharp - Whether or not it has C#
# JS - Whether or not it has JS/TS
function(xpAddCoverage)
  set(optionArgs CPP CSharp JS)
  cmake_parse_arguments(P "${optionArgs}" "" "" ${ARGN})
  if(NOT P_CPP AND NOT P_CSharp AND NOT P_JS)
    message(FATAL_ERROR "No coverage types passed in")
  endif()
  if(WIN32 OR NOT CMAKE_BUILD_TYPE STREQUAL Debug)
    return()
  endif()
  if(P_CPP)
    find_program(XP_PATH_LCOV lcov)
    if(NOT XP_PATH_LCOV)
      message(WARNING "lcov not found")
    endif()
    find_program(XP_PATH_GENHTML genhtml)
    if(NOT XP_PATH_GENHTML)
      message(WARNING "gcov not found")
    endif()
    add_custom_target(precoveragecpp
      COMMAND ${CMAKE_COMMAND} -E make_directory coveragecpp
      COMMAND ${XP_PATH_LCOV} --directory . --zerocounters
      COMMAND ${XP_PATH_LCOV} --directory . --capture --initial --output-file coveragecpp/${PROJECT_NAME}-base.info
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      )
    list(APPEND precoverage precoveragecpp)
    add_custom_target(postcoveragecpp
      COMMAND ${XP_PATH_LCOV} --directory . --capture --output-file coveragecpp/${PROJECT_NAME}-test.info
      COMMAND ${XP_PATH_LCOV} -a coveragecpp/${PROJECT_NAME}-base.info
        -a coveragecpp/${PROJECT_NAME}-test.info -o coveragecpp/${PROJECT_NAME}.info
      COMMAND ${XP_PATH_LCOV} --remove coveragecpp/${PROJECT_NAME}.info ${XP_COVERAGE_RM} --output-file coveragecpp/${PROJECT_NAME}-cleaned.info
      COMMAND ${XP_PATH_GENHTML} -o coveragecpp coveragecpp/${PROJECT_NAME}-cleaned.info
      COMMAND ${CMAKE_COMMAND} -E remove coveragecpp/${PROJECT_NAME}*.info
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      )
    list(APPEND postcoverage postcoveragecpp)
  endif()
  if(P_CSharp)
    add_custom_target(precoveragecsharp
      COMMAND dotnet tool install dotnet-reportgenerator-globaltool --version 5.1.26 --global || (exit 0)
      COMMAND ${CMAKE_COMMAND} -E rm -rf coveragecsharp/*
      COMMAND ${CMAKE_COMMAND} -E make_directory coveragecsharp
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      )
    list(APPEND precoverage precoveragecsharp)
    add_custom_target(postcoveragecsharp
      COMMAND $ENV{HOME}/.dotnet/tools/reportgenerator -reports:TestResults/**/coverage.cobertura.xml
        -targetdir:${CMAKE_BINARY_DIR}/coveragecsharp -reporttypes:Html ${XP_COVERAGE_RM_CSHARP}
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/coveragecsharp
      )
    list(APPEND postcoverage postcoveragecsharp)
    set(CSHARP_COVERAGE_FLAGS --collect:"XPlat Code Coverage" --results-directory:${CMAKE_BINARY_DIR}/coveragecsharp/TestResults)
    set(CSHARP_COVERAGE_FLAGS ${CSHARP_COVERAGE_FLAGS} PARENT_SCOPE)
  endif()
  if(P_JS)
    add_custom_target(precoveragejs
      COMMAND ${CMAKE_COMMAND} -E rm -rf coveragejs/*
      COMMAND ${CMAKE_COMMAND} -E make_directory coveragejs
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      )
    list(APPEND precoverage precoveragejs)
    if(NOT DEFINED NODEXP_EXE)
      xpGetPkgVar(nodexp EXE)
    endif()
    set(JS_SERVER_COVERAGE_FLAGS ${NODEXP_EXE} node_modules/nyc/bin/nyc.js --include @SRC_DIR@
      --report-dir ${CMAKE_BINARY_DIR}/coveragejs/@BUILD_TARGET@
      --temp-dir ${CMAKE_BINARY_DIR}/coveragejs/@BUILD_TARGET@/.nyc_output
      )
    set(JS_SERVER_COVERAGE_FLAGS ${JS_SERVER_COVERAGE_FLAGS} PARENT_SCOPE)
    set(JS_CLIENT_COVERAGE_FLAGS --code-coverage)
    set(JS_CLIENT_COVERAGE_FLAGS ${JS_CLIENT_COVERAGE_FLAGS} PARENT_SCOPE)
    set(JS_CLIENT_COVERAGE_LOC ${CMAKE_BINARY_DIR}/coveragejs)
    set(JS_CLIENT_COVERAGE_LOC ${JS_CLIENT_COVERAGE_LOC} PARENT_SCOPE)
  endif()
  add_custom_target(precoverageall DEPENDS ${precoverage})
  add_custom_target(postcoverageall DEPENDS ${postcoverage})
  if(NOT DEFINED XP_TEST_CMD)
    set(XP_TEST_CMD make test)
  endif()
  add_custom_target(coverageall
    COMMAND make precoverageall
    COMMAND ${XP_TEST_CMD}
    COMMAND make postcoverageall
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
endfunction()

function(xpEnforceOutOfSourceBuilds)
  # NOTE: could also check for in-source builds with the following:
  #if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  # make sure the user doesn't play dirty with symlinks
  get_filename_component(srcdir "${CMAKE_SOURCE_DIR}" REALPATH)
  # check for polluted source tree and disallow in-source builds
  if(EXISTS ${srcdir}/CMakeCache.txt OR EXISTS ${srcdir}/CMakeFiles)
    message("##########################################################")
    message("Found results from an in-source build in source directory.")
    message("Please delete:")
    message("  ${srcdir}/CMakeCache.txt (file)")
    message("  ${srcdir}/CMakeFiles (directory)")
    message("And re-run CMake from an out-of-source directory.")
    message("In-source builds are forbidden!")
    message("##########################################################")
    message(FATAL_ERROR)
  endif()
endfunction()

function(xpOptionalBuildDirs)
  foreach(dir ${ARGV})
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${dir})
      string(TOUPPER ${dir} DIR)
      option(XP_GENERATE_${DIR} "include ${dir} targets" ON)
      if(XP_GENERATE_${DIR})
        set(${DIR} PARENT_SCOPE) # will be part of main solution
      else()
        set(${DIR} EXCLUDE_FROM_ALL PARENT_SCOPE) # generated, but not part of main solution
      endif()
    endif()
  endforeach()
endfunction()

function(xpCheckCompilerFlags flagVar flags)
  separate_arguments(flags)
  foreach(flag ${flags})
    string(REPLACE "-" "_" flag_ ${flag})
    string(REPLACE "=" "_" flag_ ${flag_})
    if(flagVar MATCHES ".*CXX_FLAGS.*")
      check_cxx_compiler_flag("${flag}" has_cxx${flag_})
      if(has_cxx${flag_})
        xpStringAppendIfDne(${flagVar} "${flag}")
      endif()
    elseif(flagVar MATCHES ".*C_FLAGS.*")
      check_c_compiler_flag("${flag}" has_c${flag_})
      if(has_c${flag_})
        xpStringAppendIfDne(${flagVar} "${flag}")
      endif()
    endif()
  endforeach()
  set(${flagVar} "${${flagVar}}" PARENT_SCOPE)
endfunction()

function(xpCheckLinkerFlag _FLAG _RESULT)
  set(srcFile ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/linksrc.cxx)
  file(WRITE ${srcFile} "int main() { return 0; }\n")
  message(STATUS "Performing Linker Test ${_RESULT}")
  try_compile(${_RESULT} ${CMAKE_BINARY_DIR} ${srcFile}
    CMAKE_FLAGS -DCMAKE_EXE_LINKER_FLAGS="${_FLAG}"
    OUTPUT_VARIABLE OUTPUT
    )
  if(${${_RESULT}})
    message(STATUS "Performing Linker Test ${_RESULT} - Success")
  else()
    message(STATUS "Performing Linker Test ${_RESULT} - Failed")
  endif()
  set(${_RESULT} ${${_RESULT}} PARENT_SCOPE)
endfunction()

function(xpCheckLinkerOptions linkVar options)
  separate_arguments(options)
  foreach(opt ${options})
    string(REPLACE "-" "_" opt_ ${opt})
    string(REPLACE "," "" opt_ ${opt_})
    xpCheckLinkerFlag("${opt}" has_link${opt_})
    if(has_link${opt_})
      xpStringAppendIfDne(${linkVar} "${opt}")
    endif()
  endforeach()
  set(${linkVar} "${${linkVar}}" PARENT_SCOPE)
endfunction()

macro(xpEnableWarnings)
  if((CMAKE_CXX_COMPILER_ID STREQUAL GNU) OR (${CMAKE_CXX_COMPILER_ID} MATCHES "Clang"))
    check_cxx_compiler_flag("-Wall" has_Wall)
    if(has_Wall)
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-Wall")
    endif()
    #-Wall turns on maybe_uninitialized warnings which can be spurious
    check_cxx_compiler_flag("-Wno-maybe-uninitialized" has_Wno_maybe_uninitialized)
    if(has_Wno_maybe_uninitialized)
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-Wno-maybe-uninitialized")
    endif()
    check_cxx_compiler_flag("-Wextra" has_Wextra)
    if(has_Wextra)
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-Wextra")
    endif()
    check_cxx_compiler_flag("-Wcast-align" has_cast_align)
    if(has_cast_align)
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-Wcast-align")
    endif()
    check_cxx_compiler_flag("-pedantic" has_pedantic)
    if(has_pedantic)
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-pedantic")
    endif()
    check_cxx_compiler_flag("-Wformat=2" has_Wformat)
    if(has_Wformat)
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-Wformat=2")
    endif()
    check_cxx_compiler_flag("-Wfloat-equal" has_Wfloat_equal)
    if(has_Wfloat_equal)
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-Wfloat-equal")
    endif()
    check_cxx_compiler_flag("-Wno-unknown-pragmas" has_nounkprag)
    if(has_nounkprag)
      # turn off unknown pragma warnings as we use MSVC pragmas
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-Wno-unknown-pragmas")
    endif()
    check_cxx_compiler_flag("-Wno-psabi" has_psabi)
    if(has_psabi)
      # turn off messages noting ABI passing structure changes in GCC
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-Wno-psabi")
    endif()
  endif()
endmacro()

function(xpToggleDebugInfo)
  if(MSVC)
    set(releaseCompiler "/O2 /Ob2")
    set(reldebCompiler "/Zi /O2 /Ob1")
    set(releaseLinker "/INCREMENTAL:NO")
    set(reldebLinker "/debug /INCREMENTAL")
  elseif((CMAKE_C_COMPILER_ID STREQUAL GNU) OR (CMAKE_CXX_COMPILER_ID STREQUAL GNU) OR
         ${CMAKE_C_COMPILER_ID} MATCHES "Clang" OR ${CMAKE_CXX_COMPILER_ID} MATCHES "Clang"
    )
    set(releaseCompiler "-O3")
    set(reldebCompiler "-O2 -g")
  else()
    message(FATAL_ERROR "unknown compiler")
  endif()
  if(XP_BUILD_WITH_DEBUG_INFO)
    set(from release)
    set(to reldeb)
  else()
    set(from reldeb)
    set(to release)
  endif()
  foreach(flagVar ${ARGV})
    if(DEFINED ${flagVar})
      if(${flagVar} MATCHES ".*LINKER_FLAGS.*")
        if(DEFINED ${from}Linker AND DEFINED ${to}Linker)
          string(REGEX REPLACE "${${from}Linker}" "${${to}Linker}" flagTmp "${${flagVar}}")
          set(${flagVar} ${flagTmp} CACHE STRING "Flags used by the linker." FORCE)
        endif()
      else()
        if(${flagVar} MATCHES ".*CXX_FLAGS.*")
          set(cType "C++ ")
        elseif(${flagVar} MATCHES ".*C_FLAGS.*")
          set(cType "C ")
        endif()
        string(REGEX REPLACE "${${from}Compiler}" "${${to}Compiler}" flagTmp "${${flagVar}}")
        set(${flagVar} ${flagTmp} CACHE STRING "Flags used by the ${cType}compiler." FORCE)
      endif()
    endif()
  endforeach()
endfunction()

function(xpDebugInfoOption)
  cmake_dependent_option(XP_BUILD_WITH_DEBUG_INFO "build Release with debug information" OFF
    "DEFINED CMAKE_BUILD_TYPE;CMAKE_BUILD_TYPE STREQUAL Release" OFF
    )
  set(checkflags
    CMAKE_C_FLAGS_RELEASE
    CMAKE_CXX_FLAGS_RELEASE
    )
  if(MSVC)
    list(APPEND checkflags
      CMAKE_EXE_LINKER_FLAGS_RELEASE
      CMAKE_MODULE_LINKER_FLAGS_RELEASE
      CMAKE_SHARED_LINKER_FLAGS_RELEASE
      )
  endif()
  xpToggleDebugInfo(${checkflags})
endfunction()

function(xpModifyRuntime)
  if(XP_BUILD_STATIC_RT)
    set(from "/MD")
    set(to "/MT")
  else()
    set(from "/MT")
    set(to "/MD")
  endif()
  foreach(flagVar ${ARGV})
    if(DEFINED ${flagVar})
      if(${flagVar} MATCHES "${from}")
        string(REGEX REPLACE "${from}" "${to}" flagTmp "${${flagVar}}")
        if(${flagVar} MATCHES ".*CXX_FLAGS.*")
          set(cType "C++ ")
        elseif(${flagVar} MATCHES ".*C_FLAGS.*")
          set(cType "C ")
        endif()
        set(${flagVar} ${flagTmp} CACHE STRING "Flags used by the ${cType}compiler." FORCE)
      endif()
    endif()
  endforeach()
endfunction()

function(xpSetPostfix)
  if(XP_BUILD_STATIC_RT)
    set(CMAKE_RELEASE_POSTFIX "-s" PARENT_SCOPE)
    set(CMAKE_DEBUG_POSTFIX "-sd" PARENT_SCOPE)
  else()
    set(CMAKE_RELEASE_POSTFIX "" PARENT_SCOPE)
    set(CMAKE_DEBUG_POSTFIX "-d" PARENT_SCOPE)
  endif()
endfunction()

macro(xpCommonFlags)
  include(${xpThisDir}/pros.cmake) # xp_<project> lists
  if(NOT DEFINED CMAKE_C_COMPILER_ID)
    set(CMAKE_C_COMPILER_ID NOTDEFINED)
  endif()
  if(NOT DEFINED CMAKE_CXX_COMPILER_ID)
    set(CMAKE_CXX_COMPILER_ID NOTDEFINED)
  endif()
  if(EXISTS ${xpThisDir}/xpopts.cmake)
    include(${xpThisDir}/xpopts.cmake) # determine XP_BUILD_STATIC_RT
  elseif(MSVC)
    set(XP_BUILD_STATIC_RT ON)
  else()
    set(XP_BUILD_STATIC_RT)
  endif()
  if(CMAKE_CONFIGURATION_TYPES)
    # https://gitlab.kitware.com/cmake/community/-/wikis/FAQ#how-can-i-specify-my-own-configurations-for-generators-that-allow-it-
    # For generators that allow it (like Visual Studio), CMake generates four
    # configurations by default: Debug, Release, MinSizeRel and RelWithDebInfo.
    # Many people just need Debug and Release, or need other configurations. To
    # modify this change the variable CMAKE_CONFIGURATION_TYPES in the cache:
    set(CMAKE_CONFIGURATION_TYPES Debug Release)
    set(CMAKE_CONFIGURATION_TYPES "${CMAKE_CONFIGURATION_TYPES}" CACHE STRING
      "Set the configurations to what we need" FORCE
      )
  endif()
  xpSetPostfix()
  xpDebugInfoOption()
  if(MSVC)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
      add_definitions(-DWIN64)
    endif()
    # Turn on Multi-processor Compilation
    xpStringAppendIfDne(CMAKE_C_FLAGS "/MP")
    xpStringAppendIfDne(CMAKE_CXX_FLAGS "/MP")
    # option to change default build configuration to include INSTALL and PACKAGE
    option(XP_BUILD_INSTALL_PACKAGE "enable CMAKE_VS_INCLUDE_[INSTALL|PACKAGE]_TO_DEFAULT_BUILD" OFF)
    if(XP_BUILD_INSTALL_PACKAGE)
      # Add INSTALL and PACKAGE to the default build configuration
      set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD 1)
      set(CMAKE_VS_INCLUDE_PACKAGE_TO_DEFAULT_BUILD 1)
    else()
      unset(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD)
      unset(CMAKE_VS_INCLUDE_PACKAGE_TO_DEFAULT_BUILD)
    endif()
    # Remove /Zm1000 - breaks optimizing compiler w/ IncrediBuild
    string(REPLACE "/Zm1000" "" CMAKE_C_FLAGS ${CMAKE_C_FLAGS})
    string(REPLACE "/Zm1000" "" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})
    # https://cmake.org/cmake/help/v3.15/policy/CMP0091.html
    cmake_policy(GET CMP0091 msvcRuntime)
    if(msvcRuntime STREQUAL NEW)
      if(XP_BUILD_STATIC_RT)
        set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
      else()
        set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
      endif()
    else()
      # by default we'll modify the following list of flag variables,
      # but you can call xpModifyRuntime with your own list
      xpModifyRuntime(
        CMAKE_C_FLAGS_RELEASE
        CMAKE_C_FLAGS_DEBUG
        CMAKE_CXX_FLAGS_RELEASE
        CMAKE_CXX_FLAGS_DEBUG
        # NOTE: these are the only flags we modify in common (including externpro-built projects), for now
        )
    endif()
  elseif((CMAKE_C_COMPILER_ID STREQUAL GNU) OR (CMAKE_CXX_COMPILER_ID STREQUAL GNU) OR ${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
    if(CMAKE_BUILD_TYPE STREQUAL Debug)
      add_definitions(-D_DEBUG)
    endif()
    # C
    if(DEFINED CMAKE_C_COMPILER)
      include(CheckCCompilerFlag)
      check_c_compiler_flag("-fPIC" has_c_fPIC)
      if(has_c_fPIC)
        xpStringAppendIfDne(CMAKE_C_FLAGS "-fPIC")
        xpStringAppendIfDne(CMAKE_EXE_LINKER_FLAGS "-fPIC")
        xpStringAppendIfDne(CMAKE_MODULE_LINKER_FLAGS "-fPIC")
        xpStringAppendIfDne(CMAKE_SHARED_LINKER_FLAGS "-fPIC")
      endif()
      check_c_compiler_flag("-msse3" has_c_msse3)
      if(has_c_msse3)
        xpStringAppendIfDne(CMAKE_C_FLAGS "-msse3")
      endif()
      check_c_compiler_flag("-fstack-protector-strong" has_c_StrongSP)
      if(has_c_StrongSP)
        xpStringAppendIfDne(CMAKE_C_FLAGS "-fstack-protector-strong")
      endif()
      if(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
        check_c_compiler_flag("-arch x86_64" has_c_arch)
        if(has_c_arch)
          xpStringAppendIfDne(CMAKE_C_FLAGS "-arch x86_64")
          xpStringAppendIfDne(CMAKE_EXE_LINKER_FLAGS "-arch x86_64")
          xpStringAppendIfDne(CMAKE_MODULE_LINKER_FLAGS "-arch x86_64")
          xpStringAppendIfDne(CMAKE_SHARED_LINKER_FLAGS "-arch x86_64")
        endif()
      endif() # CMAKE_SYSTEM_NAME (Darwin)
    endif()
    # C++
    if((CMAKE_CXX_COMPILER_ID STREQUAL GNU) OR ${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
      include(CheckCXXCompilerFlag)
      if(${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
        check_cxx_compiler_flag("-stdlib=libc++" has_libcxx)
        if(has_libcxx)
          xpStringAppendIfDne(CMAKE_CXX_FLAGS "-stdlib=libc++")
          xpStringAppendIfDne(CMAKE_EXE_LINKER_FLAGS "-stdlib=libc++")
          xpStringAppendIfDne(CMAKE_MODULE_LINKER_FLAGS "-stdlib=libc++")
          xpStringAppendIfDne(CMAKE_SHARED_LINKER_FLAGS "-stdlib=libc++")
        endif()
      endif()
      check_cxx_compiler_flag("-fPIC" has_cxx_fPIC)
      if(has_cxx_fPIC)
        xpStringAppendIfDne(CMAKE_CXX_FLAGS "-fPIC")
        xpStringAppendIfDne(CMAKE_EXE_LINKER_FLAGS "-fPIC")
        xpStringAppendIfDne(CMAKE_MODULE_LINKER_FLAGS "-fPIC")
        xpStringAppendIfDne(CMAKE_SHARED_LINKER_FLAGS "-fPIC")
      endif()
      check_cxx_compiler_flag("-msse3" has_cxx_msse3)
      if(has_cxx_msse3)
        xpStringAppendIfDne(CMAKE_CXX_FLAGS "-msse3")
      endif()
      check_cxx_compiler_flag("-fstack-protector-strong" has_cxx_StrongSP)
      if(has_cxx_StrongSP)
        xpStringAppendIfDne(CMAKE_CXX_FLAGS "-fstack-protector-strong")
      endif()
      if(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
        check_cxx_compiler_flag("-arch x86_64" has_cxx_arch)
        if(has_cxx_arch)
          xpStringAppendIfDne(CMAKE_CXX_FLAGS "-arch x86_64")
          xpStringAppendIfDne(CMAKE_EXE_LINKER_FLAGS "-arch x86_64")
          xpStringAppendIfDne(CMAKE_MODULE_LINKER_FLAGS "-arch x86_64")
          xpStringAppendIfDne(CMAKE_SHARED_LINKER_FLAGS "-arch x86_64")
        endif()
      endif() # CMAKE_SYSTEM_NAME (Darwin)
    endif() # C++ (GNUCXX OR Clang)
  endif()
endmacro()

macro(xpSetFlagsMsvc)
  add_definitions(
    -D_CRT_NONSTDC_NO_DEPRECATE
    -D_CRT_SECURE_NO_WARNINGS
    -D_SCL_SECURE_NO_WARNINGS
    -D_WINSOCK_DEPRECATED_NO_WARNINGS
    -D_WIN32_WINNT=0x0601 #(Windows 7 target)
    -DWIN32_LEAN_AND_MEAN
    )
  xpStringAppendIfDne(CMAKE_EXE_LINKER_FLAGS_DEBUG "/MANIFEST:NO")
  # Remove Linker > System > Stack Reserve Size setting
  string(REPLACE "/STACK:10000000" "" CMAKE_EXE_LINKER_FLAGS ${CMAKE_EXE_LINKER_FLAGS})
  # Add Linker > System > Enable Large Addresses
  xpStringAppendIfDne(CMAKE_EXE_LINKER_FLAGS "/LARGEADDRESSAWARE")
  option(XP_BUILD_VERBOSE "use verbose compiler and linker options" OFF)
  if(XP_BUILD_VERBOSE)
    # Report the build times
    xpStringAppendIfDne(CMAKE_EXE_LINKER_FLAGS "/time")
    # Report the linker version (32/64-bit: x86_amd64/amd64)
    xpStringAppendIfDne(CMAKE_CXX_FLAGS "/Bv")
  endif()
  if(MSVC12)
    # Remove unreferenced data and functions
    # http://blogs.msdn.com/b/vcblog/archive/2014/03/25/linker-enhancements-in-visual-studio-2013-update-2-ctp2.aspx
    xpStringAppendIfDne(CMAKE_CXX_FLAGS "/Zc:inline")
  endif()
  # Increase the number of sections that an object file can contain
  # https://msdn.microsoft.com/en-us/library/ms173499.aspx
  xpStringAppendIfDne(CMAKE_CXX_FLAGS "/bigobj")
  # Treat Warnings As Errors
  xpStringAppendIfDne(CMAKE_CXX_FLAGS "/WX")
  # Warning level 3
  xpStringAppendIfDne(CMAKE_CXX_FLAGS "/W3")
  # Treat the following warnings as errors (above and beyond Warning Level 3)
  xpStringAppendIfDne(CMAKE_CXX_FLAGS "/we4238") # don't take address of temporaries
  xpStringAppendIfDne(CMAKE_CXX_FLAGS "/we4239") # don't bind temporaries to non-const references
  # Disable the following warnings
  xpStringAppendIfDne(CMAKE_CXX_FLAGS "/wd4503") # decorated name length exceeded, name was truncated
  xpStringAppendIfDne(CMAKE_CXX_FLAGS "/wd4351") # new behavior: elements of array will be default initialized
endmacro()

macro(xpSetFlagsGccDebug)
  if(NOT DEFINED XP_SANITIZER)
    set(NV_SANITIZER "NONE") # (NV: normal variable) 'cmake --help-policy CMP0077'
    if(XP_USE_ASAN)
      message(AUTHOR_WARNING "XP_USE_ASAN deprecated, use XP_SANITIZER=ASAN.")
      set(NV_SANITIZER "ASAN")
    endif()
  else()
    if(DEFINED XP_USE_ASAN)
      if(XP_SANITIZER STREQUAL "ASAN")
        message(AUTHOR_WARNING "XP_USE_ASAN deprecated, remove use.")
      else()
        message(AUTHOR_WARNING "XP_USE_ASAN deprecated and ignored, using XP_SANITIZER=${XP_SANITIZER}.")
      endif()
    endif()
    set(NV_SANITIZER ${XP_SANITIZER})
    unset(XP_SANITIZER)
  endif()
  set(docSanitizer "sanitizer option [ASAN|TSAN|NONE]")
  if(CMAKE_BUILD_TYPE STREQUAL Debug)
    set(XP_SANITIZER ${NV_SANITIZER} CACHE STRING "${docSanitizer}" FORCE)
    set_property(CACHE XP_SANITIZER PROPERTY STRINGS NONE ASAN TSAN)
    if(XP_SANITIZER STREQUAL "NONE")
    elseif(XP_SANITIZER STREQUAL "ASAN")
      include(CMakePushCheckState)
      cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES asan)
      check_cxx_compiler_flag("-fsanitize=address" has_asan)
      if(has_asan)
        xpStringAppendIfDne(CMAKE_CXX_FLAGS_DEBUG "-fsanitize=address")
      endif()
      cmake_pop_check_state()
    elseif(XP_SANITIZER STREQUAL "TSAN")
      include(CMakePushCheckState)
      cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES tsan)
      check_cxx_compiler_flag("-fsanitize=thread" has_tsan)
      if(has_tsan)
        xpStringAppendIfDne(CMAKE_CXX_FLAGS_DEBUG "-fsanitize=thread")
      endif()
      cmake_pop_check_state()
    elseif(DEFINED XP_SANITIZER)
      message(FATAL_ERROR "XP_SANITIZER unrecognized: ${XP_SANITIZER}, ${docSanitizer}")
    endif()
  else()
    set(XP_SANITIZER ${NV_SANITIZER} CACHE INTERNAL "${docSanitizer}")
  endif()
  #######
  if(NOT DEFINED XP_COVERAGE)
    set(NV_COVERAGE OFF) # (NV: normal variable) 'cmake --help-policy CMP0077'
  else()
    set(NV_COVERAGE ${XP_COVERAGE})
    unset(XP_COVERAGE)
  endif()
  cmake_dependent_option(XP_COVERAGE "generate coverage information" ${NV_COVERAGE}
    "CMAKE_BUILD_TYPE STREQUAL Debug" ${NV_COVERAGE}
    )
  if(XP_COVERAGE AND CMAKE_BUILD_TYPE STREQUAL Debug)
    find_program(XP_PATH_LCOV lcov)
    find_program(XP_PATH_GENHTML genhtml)
    if(XP_PATH_LCOV AND XP_PATH_GENHTML)
      if(DEFINED externpro_DIR AND EXISTS ${externpro_DIR})
        list(APPEND XP_COVERAGE_RM '${externpro_DIR}/*')
      endif()
      if(EXISTS /opt/rh AND IS_DIRECTORY /opt/rh)
        list(APPEND XP_COVERAGE_RM '/opt/rh/*')
      endif()
      if(EXISTS /tmp AND IS_DIRECTORY /tmp)
        list(APPEND XP_COVERAGE_RM '/tmp/*')
      endif()
      if(EXISTS /usr AND IS_DIRECTORY /usr)
        list(APPEND XP_COVERAGE_RM '/usr/*')
      endif()
      list(APPEND XP_COVERAGE_RM '${CMAKE_BINARY_DIR}/*')
      list(REMOVE_DUPLICATES XP_COVERAGE_RM)
      if(NOT TARGET precoverage)
        add_custom_target(precoverage
          COMMAND ${XP_PATH_LCOV} --directory ${CMAKE_BINARY_DIR} --zerocounters
          COMMAND ${XP_PATH_LCOV} --capture --initial --directory ${CMAKE_BINARY_DIR} --output-file ${PROJECT_NAME}-base.info
          WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
          )
      endif()
      if(NOT TARGET postcoverage)
        add_custom_target(postcoverage
          COMMAND ${XP_PATH_LCOV} --directory ${CMAKE_BINARY_DIR} --capture --output-file ${PROJECT_NAME}-test.info
          COMMAND ${XP_PATH_LCOV} -a ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-base.info
            -a ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-test.info -o ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.info
          COMMAND ${XP_PATH_LCOV} --remove ${PROJECT_NAME}.info ${XP_COVERAGE_RM} --output-file ${PROJECT_NAME}-cleaned.info
          COMMAND ${XP_PATH_GENHTML} -o report ${PROJECT_NAME}-cleaned.info
          COMMAND ${CMAKE_COMMAND} -E remove ${PROJECT_NAME}*.info
          WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
          )
      endif()
      if(NOT TARGET coverage)
        add_custom_target(coverage
          COMMAND make precoverage
          COMMAND make test
          COMMAND make postcoverage
          WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
          )
      endif()
      xpStringAppendIfDne(CMAKE_CXX_FLAGS_DEBUG "--coverage")
    else()
      if(NOT XP_PATH_LCOV)
        message(AUTHOR_WARNING "lcov not found -- coverage reports will not be supported")
      endif()
      if(NOT XP_PATH_GENHTML)
        message(AUTHOR_WARNING "genhtml not found -- coverage reports will not be supported")
      endif()
    endif()
  endif()
  check_cxx_compiler_flag("-O0" has_O0)
  if(has_O0) # don't use debug optimizations (coverage requires this, make it the default for all debug builds)
    xpStringAppendIfDne(CMAKE_CXX_FLAGS_DEBUG "-O0")
  endif()
endmacro()

macro(xpSetFlagsGcc)
  if(NOT CMAKE_BUILD_TYPE) # if not specified, default to "Release"
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING
      "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
      FORCE
      )
  endif()
  include(CheckCCompilerFlag)
  include(CheckCXXCompilerFlag)
  xpSetFlagsGccDebug()
  if(CMAKE_CXX_COMPILER_ID STREQUAL GNU)
    # Have all executables look in the current directory for shared libraries
    # so the user or installers don't need to update LD_LIBRARY_PATH or equivalent.
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-R,\$ORIGIN")
    set(CMAKE_INSTALL_RPATH "\$ORIGIN")
  endif()
  option(XP_TREAT_WARNING_AS_ERROR "treat GCC warnings as errors" ON)
  if(XP_TREAT_WARNING_AS_ERROR)
    check_cxx_compiler_flag("-Werror" has_Werror)
    if(has_Werror)
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-Werror")
    endif()
    check_c_compiler_flag("-Werror" has_c_Werror)
    if(has_c_Werror)
      xpStringAppendIfDne(CMAKE_C_FLAGS "-Werror")
    endif()
  endif()
  if(${CMAKE_SYSTEM_NAME} STREQUAL Linux)
    # Makes symbols in executables inaccessible from plugins.
    xpStringRemoveIfExists(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS "-rdynamic")
    # Makes symbols hidden by default in shared libraries.  This allows
    # SDL-developed plugins compiled against different versions of
    # VantageShared to coexist without using each other's symbols.
    check_cxx_compiler_flag("-fvisibility=hidden" has_visibility)
    if(has_visibility)
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-fvisibility=hidden")
    endif()
    # Prevents symbols from external static libraries from being visible
    # in the shared libraries that use them.  This allows
    # SDL-developed plugins compiled against different versions of third-
    # party libraries to coexist without using each other's symbols.
    check_cxx_compiler_flag("-Wl,--exclude-libs,ALL" has_exclude)
    if(has_exclude)
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-Wl,--exclude-libs,ALL")
    endif()
  endif()
endmacro()

macro(xpSetFlags) # preprocessor, compiler, linker flags
  xpEnforceOutOfSourceBuilds()
  xpSetUnitTestTools()
  enable_testing()
  set_property(GLOBAL PROPERTY USE_FOLDERS ON) # enables Solution Folders
  set_property(GLOBAL PROPERTY GLOBAL_DEPENDS_NO_CYCLES ON)
  xpCommonFlags()
  xpEnableWarnings()
  if(NOT DEFINED XP_CMAKE_REPO_INSYNC)
    # cmake error if repo and cmake are not in sync
    set(NV_CMAKE_REPO_INSYNC ON) # (NV: normal variable) 'cmake --help-policy CMP0077'
  endif()
  if(MSVC)
    xpSetFlagsMsvc()
  elseif((CMAKE_CXX_COMPILER_ID STREQUAL GNU) OR ${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
    xpSetFlagsGcc()
  endif()
endmacro()

macro(xpSetUnitTestTools)
  option(XP_GENERATE_TESTTOOLS "include test tool projects" ON)
  if(XP_GENERATE_TESTTOOLS)
    set(TESTTOOL) # will be part of main solution
  else()
    set(TESTTOOL EXCLUDE_FROM_ALL) # generated, but not part of main solution
  endif()
  ######
  option(XP_GENERATE_UNITTESTS "include unit test projects" ON)
  if(XP_GENERATE_UNITTESTS)
    set(UNITTEST) # will be part of main solution
  else()
    set(UNITTEST EXCLUDE_FROM_ALL) # generated, but not part of main solution
  endif()
endmacro()
