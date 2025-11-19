# legacy/xpfunmac.cmake -- used by legacy smanders/externpro and derivatives
#    like exdlpro, internpro, webpro, etc.
#  xp prefix = intended to be used both internally (by externpro) and externally
#  ip prefix = intended to be used only internally by externpro
#  fun = functions
#  mac = macros
# functions and macros should begin with xp or ip prefix
# functions create a local scope for variables, macros use the global scope

set(xpThisDir ${CMAKE_CURRENT_LIST_DIR}) # TODO check if necessary after code copied
include(CMakeDependentOption)

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
    add_custom_command(TARGET download_${fn} POST_BUILD
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
        # CMAKE_CONFIGURATION_TYPES to take effect (see xpCommonFlags)
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

set(g_README ${CMAKE_BINARY_DIR}/xpbase/pro/README.md)
set(g_READMEsub ${CMAKE_BINARY_DIR}/xpbase/pro/README.sub.md)
set(g_READMEdep ${CMAKE_BINARY_DIR}/xpbase/pro/deps.dot)

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
    set(org externpro)
    set(branch dev)
    set(mark depgraph_${hash})
    set(url "https://raw.githubusercontent.com/${org}/exdlpro/${branch}/projects/README.md")
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
    target_include_directories(${tgt} SYSTEM ${_pubinc} ${_pvtinc})
  endif()
  if(_pubdef OR _pvtdef)
    if(XP_CMAKE_VERBOSE)
      message(STATUS "${tgt} defs: ${_pubdef} ${_pvtdef}")
    endif()
    target_compile_definitions(${tgt} ${_pubdef} ${_pvtdef})
  endif()
endfunction()
