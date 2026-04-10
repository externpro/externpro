########################################
# xpfunmac.cmake
#  xp prefix = intended to be used both internally (by externpro) and externally
#  ip prefix = intended to be used only internally by externpro
#  fun = functions
#  mac = macros
# functions and macros should begin with xp or ip prefix
# functions create a local scope for variables, macros use the global scope

set(xpThisDir ${CMAKE_CURRENT_LIST_DIR})
include(CheckCCompilerFlag)
include(CheckCXXCompilerFlag)
include(CMakeDependentOption)

function(xpGetCompilerPrefix _ret)
  set(options MATCH_BOOST VER_ONE VER_TWO)
  cmake_parse_arguments(X "${options}" "" "" ${ARGN})
  if(X_MATCH_BOOST)
    if(${CMAKE_SYSTEM_NAME} STREQUAL Darwin)
      set(digits "\\1\\2")
    else()
      set(digits "\\1")
    endif()
  elseif(X_VER_ONE)
    set(digits "\\1")
  elseif(X_VER_TWO)
    set(digits "\\1\\2")
  else()
    set(digits "\\1\\2\\3")
  endif()
  if(MSVC)
    set(prefix vc${MSVC_TOOLSET_VERSION})
  elseif((CMAKE_CXX_COMPILER_ID STREQUAL GNU) OR (CMAKE_C_COMPILER_ID STREQUAL GNU))
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
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_C_COMPILER_ID MATCHES "Clang")
    # LLVM/Apple Clang (clang.llvm.org)
    if(X_MATCH_BOOST AND ${CMAKE_SYSTEM_NAME} STREQUAL Darwin)
      set(clangName clang-darwin)
    else()
      set(clangName clang)
    endif()
    if(DEFINED CMAKE_CXX_COMPILER_VERSION)
      set(compilerVersion ${CMAKE_CXX_COMPILER_VERSION})
    elseif(DEFINED CMAKE_C_COMPILER_VERSION)
      set(compilerVersion ${CMAKE_C_COMPILER_VERSION})
    else()
      message(SEND_ERROR "xpfunmac.cmake: unknown CMAKE_<LANG>_COMPILER_VERSION")
    endif()
    string(REGEX REPLACE "([0-9]+)\\.([0-9]+)\\.([0-9]+)\\.([0-9]+)?"
      "${clangName}${digits}"
      prefix ${compilerVersion}
      )
  else()
    message(SEND_ERROR "xpfunmac.cmake: compiler support lacking: ${CMAKE_C_COMPILER_ID}")
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
  include(${xpThisDir}/xpflags.cmake) # populates CMAKE_*_FLAGS
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
    ${_dir}/*.svg
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

function(ipDownload url sha dst)
  cmake_path(GET dst PARENT_PATH dst_dir)
  if(NOT EXISTS "${dst_dir}")
    file(MAKE_DIRECTORY "${dst_dir}")
  endif()
  if(DEFINED XPRO_DIR)
    set(stamp_dir "${XPRO_DIR}/xpd/sha256")
    if(NOT EXISTS "${stamp_dir}")
      file(MAKE_DIRECTORY "${stamp_dir}")
    endif()
    cmake_path(GET dst FILENAME dst_fn)
    string(SHA256 dst_key "${dst}")
    set(stamp "${stamp_dir}/${dst_fn}.${dst_key}.sha256")
  else()
    set(stamp "${dst}.sha256")
  endif()
  if(EXISTS "${dst}" AND EXISTS "${stamp}" AND NOT "${dst}" IS_NEWER_THAN "${stamp}")
    file(READ "${stamp}" stamp_sha)
    string(STRIP "${stamp_sha}" stamp_sha)
    if("${stamp_sha}" STREQUAL "${sha}")
      return()
    endif()
  endif()
  set(max_retries 8)
  set(ok FALSE)
  foreach(attempt RANGE 0 ${max_retries})
    file(DOWNLOAD "${url}" "${dst}" TLS_VERIFY ON STATUS st LOG log)
    list(GET st 0 code)
    list(GET st 1 msg)
    if(code EQUAL 0)
      file(SHA256 "${dst}" got_sha)
      if(NOT "${got_sha}" STREQUAL "${sha}")
        message(FATAL_ERROR "ipDownload: hash mismatch downloading ${url}: expected ${sha} got ${got_sha}\n${log}")
      endif()
      file(WRITE "${stamp}" "${sha}\n")
      set(ok TRUE)
      break()
    endif()
    set(http_code "")
    if(log MATCHES "HTTP/[0-9.]+[ ]+([0-9][0-9][0-9])[ ]*")
      set(http_code "${CMAKE_MATCH_1}")
    endif()
    if(NOT "${http_code}" STREQUAL "" AND http_code EQUAL 404)
      message(FATAL_ERROR "ipDownload: 404 downloading ${url} (${code}): ${msg}\n${log}")
    endif()
    set(retryable FALSE)
    if(NOT "${http_code}" STREQUAL "")
      if(http_code GREATER_EQUAL 500 AND http_code LESS_EQUAL 599)
        set(retryable TRUE)
      elseif(http_code EQUAL 429)
        set(retryable TRUE)
      endif()
    endif()
    if(attempt LESS ${max_retries})
      if(retryable)
        math(EXPR sleep_s "2 << ${attempt}")
      else()
        math(EXPR sleep_s "${attempt} + 1")
      endif()
      if(sleep_s GREATER 60)
        set(sleep_s 60)
      endif()
      execute_process(COMMAND ${CMAKE_COMMAND} -E sleep ${sleep_s})
    endif()
  endforeach()
  if(NOT ok)
    message(FATAL_ERROR "ipDownload: error downloading ${url} (${code}): ${msg}\n${log}")
  endif()
endfunction()

function(ipDownloadManifestFromRepo dst)
  set(oneValueArgs REPO TAG MANIFEST_SHA256)
  set(multiValueArgs MANIFEST_HASH)
  cmake_parse_arguments(P "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  if(NOT DEFINED P_REPO OR NOT DEFINED P_TAG)
    message(FATAL_ERROR "ipDownloadManifestFromRepo: expected REPO and TAG")
  endif()
  string(REGEX REPLACE ".*/" "" PKG_NAME ${P_REPO})
  if(DEFINED P_MANIFEST_SHA256)
    set(_ext "cmake")
    set(_sha "${P_MANIFEST_SHA256}")
  elseif(DEFINED P_MANIFEST_HASH)
    if(NOT P_MANIFEST_HASH)
      message(FATAL_ERROR "ipDownloadManifestFromRepo: MANIFEST_HASH specified but empty")
    endif()
    list(GET P_MANIFEST_HASH 0 _mh0)
    if(NOT _mh0 MATCHES "^SHA256=(.+)$")
      message(FATAL_ERROR "ipDownloadManifestFromRepo: MANIFEST_HASH must be of the form 'SHA256=<hash>'")
    endif()
    set(_sha "${CMAKE_MATCH_1}")
    string(LENGTH "${_sha}" _msha_len)
    if(NOT _msha_len EQUAL 64)
      message(FATAL_ERROR "ipDownloadManifestFromRepo: MANIFEST_HASH SHA256 has invalid length (${_msha_len})")
    endif()
    set(_ext "json")
  else()
    message(FATAL_ERROR "ipDownloadManifestFromRepo: expected MANIFEST_SHA256 (manifest.cmake) or MANIFEST_HASH (manifest.json)")
  endif()
  set(_dst "${XPRO_DIR}/xpd/manifests/${PKG_NAME}-${P_TAG}.manifest.${_ext}")
  ipDownload(
    https://${P_REPO}/releases/download/${P_TAG}/${PKG_NAME}-${P_TAG}.manifest.${_ext}
    ${_sha}
    ${_dst}
    )
  set(${dst} "${_dst}" PARENT_SCOPE)
endfunction()

function(ipDownloadExtract url sha pth)
  cmake_path(GET url FILENAME txz)
  set(dst ${XPRO_DIR}/xpd/pkgs/${txz})
  ipDownload(${url} ${sha} ${dst})
  if(${dst} IS_NEWER_THAN ${XPRO_DIR}/xpx)
    file(ARCHIVE_EXTRACT INPUT ${dst} DESTINATION ${XPRO_DIR}/xpx)
    file(TOUCH_NOCREATE ${XPRO_DIR}/xpx)
  endif()
  string(REPLACE "-xpro.tar.xz" "" pkgbase ${txz})
  set(_pth ${XPRO_DIR}/xpx/${pkgbase}-xpro)
  if(NOT IS_DIRECTORY "${_pth}")
    set(_pth ${XPRO_DIR}/xpx/${pkgbase})
  endif()
  if(NOT IS_DIRECTORY "${_pth}")
    # txz already downloaded, needs to be extracted
    file(TOUCH_NOCREATE ${dst})
    ipDownloadExtract(${url} ${sha} _pth)
  endif()
  set(${pth} ${_pth} PARENT_SCOPE)
endfunction()

function(ipNormalizeManifestVarName _ret filename)
  # Must mirror normalization done in the release workflow.
  string(REGEX REPLACE "[^A-Za-z0-9]" "_" _norm "${filename}")
  set(${_ret} "${_norm}" PARENT_SCOPE)
endfunction()

function(ipGetPkgFromManifestCMake manifestFile pkg sha)
  xpGetCompilerPrefix(pfx VER_ONE)
  if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64|ARM64)$")
    set(platform ${CMAKE_SYSTEM_NAME}-arm64)
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64|AMD64)$")
    set(platform ${CMAKE_SYSTEM_NAME}-amd64)
  else()
    message(FATAL_ERROR "ipGetPkgFromManifestCMake: unhandled CMAKE_SYSTEM_PROCESSOR='${CMAKE_SYSTEM_PROCESSOR}'")
  endif()
  if(NOT EXISTS "${manifestFile}")
    message(FATAL_ERROR "ipGetPkgFromManifestCMake: manifest file not found: '${manifestFile}'")
  endif()
  unset(XP_MANIFEST_ARTIFACTS)
  include("${manifestFile}")
  if(NOT DEFINED XP_MANIFEST_ARTIFACTS)
    message(FATAL_ERROR "ipGetPkgFromManifestCMake: manifest missing XP_MANIFEST_ARTIFACTS: '${manifestFile}'")
  endif()
  set(match "${pfx}-${platform}")
  set(found_pkg "")
  foreach(fname ${XP_MANIFEST_ARTIFACTS})
    if(fname MATCHES "${match}.*\\.tar\\.xz$")
      set(found_pkg "${fname}")
      break()
    endif()
  endforeach()
  if(found_pkg STREQUAL "")
    set(match "${platform}")
    foreach(fname ${XP_MANIFEST_ARTIFACTS})
      if(fname MATCHES "${match}.*\\.tar\\.xz$")
        set(found_pkg "${fname}")
        break()
      endif()
    endforeach()
  endif()
  if(found_pkg STREQUAL "")
    message(FATAL_ERROR "ipGetPkgFromManifestCMake: no artifact matched '${pfx}-${platform}' (or fallback '${platform}') in '${manifestFile}'")
  endif()
  ipNormalizeManifestVarName(norm "${found_pkg}")
  set(shaVar "XP_ARTIFACT_SHA256__${norm}")
  if(NOT DEFINED ${shaVar})
    message(FATAL_ERROR "ipGetPkgFromManifestCMake: missing sha variable '${shaVar}' for artifact '${found_pkg}' in '${manifestFile}'")
  endif()
  string(LENGTH "${${shaVar}}" sha_len)
  if(NOT sha_len EQUAL 64)
    message(FATAL_ERROR "ipGetPkgFromManifestCMake: invalid SHA length (${sha_len}) for '${found_pkg}' in '${manifestFile}'")
  endif()
  set(${pkg} "${found_pkg}" PARENT_SCOPE)
  set(${sha} "${${shaVar}}" PARENT_SCOPE)
endfunction()

function(ipParseCompilerPrefix _family _ver pfx)
  # Parse prefixes like: gcc13, clang17, clang-darwin17, vc143.
  # If parsing fails, version is set to -1.
  set(family "")
  set(ver "-1")
  if(pfx MATCHES "^([A-Za-z_-]+)([0-9]+)$")
    set(family "${CMAKE_MATCH_1}")
    set(ver "${CMAKE_MATCH_2}")
  endif()
  set(${_family} "${family}" PARENT_SCOPE)
  set(${_ver} "${ver}" PARENT_SCOPE)
endfunction()

function(ipGetPkgFromManifestJson manifestFile pkg sha)
  xpGetCompilerPrefix(pfx VER_ONE)
  ipParseCompilerPrefix(want_family want_ver "${pfx}")
  if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64|ARM64)$")
    set(platform ${CMAKE_SYSTEM_NAME}-arm64)
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64|AMD64)$")
    set(platform ${CMAKE_SYSTEM_NAME}-amd64)
  else()
    message(FATAL_ERROR "ipGetPkgFromManifestJson: unhandled CMAKE_SYSTEM_PROCESSOR='${CMAKE_SYSTEM_PROCESSOR}'")
  endif()
  if(NOT EXISTS "${manifestFile}")
    message(FATAL_ERROR "ipGetPkgFromManifestJson: manifest file not found: '${manifestFile}'")
  endif()
  file(READ "${manifestFile}" _json)
  string(JSON _len ERROR_VARIABLE _json_err LENGTH "${_json}" artifacts)
  if(NOT "${_json_err}" STREQUAL "" AND NOT _len GREATER 0)
    message(FATAL_ERROR "ipGetPkgFromManifestJson: failed to read artifacts[] from '${manifestFile}': ${_json_err}")
  endif()
  if(_len EQUAL 0)
    message(FATAL_ERROR "ipGetPkgFromManifestJson: artifacts[] is empty in '${manifestFile}'")
  endif()
  if(want_ver LESS 0 OR want_family STREQUAL "")
    message(FATAL_ERROR "ipGetPkgFromManifestJson: could not parse compiler prefix '${pfx}' into family/version")
  endif()
  math(EXPR _last "${_len} - 1")
  # Pass 1: exact match on compiler_prefix + platform.
  set(best_fname "")
  set(best_sha "")
  foreach(i RANGE 0 ${_last})
    string(JSON a_platform GET "${_json}" artifacts ${i} platform)
    if(NOT "${a_platform}" STREQUAL "${platform}")
      continue()
    endif()
    string(JSON a_pfx GET "${_json}" artifacts ${i} compiler_prefix)
    if(NOT "${a_pfx}" STREQUAL "${pfx}")
      continue()
    endif()
    string(JSON best_fname GET "${_json}" artifacts ${i} filename)
    string(JSON best_sha GET "${_json}" artifacts ${i} sha256)
    break()
  endforeach()
  # Pass 2: fallback within same platform, choose highest numeric compiler version in same family.
  if(best_fname STREQUAL "")
    set(best_ver "-1")
    set(best_pfx "")
    foreach(i RANGE 0 ${_last})
      string(JSON a_platform GET "${_json}" artifacts ${i} platform)
      if(NOT "${a_platform}" STREQUAL "${platform}")
        continue()
      endif()
      string(JSON a_pfx GET "${_json}" artifacts ${i} compiler_prefix)
      ipParseCompilerPrefix(a_family a_ver "${a_pfx}")
      if(a_ver LESS 0 OR a_family STREQUAL "")
        continue()
      endif()
      if(NOT "${a_family}" STREQUAL "${want_family}")
        continue()
      endif()
      if(a_ver GREATER best_ver)
        set(best_ver "${a_ver}")
        set(best_pfx "${a_pfx}")
        string(JSON best_fname GET "${_json}" artifacts ${i} filename)
        string(JSON best_sha GET "${_json}" artifacts ${i} sha256)
      elseif(a_ver EQUAL best_ver)
        string(JSON cand_fname GET "${_json}" artifacts ${i} filename)
        if(NOT "${cand_fname}" STREQUAL "" AND "${cand_fname}" STRGREATER "${best_fname}")
          set(best_pfx "${a_pfx}")
          set(best_fname "${cand_fname}")
          string(JSON best_sha GET "${_json}" artifacts ${i} sha256)
        endif()
      endif()
    endforeach()
    if(best_fname STREQUAL "")
      message(FATAL_ERROR "ipGetPkgFromManifestJson: no artifact matched platform '${platform}' with compiler family '${want_family}' in '${manifestFile}'")
    endif()
  endif()
  string(LENGTH "${best_sha}" sha_len)
  if(NOT sha_len EQUAL 64)
    message(FATAL_ERROR "ipGetPkgFromManifestJson: invalid SHA length (${sha_len}) for '${best_fname}' in '${manifestFile}'")
  endif()
  set(${pkg} "${best_fname}" PARENT_SCOPE)
  set(${sha} "${best_sha}" PARENT_SCOPE)
endfunction()

function(ipGetPkgFromManifest manifestFile pkg sha)
  cmake_path(GET manifestFile EXTENSION LAST_ONLY _ext)
  if(_ext STREQUAL ".json")
    ipGetPkgFromManifestJson("${manifestFile}" _pkg _sha)
  else()
    ipGetPkgFromManifestCMake("${manifestFile}" _pkg _sha)
  endif()
  set(${pkg} "${_pkg}" PARENT_SCOPE)
  set(${sha} "${_sha}" PARENT_SCOPE)
endfunction()

function(ipGetProPath pth)
  set(oneValueArgs PKG REPO TAG MANIFEST_SHA256 DIST_DIR XPRO_PATH MANIFEST_FILE)
  set(multiValueArgs MANIFEST_HASH)
  cmake_parse_arguments(P "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  # NOTE - XPRO_DIR is set and cached (configurable) in xproinc.cmake
  # NOTE - XPRO_DIR subdirs: xpd (downloaded), xpx (extracted)
  if(DEFINED P_DIST_DIR)
    set(pth ${P_DIST_DIR}/share/cmake)
  elseif(DEFINED P_XPRO_PATH)
    set(url file://${P_XPRO_PATH})
    file(SHA256 ${P_XPRO_PATH} sha)
  elseif(DEFINED P_PKG AND DEFINED P_REPO AND DEFINED P_TAG)
    ipDownloadManifestFromRepo(dst REPO ${P_REPO} TAG ${P_TAG} MANIFEST_SHA256 ${P_MANIFEST_SHA256} MANIFEST_HASH ${P_MANIFEST_HASH})
    ipGetPkgFromManifest(${dst} pkg sha) # set pkg and sha
    set(url https://${P_REPO}/releases/download/${P_TAG}/${pkg})
  elseif(DEFINED P_PKG)
    message(FATAL_ERROR "ipGetProPath: error in xp_${P_PKG}")
  else()
    message(FATAL_ERROR "ipGetProPath: unexpected error")
  endif()
  if(DEFINED url AND DEFINED sha)
    ipDownloadExtract(${url} ${sha} pth) # populates pth
  endif()
  set(pth ${pth} PARENT_SCOPE)
endfunction()

function(xpFindPkg)
  cmake_parse_arguments(FP "" "" PKGS ${ARGN})
  foreach(package ${FP_PKGS})
    string(TOUPPER ${package} PKG)
    string(TOLOWER ${package} pkg)
    if("${package}" STREQUAL "Threads" AND DEFINED Threads_FOUND AND EXISTS ${Threads_DIR})
      return()
    endif()
    if(DEFINED xp_${package})
      ipGetProPath(pth PKG ${pkg} ${xp_${package}})
      unset(${package}_DIR CACHE)
      if(EXISTS ${pth}/share/cmake/xpuse-${pkg}-config.cmake)
        set(PKG_NAMES NAMES xpuse-${pkg})
      endif()
      find_package(${package} ${PKG_NAMES} REQUIRED CONFIG BYPASS_PROVIDER GLOBAL
        PATHS ${pth} ${pth}/share/cmake NO_DEFAULT_PATH
        )
      mark_as_advanced(${package}_DIR)
      if(NOT DEFINED __xp_${package}_cps_message_shown
         AND DEFINED ${package}_CONFIG
         AND ${package}_CONFIG MATCHES "\\.cps$")
        message(STATUS "Found ${package}.cps: ${${package}_VERSION}")
        set(__xp_${package}_cps_message_shown TRUE CACHE INTERNAL "Flag to track if ${package}.cps message was shown")
      endif()
      if(DEFINED ${PKG}_FOUND)
        set(${package}_FOUND ${${PKG}_FOUND})
        list(APPEND reqVars ${PKG}_FOUND ${package}_FOUND)
      elseif(DEFINED ${package}_FOUND)
        list(APPEND reqVars ${package}_FOUND)
      elseif(DEFINED ${pkg}_FOUND)
        list(APPEND reqVars ${pkg}_FOUND)
      endif()
      foreach(var ${reqVars})
        set(${var} ${${var}} PARENT_SCOPE)
      endforeach()
    endif()
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

function(xpGetVersionString verString)
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
  set(${verString} ${gitDescribe} PARENT_SCOPE)
endfunction()

function(ipProDepsInit)
  set(slate "\"#64748b\"")
  string(JOIN "\n" dot
    "digraph GG {"
    "  bgcolor=\"transparent\";"
    "  graph [fontcolor=${slate}, color=${slate}];"
    "  node  [fontcolor=${slate}, color=${slate}];"
    "  edge  [fontcolor=${slate}, color=${slate}];"
    "  node  [fontsize=10];"
    ""
    )
  set(dot "${dot}" PARENT_SCOPE)
  if(DEFINED xpdepsFile AND DEFINED P_REPO_NAME)
    # P_REPO_NAME should be DEFINED when this function is called from
    # xpExternPackage() but not when called from xpProDeps()
    file(WRITE ${xpdepsFile} "# ${P_REPO_NAME} dependencies\n")
  elseif(DEFINED xpdepsFile)
    string(JOIN "\n" hdr
      "# projects"
      "This README.md and the [deps.svg](deps.svg) files are generated"
      " from the contents of [pros.cmake](pros.cmake), any independently set"
      " or overridden `xp_` variables, and downloaded project manifest files."
      ""
      "For CMake toolkit docs, see [cmake/docs/README.md](docs/README.md)."
      ""
      )
    file(WRITE ${xpdepsFile} "${hdr}")
  endif()
  string(JOIN "\n" rme
    ""
    "|project|license [^_l]|description [dependencies]|version|source|diff [^_d]|"
    "|-------|-------------|--------------------------|-------|------|----------|"
    ""
    )
  set(rme "${rme}" PARENT_SCOPE)
  set(depsCheckCount 0 PARENT_SCOPE)
  set(depsMismatchCount 0 PARENT_SCOPE)
  set(depsMismatchReport "" PARENT_SCOPE)
endfunction()

function(ipProDepsKey _out)
  set(oneValueArgs REPO TAG MANIFEST_SHA256 MANIFEST_HASH)
  cmake_parse_arguments(P "" "${oneValueArgs}" "" ${ARGN})
  if(DEFINED P_MANIFEST_SHA256)
    set(${_out} "REPO=${P_REPO};TAG=${P_TAG};MANIFEST_SHA256=${P_MANIFEST_SHA256}" PARENT_SCOPE)
  elseif(DEFINED P_MANIFEST_HASH)
    set(${_out} "REPO=${P_REPO};TAG=${P_TAG};MANIFEST_HASH=${P_MANIFEST_HASH}" PARENT_SCOPE)
  else()
    set(${_out} "REPO=${P_REPO};TAG=${P_TAG}" PARENT_SCOPE)
  endif()
endfunction()

function(ipProDepsTrack)
  set(oneValueArgs PKG)
  set(multiValueArgs DEPS)
  cmake_parse_arguments(P "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  block(PROPAGATE depsCheckCount depsMismatchCount depsMismatchReport)
    foreach(dep ${P_DEPS})
      if(DEFINED xp_${dep} AND DEFINED xp_${dep}_${P_PKG})
        math(EXPR depsCheckCount "${depsCheckCount} + 1")
        ipProDepsKey(_pinned_key ${xp_${dep}})
        ipProDepsKey(_parent_key ${xp_${dep}_${P_PKG}})
        if(NOT "${_pinned_key}" STREQUAL "${_parent_key}")
          math(EXPR depsMismatchCount "${depsMismatchCount} + 1")
          cmake_parse_arguments(PIN "" "REPO;TAG;MANIFEST_SHA256;MANIFEST_HASH" "" ${xp_${dep}})
          cmake_parse_arguments(PAR "" "REPO;TAG;MANIFEST_SHA256;MANIFEST_HASH" "" ${xp_${dep}_${P_PKG}})
          set(_pin_sha "${PIN_MANIFEST_SHA256}")
          set(_par_sha "${PAR_MANIFEST_SHA256}")
          if("${_pin_sha}" STREQUAL "" AND DEFINED PIN_MANIFEST_HASH)
            # Extract SHA256 from MANIFEST_HASH format (SHA256=<hash>)
            if(PIN_MANIFEST_HASH MATCHES "^SHA256=(.+)$")
              set(_pin_sha "${CMAKE_MATCH_1}")
            endif()
          endif()
          if("${_par_sha}" STREQUAL "" AND DEFINED PAR_MANIFEST_HASH)
            # Extract SHA256 from MANIFEST_HASH format (SHA256=<hash>)
            if(PAR_MANIFEST_HASH MATCHES "^SHA256=(.+)$")
              set(_par_sha "${CMAKE_MATCH_1}")
            endif()
          endif()
          if(NOT "${_pin_sha}" STREQUAL "" AND NOT "${_pin_sha}" STREQUAL "1")
            string(SUBSTRING "${_pin_sha}" 0 8 _pin_sha)
          endif()
          if(NOT "${_par_sha}" STREQUAL "" AND NOT "${_par_sha}" STREQUAL "1")
            string(SUBSTRING "${_par_sha}" 0 8 _par_sha)
          endif()
          string(APPEND depsMismatchReport "- ${P_PKG} -> ${dep}<br>\n")
          string(APPEND depsMismatchReport "  pinned:   TAG=${PIN_TAG}  SHA=${_pin_sha}  REPO=${PIN_REPO}<br>\n")
          string(APPEND depsMismatchReport "  manifest: TAG=${PAR_TAG}  SHA=${_par_sha}  REPO=${PAR_REPO}<br>\n")
        endif()
      endif()
    endforeach()
  endblock()
  set(depsCheckCount "${depsCheckCount}" PARENT_SCOPE)
  set(depsMismatchCount "${depsMismatchCount}" PARENT_SCOPE)
  set(depsMismatchReport "${depsMismatchReport}" PARENT_SCOPE)
endfunction()

function(ipProDepsLoadManifest manifestFile pkg)
  if(NOT EXISTS "${manifestFile}")
    message(FATAL_ERROR "ipProDepsLoadManifest: manifest file not found: '${manifestFile}'")
  endif()
  unset(XP_MANIFEST_BASE)
  unset(XP_MANIFEST_WEB)
  unset(XP_MANIFEST_UPSTREAM)
  unset(XP_MANIFEST_DESC)
  unset(XP_MANIFEST_LICENSE)
  unset(XP_MANIFEST_XPDIFF)
  unset(XP_MANIFEST_DEPS)
  unset(XP_MANIFEST_PVT_DEPS)
  if("${manifestFile}" MATCHES "\\.manifest\\.json$")
    file(READ "${manifestFile}" _json)
    ipJsonOptionalField(XP_MANIFEST_BASE "${_json}" base)
    ipJsonOptionalField(XP_MANIFEST_WEB "${_json}" web)
    ipJsonOptionalField(XP_MANIFEST_UPSTREAM "${_json}" upstream)
    ipJsonOptionalField(XP_MANIFEST_DESC "${_json}" desc)
    ipJsonOptionalField(XP_MANIFEST_LICENSE "${_json}" license)
    ipJsonOptionalField(XP_MANIFEST_XPDIFF "${_json}" xpdiff)
    ipJsonParseDeps(XP_MANIFEST_DEPS "${_json}" deps ${pkg})
    ipJsonParseDeps(XP_MANIFEST_PVT_DEPS "${_json}" pvt_deps ${pkg})
  else()
    include("${manifestFile}")
  endif()
  if(DEFINED XP_MANIFEST_BASE AND NOT "${XP_MANIFEST_BASE}" STREQUAL "")
    set(XP_MANIFEST_BASE "${XP_MANIFEST_BASE}" PARENT_SCOPE)
  endif()
  if(DEFINED XP_MANIFEST_WEB AND NOT "${XP_MANIFEST_WEB}" STREQUAL "")
    set(XP_MANIFEST_WEB "${XP_MANIFEST_WEB}" PARENT_SCOPE)
  endif()
  if(DEFINED XP_MANIFEST_UPSTREAM AND NOT "${XP_MANIFEST_UPSTREAM}" STREQUAL "")
    set(XP_MANIFEST_UPSTREAM "${XP_MANIFEST_UPSTREAM}" PARENT_SCOPE)
  endif()
  if(DEFINED XP_MANIFEST_DESC AND NOT "${XP_MANIFEST_DESC}" STREQUAL "")
    set(XP_MANIFEST_DESC "${XP_MANIFEST_DESC}" PARENT_SCOPE)
  endif()
  if(DEFINED XP_MANIFEST_LICENSE AND NOT "${XP_MANIFEST_LICENSE}" STREQUAL "")
    set(XP_MANIFEST_LICENSE "${XP_MANIFEST_LICENSE}" PARENT_SCOPE)
  endif()
  if(DEFINED XP_MANIFEST_XPDIFF AND NOT "${XP_MANIFEST_XPDIFF}" STREQUAL "")
    set(XP_MANIFEST_XPDIFF "${XP_MANIFEST_XPDIFF}" PARENT_SCOPE)
  endif()
  if(DEFINED XP_MANIFEST_DEPS AND NOT "${XP_MANIFEST_DEPS}" STREQUAL "")
    set(XP_MANIFEST_DEPS "${XP_MANIFEST_DEPS}" PARENT_SCOPE)
  endif()
  if(DEFINED XP_MANIFEST_PVT_DEPS AND NOT "${XP_MANIFEST_PVT_DEPS}" STREQUAL "")
    set(XP_MANIFEST_PVT_DEPS "${XP_MANIFEST_PVT_DEPS}" PARENT_SCOPE)
  endif()
  # Propagate package-specific dependency variables (from either JSON parsing or CMake includes)
  foreach(dep ${XP_MANIFEST_DEPS})
    if(DEFINED xp_${dep}_${pkg})
      set(xp_${dep}_${pkg} "${xp_${dep}_${pkg}}" PARENT_SCOPE)
    endif()
  endforeach()
  foreach(dep ${XP_MANIFEST_PVT_DEPS})
    if(DEFINED xp_${dep}_${pkg})
      set(xp_${dep}_${pkg} "${xp_${dep}_${pkg}}" PARENT_SCOPE)
    endif()
  endforeach()
endfunction()

function(ipProDepsRow)
  set(oneValueArgs PKG REPO TAG MANIFEST_SHA256 DIST_DIR XPRO_PATH MANIFEST_FILE OUT_DEPS)
  set(multiValueArgs MANIFEST_HASH)
  cmake_parse_arguments(P "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  block(PROPAGATE deps dot rme depsCheckCount depsMismatchCount depsMismatchReport)
    # manifest
    if((DEFINED P_MANIFEST_SHA256 OR DEFINED P_MANIFEST_HASH) AND DEFINED P_REPO AND DEFINED P_TAG)
      ipDownloadManifestFromRepo(dst REPO ${P_REPO} TAG ${P_TAG} MANIFEST_SHA256 ${P_MANIFEST_SHA256} MANIFEST_HASH ${P_MANIFEST_HASH})
      ipProDepsLoadManifest(${dst} ${P_PKG})
    endif()
    if(DEFINED P_MANIFEST_FILE AND EXISTS ${P_MANIFEST_FILE})
      ipProDepsLoadManifest(${P_MANIFEST_FILE} ${P_PKG})
    endif()
    # track dependencies
    set(deps ${XP_MANIFEST_DEPS} ${XP_MANIFEST_PVT_DEPS})
    ipProDepsTrack(PKG ${P_PKG} DEPS ${deps})
    # dot
    foreach(dep ${XP_MANIFEST_DEPS})
      string(APPEND dot "  \"${P_PKG}\" -> \"${dep}\";\n")
    endforeach()
    foreach(dep ${XP_MANIFEST_PVT_DEPS})
      string(APPEND dot "  \"${P_PKG}\" -> \"${dep}\" [style=dashed];\n")
    endforeach()
    # README project
    if(DEFINED XP_MANIFEST_WEB)
      string(APPEND rme "|<a id='${P_PKG}' />[${P_PKG}](${XP_MANIFEST_WEB})")
    else()
      string(APPEND rme "|<a id='${P_PKG}' />${P_PKG}")
    endif()
    # README license
    if(DEFINED XP_MANIFEST_LICENSE)
      string(APPEND rme "|${XP_MANIFEST_LICENSE}")
    else()
      string(APPEND rme "| ")
    endif()
    # README description [dependencies]
    if(DEFINED XP_MANIFEST_DESC)
      string(APPEND rme "|${XP_MANIFEST_DESC}")
      if(DEFINED XP_MANIFEST_DEPS)
        list(JOIN XP_MANIFEST_DEPS ", " deps_str)
        string(APPEND rme " [deps: _${deps_str}_]")
      endif()
      if(DEFINED XP_MANIFEST_PVT_DEPS)
        list(JOIN XP_MANIFEST_PVT_DEPS ", " deps_str)
        string(APPEND rme " [pvt deps: _${deps_str}_]")
      endif()
    else()
      string(APPEND rme "| ")
    endif()
    # README version
    if(DEFINED P_REPO AND DEFINED P_TAG)
      string(APPEND rme "|[${P_TAG}](https://${P_REPO}/releases/tag/${P_TAG} 'release')")
    else()
      string(APPEND rme "| ")
    endif()
    # README source
    if(DEFINED P_REPO)
      string(APPEND rme "|[repo](https://${P_REPO} '${P_REPO}')")
      if(DEFINED XP_MANIFEST_UPSTREAM)
        string(APPEND rme " [upstream](https://${XP_MANIFEST_UPSTREAM} '${XP_MANIFEST_UPSTREAM}')")
      endif()
    elseif(DEFINED XP_MANIFEST_UPSTREAM)
      string(APPEND rme "|[upstream](https://${XP_MANIFEST_UPSTREAM} '${XP_MANIFEST_UPSTREAM}')")
    else()
      string(APPEND rme "| ")
    endif()
    # README diff
    if(DEFINED P_REPO AND DEFINED XP_MANIFEST_BASE AND DEFINED P_TAG)
      string(APPEND rme "|[diff](https://${P_REPO}/compare/${XP_MANIFEST_BASE}...${P_TAG} '${P_REPO}/compare/${XP_MANIFEST_BASE}...${P_TAG}')")
    else()
      string(APPEND rme "| ")
    endif()
    # append XPDIFF to 'diff' cell
    if(DEFINED XP_MANIFEST_XPDIFF)
      string(APPEND rme " [${XP_MANIFEST_XPDIFF}]")
    endif()
    set(rme "${rme}|\n")
  endblock()
  if(DEFINED P_OUT_DEPS)
    set(${P_OUT_DEPS} "${deps}" PARENT_SCOPE)
  endif()
  set(dot "${dot}" PARENT_SCOPE)
  set(rme "${rme}" PARENT_SCOPE)
  set(depsCheckCount "${depsCheckCount}" PARENT_SCOPE)
  set(depsMismatchCount "${depsMismatchCount}" PARENT_SCOPE)
  set(depsMismatchReport "${depsMismatchReport}" PARENT_SCOPE)
endfunction()

function(ipProDepsWalk)
  set(oneValueArgs PKG MANIFEST_FILE)
  cmake_parse_arguments(P "" "${oneValueArgs}" "" ${ARGN})
  set(visited)
  set(queue)
  list(APPEND visited "${P_PKG}")
  # seed with the root package first
  set(root_deps)
  ipProDepsRow(OUT_DEPS root_deps PKG ${P_PKG} MANIFEST_FILE ${P_MANIFEST_FILE})
  foreach(dep ${root_deps})
    list(APPEND queue "${P_PKG}|${dep}")
  endforeach()
  while(queue)
    list(POP_FRONT queue item)
    string(REPLACE "|" ";" itemParts "${item}")
    list(GET itemParts 0 parent)
    list(GET itemParts 1 dep)
    list(FIND visited "${dep}" idx)
    if(NOT idx EQUAL -1)
      continue()
    endif()
    list(APPEND visited "${dep}")
    unset(_spec)
    if(DEFINED xp_${dep})
      set(_spec ${xp_${dep}})
    elseif(DEFINED xp_${dep}_${parent})
      set(_spec ${xp_${dep}_${parent}})
    endif()
    if(DEFINED _spec)
      set(child_deps)
      ipProDepsRow(OUT_DEPS child_deps PKG ${dep} ${_spec})
      if(child_deps)
        foreach(ch ${child_deps})
          list(APPEND queue "${dep}|${ch}")
        endforeach()
      endif()
    endif()
  endwhile()
  set(dot "${dot}" PARENT_SCOPE)
  set(rme "${rme}" PARENT_SCOPE)
  set(depsCheckCount "${depsCheckCount}" PARENT_SCOPE)
  set(depsMismatchCount "${depsMismatchCount}" PARENT_SCOPE)
  set(depsMismatchReport "${depsMismatchReport}" PARENT_SCOPE)
endfunction()

function(ipProDepsEnd)
  string(APPEND dot "}\n")
  if(NOT DEFINED xpdepsDot)
    set(xpdepsDot ${CMAKE_CURRENT_BINARY_DIR}/xprodeps.dot)
  endif()
  file(WRITE ${xpdepsDot} "${dot}")
  find_program(XP_DOT_PATH "dot")
  mark_as_advanced(XP_DOT_PATH)
  if(XP_DOT_PATH AND EXISTS ${xpdepsDot} AND DEFINED xpdepsGraph)
    cmake_path(GET xpdepsGraph EXTENSION LAST_ONLY ext) # ext like ".svg"
    string(SUBSTRING "${ext}" 1 -1 fmt) # fmt like "svg"
    string(TOLOWER "${fmt}" fmt)
    execute_process(COMMAND ${XP_DOT_PATH} -T${fmt} -o ${xpdepsGraph} ${xpdepsDot})
    cmake_path(GET xpdepsGraph FILENAME fname)
    string(JOIN "\n" rmeGraph
      ""
      "![deps](${fname} 'dependencies')"
      ""
      )
    string(APPEND rme "${rmeGraph}")
  endif()
  if(DEFINED depsCheckCount AND depsCheckCount GREATER 0)
    if(DEFINED depsMismatchCount AND depsMismatchCount EQUAL 0)
      string(APPEND rme "\nDependency version check: all ${depsCheckCount} parent-manifest versions match pinned versions.\n")
    elseif(NOT "${depsMismatchReport}" STREQUAL "")
      string(APPEND rme "\nDependency version mismatches (pinned vs parent manifest):\n${depsMismatchReport}\n")
    endif()
  endif()
  string(JOIN "\n" footer
    ""
    "|diff  |description|"
    "|------|-----------|"
    "|patch |diff modifies/patches existing cmake|"
    "|intro |diff introduces cmake|"
    "|auto  |diff adds cmake to replace autotools/configure/make|"
    "|native|diff adds cmake but uses existing build system|"
    "|bin   |diff adds cmake to repackage binaries built elsewhere|"
    "|fetch |diff adds cmake and utilizes FetchContent|"
    ""
    "[^_l]: see [SPDX License List](https://spdx.org/licenses/ '') for a list of commonly found licenses"
    "[^_d]: see table above with description of diff"
    ""
    )
  string(APPEND rme "${footer}")
  if(DEFINED xpdepsFile)
    file(APPEND ${xpdepsFile} "${rme}")
  endif()
endfunction()

function(xpHostnameMatches hname boolVar)
  set(matches FALSE)
  if(NOT "${hname}" STREQUAL "")
    find_program(hostnameCmd hostname)
    if(hostnameCmd)
      execute_process(
        COMMAND ${hostnameCmd}
        RESULT_VARIABLE rc
        OUTPUT_VARIABLE hostnameOut
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )
      if(rc EQUAL 0 AND NOT "${hostnameOut}" STREQUAL "" AND "${hostnameOut}" MATCHES "${hname}")
        set(matches TRUE)
      endif()
    endif()
  endif()
  set(${boolVar} ${matches} PARENT_SCOPE)
endfunction()

function(xpFilesDifferent file1 file2 boolDiff)
  set(isDiff FALSE)
  if(EXISTS ${file1})
    file(SHA256 ${file1} file1Hash)
  else()
    set(file1Hash 1)
  endif()
  if(EXISTS ${file2})
    file(SHA256 ${file2} file2Hash)
  else()
    set(file2Hash 2)
  endif()
  if(NOT file1Hash STREQUAL file2Hash)
    set(isDiff TRUE)
  endif()
  set(${boolDiff} ${isDiff} PARENT_SCOPE)
endfunction()

function(xpCopyFilesToSrc readme graph)
  # linux is the only platform where we can ensure graphviz
  # (dot executable) is available, both locally and in CI, so
  # only copy files to source directory with linux build
  # container used by update-externpro workflow
  set(build_container "rocky9-gcc13")
  xpHostnameMatches(${build_container} copyToSrc)
  xpFilesDifferent(${xpdepsFile} ${readme} isRdmeDiff)
  xpFilesDifferent(${xpdepsGraph} ${graph} isGraphDiff)
  if(copyToSrc)
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different ${xpdepsFile} ${readme})
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different ${xpdepsGraph} ${graph})
  elseif(isRdmeDiff OR isGraphDiff)
    option(XP_COPY_FILES_TO_SRC_NOTE "Emit NOTE when README.md/deps.svg differ but can only be copied to source in the build container" ON)
    if(XP_COPY_FILES_TO_SRC_NOTE)
      message(STATUS "NOTE: files in binary and source directory differ, "
        "but should be copied from binary to source directory in ${build_container} "
        "build container, where graphviz is installed and version controlled. "
        "(graphviz version is recorded in .svg file and different versions generate other diffs too). "
        "Silence with -DXP_COPY_FILES_TO_SRC_NOTE=OFF."
        )
      if(isRdmeDiff)
        cmake_path(RELATIVE_PATH xpdepsFile BASE_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE relXpdepsFile)
        cmake_path(RELATIVE_PATH readme BASE_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE relSrcRdme)
        message(STATUS "  * ${relXpdepsFile} -> ${relSrcRdme}")
      endif()
      if(isGraphDiff)
        cmake_path(RELATIVE_PATH xpdepsGraph BASE_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE relXpdepsGraph)
        cmake_path(RELATIVE_PATH graph BASE_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE relSrcGraph)
        message(STATUS "  * ${relXpdepsGraph} -> ${relSrcGraph}")
      endif()
    endif()
  endif()
endfunction()

function(xpProDeps)
  set(xpdepsFile ${CMAKE_CURRENT_BINARY_DIR}/README.md)
  set(xpdepsGraph ${CMAKE_CURRENT_BINARY_DIR}/deps.svg)
  # https://stackoverflow.com/q/9298278/
  get_cmake_property(pros VARIABLES)
  # xp_ variables from pros.cmake, included by xproinc.cmake
  list(FILTER pros INCLUDE REGEX "^xp_")
  list(SORT pros)
  ipProDepsInit()
  message(STATUS "Downloading manifest files for all externpro dependencies...")
  foreach(pro ${pros})
    string(REGEX REPLACE "^xp_" "" pkg ${pro})
    ipProDepsRow(PKG ${pkg} ${${pro}})
  endforeach()
  ipProDepsEnd()
  xpCopyFilesToSrc(${xpThisDir}/README.md ${xpThisDir}/deps.svg)
endfunction()

function(ipJsonOptionalField _out _json _field)
  string(JSON _value ERROR_VARIABLE _err GET "${_json}" ${_field})
  if(NOT "${_err}" STREQUAL "" AND "${_value}" STREQUAL "")
    # Only error if we have an error AND the result is empty
  elseif(NOT "${_value}" STREQUAL "null")
    set(${_out} "${_value}" PARENT_SCOPE)
  endif()
endfunction()

function(ipJsonOptionalString _out _var)
  if(DEFINED ${_var})
    set(_t "${${_var}}")
    string(REPLACE "\\" "\\\\" _t "${_t}")
    string(REPLACE "\"" "\\\"" _t "${_t}")
    set(${_out} "\"${_t}\"" PARENT_SCOPE)
  else()
    set(${_out} "null" PARENT_SCOPE)
  endif()
endfunction()

function(ipJsonParseDeps _out_deps _json _deps_field pkg)
  set(_deps_list)
  string(JSON _len ERROR_VARIABLE _deps_err LENGTH "${_json}" ${_deps_field})
  if(NOT "${_deps_err}" STREQUAL "" AND "${_len}" STREQUAL "")
    # Only error if we have an error AND the result is empty
  elseif(NOT "${_len}" STREQUAL "0")
    math(EXPR _last "${_len} - 1")
    foreach(i RANGE 0 ${_last})
      string(JSON _dep_obj ERROR_VARIABLE _dep_err GET "${_json}" ${_deps_field} ${i})
      if(NOT "${_dep_err}" STREQUAL "" AND "${_dep_obj}" STREQUAL "")
        # Only skip if there's an error AND the result is empty
        continue()
      else()
        # Parse dependency object
        string(JSON _dep_name ERROR_VARIABLE _name_err GET "${_dep_obj}" name)
        if(NOT "${_name_err}" STREQUAL "" AND "${_dep_name}" STREQUAL "")
          continue()
        endif()
        list(APPEND _deps_list "${_dep_name}")
        # Create package-specific dependency variable for version checking
        string(JSON _dep_repo ERROR_VARIABLE _repo_err GET "${_dep_obj}" repo)
        string(JSON _dep_tag ERROR_VARIABLE _tag_err GET "${_dep_obj}" tag)
        string(JSON _dep_sha ERROR_VARIABLE _sha_err GET "${_dep_obj}" manifest_sha256)
        # Set defaults if fields are missing (only if there's an error AND the result is empty)
        if(NOT "${_repo_err}" STREQUAL "" AND "${_dep_repo}" STREQUAL "")
          set(_dep_repo "")
        endif()
        if(NOT "${_tag_err}" STREQUAL "" AND "${_dep_tag}" STREQUAL "")
          set(_dep_tag "")
        endif()
        if(NOT "${_sha_err}" STREQUAL "" AND "${_dep_sha}" STREQUAL "")
          set(_dep_sha "")
        endif()
        # Check if the original dependency used MANIFEST_SHA256 or MANIFEST_HASH
        if(DEFINED xp_${_dep_name})
          cmake_parse_arguments(DEP "" "REPO;TAG;MANIFEST_SHA256;MANIFEST_HASH" "" ${xp_${_dep_name}})
          if(DEFINED DEP_MANIFEST_SHA256)
            set(xp_${_dep_name}_${pkg} "REPO;${_dep_repo};TAG;${_dep_tag};MANIFEST_SHA256;${_dep_sha}" PARENT_SCOPE)
          elseif(DEFINED DEP_MANIFEST_HASH)
            set(xp_${_dep_name}_${pkg} "REPO;${_dep_repo};TAG;${_dep_tag};MANIFEST_HASH;SHA256=${_dep_sha}" PARENT_SCOPE)
          else()
            # Default to MANIFEST_SHA256 for backwards compatibility
            set(xp_${_dep_name}_${pkg} "REPO;${_dep_repo};TAG;${_dep_tag};MANIFEST_SHA256;${_dep_sha}" PARENT_SCOPE)
          endif()
        else()
          # Default to MANIFEST_SHA256 if xp_${_dep_name} is not defined
          set(xp_${_dep_name}_${pkg} "REPO;${_dep_repo};TAG;${_dep_tag};MANIFEST_SHA256;${_dep_sha}" PARENT_SCOPE)
        endif()
      endif()
    endforeach()
  endif()
  set(${_out_deps} "${_deps_list}" PARENT_SCOPE)
endfunction()

function(ipManifestDepsFromVarsJson _out deps)
  set(_deps_json "[]")
  if(DEFINED deps)
    foreach(dep ${deps})
      if(NOT DEFINED xp_${dep})
        message(FATAL_ERROR "ipManifestDepsFromVarsJson: 'xp_${dep}' is not defined")
      endif()
      # Parse the dependency information
      cmake_parse_arguments(DEP "" "REPO;TAG;MANIFEST_SHA256;MANIFEST_HASH" "" ${xp_${dep}})
      # Create a JSON object with dependency version info
      set(_dep_json "{")
      string(APPEND _dep_json "\"name\": \"${dep}\"")
      if(DEFINED DEP_REPO)
        string(APPEND _dep_json ", \"repo\": \"${DEP_REPO}\"")
      endif()
      if(DEFINED DEP_TAG)
        string(APPEND _dep_json ", \"tag\": \"${DEP_TAG}\"")
      endif()
      if(DEFINED DEP_MANIFEST_SHA256)
        string(APPEND _dep_json ", \"manifest_sha256\": \"${DEP_MANIFEST_SHA256}\"")
      elseif(DEFINED DEP_MANIFEST_HASH)
        # Extract SHA256 from MANIFEST_HASH format (SHA256=<hash>)
        if(DEP_MANIFEST_HASH MATCHES "^SHA256=(.+)$")
          string(APPEND _dep_json ", \"manifest_sha256\": \"${CMAKE_MATCH_1}\"")
        endif()
      endif()
      string(APPEND _dep_json "}")
      string(JSON _len LENGTH "${_deps_json}")
      string(JSON _deps_json SET "${_deps_json}" ${_len} "${_dep_json}")
    endforeach()
  endif()
  set(${_out} "${_deps_json}" PARENT_SCOPE)
endfunction()

function(ipManifestDepsFromVarsCMake _out deps)
  foreach(dep ${deps})
    if(NOT DEFINED xp_${dep})
      message(FATAL_ERROR "ipManifestDepsFromVars: 'xp_${dep}' is not defined")
    endif()
    string(REPLACE ";" " " xp_${dep} "${xp_${dep}}")
    string(REPLACE " MANIFEST" "\n  MANIFEST" xp_${dep} "${xp_${dep}}")
    set(out "${out}set(xp_${dep}_${P_REPO_NAME} ${xp_${dep}}\n  )\n")
  endforeach()
  set(${_out} "${out}" PARENT_SCOPE)
endfunction()

function(xpExternPackage)
  # NOTE: if CMAKE_INSTALL_CMAKEDIR is not defined, it will be set here
  #   and available in PARENT_SCOPE
  set(opts CREATE_ALIASES FIND_THREADS)
  # CREATE_ALIASES is an optional parameter to indicate ALIAS targets should be
  #   created with hard-coded 'xpro' namespace for EXE and LIBRARIES
  # FIND_THREADS is an optional parameter to indicate the use script
  #   should find the Threads::Threads target (from Threads package)
  set(oneValueArgs ALIAS_NAMESPACE COMPONENT EXE EXE_PATH EXPORT NAMESPACE REPO_NAME TARGETS_FILE)
  # ALIAS_NAMESPACE is deprecated; now hard-coded internally to 'xpro' as an alternative
  #   CMake namespace. add_[executable|library] ALIAS[es] will be included in the use script
  #   for EXE and LIBRARIES when CREATE_ALIASES option is specified
  # COMPONENT is for CPack/install component name (optional, used if project has COMPONENTs)
  # EXE is for a CMake executable target name; included in the use script
  # EXE_PATH is for executable path (relative to package root, alternative to EXE)
  #   useful when the executable is not a CMake target, e.g. a binary built
  #   elsewhere; included in the use script
  # EXPORT is for export name used in install(PACKAGE_INFO) and install(SBOM) commands
  #   if not specified, defaults to TARGETS_FILE value
  # NAMESPACE is deprecated; CMAKE_PROJECT_NAME (or REPO_NAME if specified) is now
  #   prepended to CMake target names EXE and LIBRARIES in the use script
  # REPO_NAME is for repository name; if repository name doesn't match
  #   CMAKE_PROJECT_NAME (case sensitive), use REPO_NAME parameter to specify it
  # TARGETS_FILE is for targets file name (see EXPORT parameter of install() command)
  #   the targets file is included in the use script
  list(APPEND oneValueArgs ATTRIBUTION BASE DESC LICENSE UPSTREAM WEB XPDIFF)
  ### manifest - values that will be included in the generated manifest.cmake file
  # ATTRIBUTION is for attribution text that should be included in the manifest;
  #  some projects may not have attribution text, in which case this parameter
  #  should be left undefined
  # BASE is to specify the base git tag that commits were made on top of;
  #  this is often an upstream release tag and the commits are usually mostly
  #  externpro-related
  # DESC is for a short project description
  # LICENSE is for license information
  # UPSTREAM is for upstream repository URL
  # WEB is for project website URL
  # XPDIFF describes the type of diff (patch/intro/auto/native/bin/fetch)
  #  from the BASE tag to the current tag (externpro-related diff)
  #    patch: diff modifies/patches existing cmake
  #    intro: diff introduces cmake
  #     auto: diff adds cmake to replace autotools/configure/make
  #   native: diff adds cmake but uses existing build system
  #      bin: diff adds cmake to repackage binaries built elsewhere
  #    fetch: diff adds cmake and utilizes FetchContent
  set(multiValueArgs DEFAULT_TARGETS DEPS LIBRARIES PVT_DEPS)
  # DEFAULT_TARGETS are for default CMake targets; passed to install(PACKAGE_INFO)
  # DEPS are for library dependencies; leveraged by use script and manifest
  # LIBRARIES are for CMake library targets; included in the use script
  # PVT_DEPS are for private dependencies (often an executable or internal
  #   dependency); part of manifest and NOT part of use script (a project
  #   may have private dependencies that don't need to be found by projects
  #   that use the project that has private dependencies)
  cmake_parse_arguments(P "${opts}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  if(DEFINED P_ALIAS_NAMESPACE)
    message(AUTHOR_WARNING "xpExternPackage: ALIAS_NAMESPACE parameter is deprecated and ignored. Use CREATE_ALIASES option to create 'xpro' aliases instead.")
  endif()
  if(DEFINED P_NAMESPACE)
    message(AUTHOR_WARNING "xpExternPackage: NAMESPACE parameter is deprecated and ignored. Using package name as namespace instead.")
  endif()
  # Set P_EXPORT to P_TARGETS_FILE if P_EXPORT is not defined
  if(NOT DEFINED P_EXPORT)
    if(DEFINED P_TARGETS_FILE)
      set(P_EXPORT ${P_TARGETS_FILE})
    endif()
  endif()
  if(DEFINED P_COMPONENT)
    set(XP_COMPONENT COMPONENT ${P_COMPONENT})
    set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
    set(CPACK_COMPONENT_INCLUDE_TOPLEVEL_DIRECTORY ON)
    list(APPEND CPACK_COMPONENTS_ALL ${P_COMPONENT})
  endif()
  if(NOT DEFINED P_REPO_NAME)
    set(P_REPO_NAME ${CMAKE_PROJECT_NAME})
  endif()
  set(P_NAMESPACE ${P_REPO_NAME})
  set(P_ALIAS_NAMESPACE xpro) # hard-coded alias namespace
  xpGetVersionString(VER)
  set(xproBinDir "${CMAKE_CURRENT_BINARY_DIR}/xpro")
  file(MAKE_DIRECTORY "${xproBinDir}")
  ###############
  # use script
  string(TOUPPER ${P_REPO_NAME} ucRepoName)
  string(TOLOWER ${P_REPO_NAME} lcRepoName)
  if(DEFINED P_DEPS)
    list(JOIN P_DEPS " " deps) # list to string with spaces
    set(FIND_DEPS "xpFindPkg(PKGS ${deps}) # dependencies\n")
  endif()
  if(P_FIND_THREADS)
    string(JOIN "\n" FIND_THREADS
      "set(THREAD_PREFER_PTHREAD_FLAG ON)"
      "find_package(Threads REQUIRED) # depends on Threads::Threads"
      ""
      )
  endif()
  if(DEFINED P_TARGETS_FILE)
    set(TARGETS_FILE "include(\${CMAKE_CURRENT_LIST_DIR}/${P_TARGETS_FILE}.cmake)\n")
  endif()
  if(DEFINED P_LIBRARIES)
    if(P_CREATE_ALIASES)
      foreach(lib ${P_LIBRARIES})
        string(JOIN "\n" alias
          "if(NOT TARGET ${P_ALIAS_NAMESPACE}::${lib})"
          "  add_library(${P_ALIAS_NAMESPACE}::${lib} ALIAS ${P_NAMESPACE}::${lib})"
          "endif()"
          ""
          )
        set(ALIASES ${ALIASES}${alias})
      endforeach()
    endif()
    list(TRANSFORM P_LIBRARIES PREPEND "${P_NAMESPACE}::")
    list(JOIN P_LIBRARIES " " libs) # list to string with spaces
    string(JOIN "\n" LIBS
      "set(${ucRepoName}_LIBRARIES ${libs})"
      "list(APPEND reqVars ${ucRepoName}_LIBRARIES)"
      ""
      )
  endif()
  if(DEFINED P_EXE)
    if(DEFINED P_EXE_PATH)
      message(FATAL_ERROR "xpExternPackage: can only define EXE or EXE_PATH, not both")
    endif()
    if(P_CREATE_ALIASES)
      string(JOIN "\n" alias
        "if(NOT TARGET ${P_ALIAS_NAMESPACE}::${P_EXE})"
        "  add_executable(${P_ALIAS_NAMESPACE}::${P_EXE} ALIAS ${P_NAMESPACE}::${P_EXE})"
        "endif()"
        ""
        )
      set(ALIASES ${ALIASES}${alias})
    endif()
    string(PREPEND P_EXE "${P_NAMESPACE}::")
    string(JOIN "\n" EXE
      "set(${ucRepoName}_EXE ${P_EXE})"
      "list(APPEND reqVars ${ucRepoName}_EXE)"
      ""
      )
  elseif(DEFINED P_EXE_PATH)
    string(JOIN "\n" EXE
      "get_filename_component(PKG_ROOTDIR \${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)"
      "get_filename_component(PKG_ROOTDIR \${PKG_ROOTDIR} ABSOLUTE) # remove relative parts"
      "set(${ucRepoName}_EXE \${PKG_ROOTDIR}/${P_EXE_PATH}${CMAKE_EXECUTABLE_SUFFIX})"
      "list(APPEND reqVars ${ucRepoName}_EXE)"
      ""
      )
  endif()
  set(xpUseCMakeFile ${xproBinDir}/${lcRepoName}-config.cmake)
  configure_file(${xpThisDir}/xpuse.cmake.in ${xpUseCMakeFile} @ONLY NEWLINE_STYLE LF)
  ###############
  # manifest.cmake file
  # NOTE: metadata in manifest file is consistent across all platforms
  if(DEFINED P_ATTRIBUTION)
    set(MANIFEST_VARS "${MANIFEST_VARS}\nset(XP_MANIFEST_ATTRIBUTION \"${P_ATTRIBUTION}\")")
  endif()
  if(DEFINED P_BASE)
    set(MANIFEST_VARS "${MANIFEST_VARS}\nset(XP_MANIFEST_BASE ${P_BASE})")
  endif()
  if(DEFINED P_DESC)
    set(MANIFEST_VARS "${MANIFEST_VARS}\nset(XP_MANIFEST_DESC \"${P_DESC}\")")
  endif()
  if(DEFINED P_LICENSE)
    set(MANIFEST_VARS "${MANIFEST_VARS}\nset(XP_MANIFEST_LICENSE \"${P_LICENSE}\")")
  endif()
  if(DEFINED P_UPSTREAM)
    set(MANIFEST_VARS "${MANIFEST_VARS}\nset(XP_MANIFEST_UPSTREAM \"${P_UPSTREAM}\")")
  endif()
  if(DEFINED P_WEB)
    set(MANIFEST_VARS "${MANIFEST_VARS}\nset(XP_MANIFEST_WEB \"${P_WEB}\")")
  endif()
  if(DEFINED P_XPDIFF)
    set(MANIFEST_VARS "${MANIFEST_VARS}\nset(XP_MANIFEST_XPDIFF \"${P_XPDIFF}\")")
  endif()
  if(DEFINED P_DEPS)
    ipManifestDepsFromVarsCMake(MANIFEST_DEPS "${P_DEPS}")
    list(JOIN P_DEPS " " deps) # list to string with spaces
    set(MANIFEST_VARS "${MANIFEST_VARS}\nset(XP_MANIFEST_DEPS ${deps})")
  endif()
  if(DEFINED P_PVT_DEPS)
    ipManifestDepsFromVarsCMake(MANIFEST_PVT_DEPS "${P_PVT_DEPS}")
    set(MANIFEST_DEPS "${MANIFEST_DEPS}${MANIFEST_PVT_DEPS}")
    list(JOIN P_PVT_DEPS " " pvtdeps) # list to string with spaces
    set(MANIFEST_VARS "${MANIFEST_VARS}\nset(XP_MANIFEST_PVT_DEPS ${pvtdeps})")
  endif()
  set(xpManifestCMakeFile ${xproBinDir}/${P_REPO_NAME}-${VER}.manifest.cmake)
  file(WRITE ${xpManifestCMakeFile}
    "set(XP_MANIFEST_VERSION 1)\n"
    "set(XP_MANIFEST_REPO \"${P_REPO_NAME}\")\n"
    "set(XP_MANIFEST_TAG \"${VER}\")\n"
    "${MANIFEST_VARS}\n"
    "${MANIFEST_DEPS}\n"
    "set(XP_MANIFEST_ARTIFACTS)\n"
    )
  ###############
  # manifest.json file
  # NOTE: metadata in manifest file is consistent across all platforms
  ipJsonOptionalString(_mj_attr P_ATTRIBUTION)
  ipJsonOptionalString(_mj_base P_BASE)
  ipJsonOptionalString(_mj_desc P_DESC)
  ipJsonOptionalString(_mj_lic P_LICENSE)
  ipJsonOptionalString(_mj_up P_UPSTREAM)
  ipJsonOptionalString(_mj_web P_WEB)
  ipJsonOptionalString(_mj_xpd P_XPDIFF)
  ipManifestDepsFromVarsJson(_mj_deps "${P_DEPS}")
  ipManifestDepsFromVarsJson(_mj_pvt_deps "${P_PVT_DEPS}")
  set(xpManifestJsonFile ${xproBinDir}/${P_REPO_NAME}-${VER}.manifest.json)
  file(WRITE ${xpManifestJsonFile}
    "{\n"
    "  \"manifest_version\": 1,\n"
    "  \"repo\": \"${P_REPO_NAME}\",\n"
    "  \"tag\": \"${VER}\",\n"
    "  \"base\": ${_mj_base},\n"
    "  \"web\": ${_mj_web},\n"
    "  \"upstream\": ${_mj_up},\n"
    "  \"desc\": ${_mj_desc},\n"
    "  \"license\": ${_mj_lic},\n"
    "  \"xpdiff\": ${_mj_xpd},\n"
    "  \"attribution\": ${_mj_attr},\n"
    "  \"deps\": ${_mj_deps},\n"
    "  \"pvt_deps\": ${_mj_pvt_deps},\n"
    "  \"artifacts\": []\n"
    "}\n"
    )
  ###############
  # sysinfo.txt file
  # NOTE: metadata in sysinfo file is different depending on platform
  set(xpSysinfoFile ${xproBinDir}/sysinfo.txt)
  file(WRITE ${xpSysinfoFile} "${VER}\n")
  execute_process(COMMAND uname -a
    OUTPUT_VARIABLE uname
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_VARIABLE unameErr
    )
  if(NOT unameErr)
    file(APPEND ${xpSysinfoFile} "${uname}\n")
  endif()
  execute_process(COMMAND lsb_release --description
    OUTPUT_VARIABLE lsbDesc # LSB (Linux Standard Base)
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
    )
  if(NOT lsbDesc STREQUAL "")
    file(APPEND ${xpSysinfoFile} "lsb_release ${lsbDesc}\n")
  endif()
  if(DEFINED MSVC_VERSION)
    file(APPEND ${xpSysinfoFile} "MSVC_VERSION ${MSVC_VERSION}\n")
  endif()
  xpGetCompilerPrefix(compilerPrefix)
  file(APPEND ${xpSysinfoFile} "COMPILER_PREFIX: ${compilerPrefix}\n")
  ###############
  # xpdeps files
  if(DEFINED P_DEPS OR DEFINED P_PVT_DEPS)
    set(xpdepsFile ${xproBinDir}/xprodeps.md)
    set(xpdepsGraph ${xproBinDir}/xprodeps.svg)
    ipProDepsInit()
    ipProDepsWalk(PKG ${P_REPO_NAME} MANIFEST_FILE ${xpManifestJsonFile})
    ipProDepsEnd()
    xpCopyFilesToSrc(${CMAKE_SOURCE_DIR}/xprodeps.md ${CMAKE_SOURCE_DIR}/xprodeps.svg)
  endif()
  ###############
  # install sysinfo.txt, ${lcRepoName}-config.cmake, and manifest.cmake
  install(FILES ${xpSysinfoFile} DESTINATION ${CMAKE_INSTALL_DATADIR} ${XP_COMPONENT})
  if(NOT DEFINED CMAKE_INSTALL_DATADIR)
    include(GNUInstallDirs)
  endif()
  if(NOT DEFINED CMAKE_INSTALL_CMAKEDIR)
    # NOTE: if your project is overriding CMAKE_INSTALL_CMAKEDIR
    # be aware that xpFindPkg() expects to find <pkg>-config.cmake
    # in ${XPRO_DIR}/xpx/${pkgbase}[-xpro]/share/cmake
    set(CMAKE_INSTALL_CMAKEDIR ${CMAKE_INSTALL_DATADIR}/cmake)
    set(CMAKE_INSTALL_CMAKEDIR ${CMAKE_INSTALL_CMAKEDIR} PARENT_SCOPE)
  endif()
  install(FILES ${xpUseCMakeFile} ${xpManifestCMakeFile}
    DESTINATION ${CMAKE_INSTALL_CMAKEDIR} ${XP_COMPONENT}
    )
  ###############
  # CPS/SBOM: package metadata
  set(xpInfoProject)
  if(NOT "${P_REPO_NAME}" STREQUAL "${CMAKE_PROJECT_NAME}")
    # By default, if the specified <package-name> matches the current CMake PROJECT_NAME,
    # package metadata will be inherited from the project. The PROJECT <project-name>
    # option may be used to specify a different project from which to inherit metadata.
    # In any case, any metadata values specified in the install command will take precedence.
    set(xpInfoProject PROJECT ${CMAKE_PROJECT_NAME})
  endif()
  string(REGEX REPLACE "^xpv" "" xpInfoVerCandidate "${VER}")
  string(REGEX REPLACE "-[0-9]+-g[0-9a-f]+(-.*)?$" "" xpInfoVerCandidate "${xpInfoVerCandidate}")
  string(REGEX REPLACE "[^0-9.]" "" xpInfoVerCandidate "${xpInfoVerCandidate}")
  set(xpInfoVersion VERSION ${xpInfoVerCandidate})
  if(DEFINED P_DESC)
    set(xpInfoDesc DESCRIPTION "${P_DESC}")
  endif()
  if(DEFINED P_WEB)
    set(xpInfoHome HOMEPAGE_URL "${P_WEB}")
  endif()
  if(DEFINED P_LICENSE)
    if(P_LICENSE MATCHES "^\\[[^]]+\\]\\([^)]+\\)$")
      set(xpInfoLicenseCandidate "${P_LICENSE}")
      string(REGEX REPLACE "^\\[([^]]+)\\]\\([^)]+\\)$" "\\1" xpInfoLicenseCandidate "${xpInfoLicenseCandidate}")
      if(NOT xpInfoLicenseCandidate STREQUAL "")
        set(xpInfoLicense LICENSE "${xpInfoLicenseCandidate}")
      endif()
    endif()
  endif()
  ###############
  # CPS: common package specification
  if(NOT DEFINED CMAKE_INSTALL_CPSDIR)
    set(CMAKE_INSTALL_CPSDIR ${CMAKE_INSTALL_DATADIR}/cps)
  endif()
  install(FILES ${xpManifestJsonFile}
    DESTINATION ${CMAKE_INSTALL_CPSDIR} ${XP_COMPONENT}
    )
  if(DEFINED P_DEFAULT_TARGETS)
    set(xpInfoDefaultTargets DEFAULT_TARGETS ${P_DEFAULT_TARGETS})
  endif()
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 4.3 AND DEFINED P_EXPORT)
    install(PACKAGE_INFO ${P_REPO_NAME} EXPORT ${P_EXPORT}
      ${xpInfoProject} ${xpInfoVersion} ${xpInfoDefaultTargets}
      ${xpInfoLicense} ${xpInfoDesc} ${xpInfoHome}
      DESTINATION ${CMAKE_INSTALL_CPSDIR} ${XP_COMPONENT}
      )
  endif()
  ###############
  # SBOM: software bill of materials
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 4.3 AND DEFINED P_EXPORT)
    if(CMAKE_EXPERIMENTAL_GENERATE_SBOM STREQUAL "ca494ed3-b261-4205-a01f-603c95e4cae0")
      if(NOT DEFINED CMAKE_INSTALL_SBOMDIR)
        set(CMAKE_INSTALL_SBOMDIR ${CMAKE_INSTALL_DATADIR}/sbom)
      endif()
      install(SBOM ${P_REPO_NAME} EXPORT ${P_EXPORT}
        ${xpInfoProject} ${xpInfoVersion} ${xpInfoLicense} ${xpInfoDesc} ${xpInfoHome}
        DESTINATION ${CMAKE_INSTALL_SBOMDIR} ${XP_COMPONENT}
        )
    endif()
  endif()
  ###############
  # packaging
  unset(CPACK_PACKAGING_INSTALL_PREFIX)
  set(CPACK_GENERATOR TXZ)
  set(CPACK_PACKAGE_NAME ${P_REPO_NAME})
  xpGetCompilerPrefix(pfx VER_ONE)
  set(CPACK_PACKAGE_VERSION "${VER}-${pfx}") # override CPACK_PACKAGE_VERSION
  if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64|ARM64)$")
    set(CPACK_SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-arm64") # override CPACK_SYSTEM_NAME
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64|AMD64)$")
    set(CPACK_SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-amd64") # override CPACK_SYSTEM_NAME
  endif()
  if(NOT DEFINED P_COMPONENT)
    set(CPACK_SYSTEM_NAME ${CPACK_SYSTEM_NAME}-xpro)
  endif()
  # CPACK_PACKAGE_FILE_NAME is ${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_SYSTEM_NAME}
  include(CPack)
endfunction()

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
  elseif("${CMAKE_C_COMPILER_ID}" STREQUAL "GNU" OR "${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU" OR
         "${CMAKE_C_COMPILER_ID}" MATCHES "Clang" OR "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang"
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
  if(CMAKE_SYSTEM_NAME STREQUAL "Darwin" AND CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64")
    list(REMOVE_ITEM CMAKE_SYSTEM_PREFIX_PATH
      /opt/homebrew # Brew on Apple Silicon
      )
  endif()
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
  elseif((CMAKE_C_COMPILER_ID STREQUAL GNU) OR (CMAKE_CXX_COMPILER_ID STREQUAL GNU) OR (${CMAKE_C_COMPILER_ID} MATCHES "Clang") OR (${CMAKE_CXX_COMPILER_ID} MATCHES "Clang"))
    if(CMAKE_BUILD_TYPE STREQUAL Debug)
      add_definitions(-D_DEBUG)
    endif()
    # C
    if(CMAKE_C_COMPILER AND CMAKE_C_COMPILER_ID)
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
    endif()
    # C++
    if(CMAKE_CXX_COMPILER AND CMAKE_CXX_COMPILER_ID)
      include(CheckCXXCompilerFlag)
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
    endif() # C++ (GNUCXX OR Clang)
  endif()
  if(XP_FLAGS_VERBOSE)
    message(STATUS "xpCommonFlags CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}")
    message(STATUS "xpCommonFlags CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
    message(STATUS "xpCommonFlags CMAKE_EXE_LINKER_FLAGS: ${CMAKE_EXE_LINKER_FLAGS}")
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
  if(XP_FLAGS_VERBOSE)
    message(STATUS "xpSetFlags CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}")
    message(STATUS "xpSetFlags CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
    message(STATUS "xpSetFlags CMAKE_EXE_LINKER_FLAGS: ${CMAKE_EXE_LINKER_FLAGS}")
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
