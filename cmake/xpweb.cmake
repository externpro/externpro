#gathers all dependencies for a package and places it in the staging directory under the package name
function(wpBuildYarnMirror)
  set(oneValueArgs NAME)
  set(multiValueArgs DEPENDS)
  cmake_parse_arguments(P "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  string(TOLOWER ${P_NAME} prj)
  string(TOUPPER ${P_NAME} PRJ)
  if(TARGET ${prj})
    return()
  endif()

  if(XP_DEFAULT OR XP_PRO_${PRJ})
    wpAnalyzeDeps(${P_NAME} "${P_DEPENDS}")
    set(yarnDir ${CMAKE_BINARY_DIR}/wpYarn) #temp dir for installing Node.js modules
    foreach(dep ${includedDeps})
      ExternalProject_Get_Property(${dep} SOURCE_DIR)
      file(RELATIVE_PATH relative_path ${yarnDir} ${SOURCE_DIR})
      string(TOUPPER ${dep} DEP)
      xpGetArgValue(${PRO_${DEP}} ARG INSTALL_PATH VALUE INSTALL_PATH)
      if(NOT ("unknown" STREQUAL INSTALL_PATH))
        set(relative_path ${relative_path}/${INSTALL_PATH})
      endif()
      list(APPEND dependencyList ${relative_path})
    endforeach()
    option(WP_UPDATE_LOCK "Update lock files in repo" OFF)
    if(dirty)
      set(dirtyFlag "dirty")
    endif()
    file(WRITE ${yarnDir}/.yarnrc "yarn-offline-mirror \"${STAGE_DIR}/yarn-offline-mirror\"\nyarn-offline-mirror-pruning false\n")
    file(COPY
      ${WP_MODULES_DIR}/.yarnrc.in
      ${WP_MODULES_DIR}/version.js.in
      ${WP_MODULES_DIR}/version.ts.in
      ${WP_MODULES_DIR}/versionjs.cmake
      ${WP_MODULES_DIR}/wpfuncmac.cmake
      ${WP_MODULES_DIR}/NodePath.cmake
      DESTINATION ${STAGE_DIR}/share/cmake
      )
    if(NOT WP_UPDATE_LOCK)
      set(updateLock ${CMAKE_COMMAND} -E copy_if_different ${WP_MODULES_DIR}/yarn.lock ${yarnDir})
    endif()
    if(WIN32)
      set(noop_success_cmd VER>NUL)
    else()
      set(noop_success_cmd true)
    endif()
    ExternalProject_Get_Property(download_yarn DOWNLOAD_DIR)
    add_custom_command(OUTPUT "${CMAKE_BINARY_DIR}/wpStamp/${prj}"
      DEPENDS ${buildDeps} download_yarn
      COMMAND ${NODE_EXE} ${DOWNLOAD_DIR}/yarn.js cache clean --cache-folder ${CMAKE_BINARY_DIR}/cache
      COMMAND ${NODE_EXE} ${DOWNLOAD_DIR}/yarn.js init -yp
      COMMAND ${updateLock}
      COMMAND ${CMAKE_COMMAND} -P ${WP_MODULES_DIR}/NodePath.cmake ${yarnDir} ${NODE_EXE}
        ${NODE_EXE} ${DOWNLOAD_DIR}/yarn.js add ${dependencyList} --ignore-optional
        --cache-folder ${CMAKE_CURRENT_BINARY_DIR}/cache --network-timeout 100000 --update-checksums
      COMMAND ${NODE_EXE} ${DOWNLOAD_DIR}/yarn.js audit --no-color > ${P_NAME}_audit.txt || ${noop_success_cmd}
      COMMAND ${CMAKE_COMMAND} -E copy_if_different ${P_NAME}_audit.txt ${STAGE_DIR}/share/${P_NAME}_audit.txt
      COMMAND ${CMAKE_COMMAND} -P ${WP_MODULES_DIR}/compareFiles.cmake
        yarn.lock ${WP_MODULES_DIR}/yarn.lock ${dirtyFlag}
      COMMAND ${NODE_EXE} ${WP_MODULES_DIR}/fixYarnLock.js ${WP_MODULES_DIR}/yarn.lock ${STAGE_DIR}/share/yarn.lock
      COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_BINARY_DIR}/wpStamp/${prj}"
      WORKING_DIRECTORY ${yarnDir}
      )
    add_custom_target(${prj} ALL DEPENDS "${CMAKE_BINARY_DIR}/wpStamp/${prj}" ${buildDeps})
    add_test(NAME Yarn
      COMMAND ${NODE_EXE} ./FixYarnTest.js ${CMAKE_SOURCE_DIR}/modules/fixYarnLock.js ./Test.lock ./Expected.lock ${CMAKE_BINARY_DIR}/Result.lock
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/test
      )
  endif()
endfunction()

#gets the npm registry download url
# sets ${DLURL} in the parent scope
function(wpNpmDownloadUrl package version)
  string(FIND ${package} "/" slashLocation)
  if(NOT slashLocation EQUAL -1)
    math(EXPR slashLocation+ "${slashLocation} + 1")
    string(SUBSTRING ${package} 0 ${slashLocation} namespace)
    string(SUBSTRING ${package} ${slashLocation+} -1 package)
  endif()
  set(DLURL "https://registry.npmjs.org/${namespace}/${package}/-/${package}-${version}.tgz")
  set(DLURL ${DLURL} PARENT_SCOPE)
endfunction()

# sets ${DLURL} in the parent scope
# sets ${NAME} in the parent scope
# sets ${CACHE_NAME} in the parent scope
function(initLibrary LIB_NAME VER)
  string(REPLACE "/" "-" CACHE_NAME ${LIB_NAME})
  string(REPLACE "@" "" NAME ${CACHE_NAME})
  wpNpmDownloadUrl(${LIB_NAME} ${VER})
  xpProOption(${NAME}_${VER})
  set(DLURL ${DLURL} PARENT_SCOPE)
  set(NAME ${NAME} PARENT_SCOPE)
  set(CACHE_NAME ${CACHE_NAME} PARENT_SCOPE)
endfunction()

#prepare buildDeps and includedDeps
function(wpAnalyzeDeps packageName pkgDeps)
  foreach(dep ${pkgDeps})
    string(REPLACE "-" "" depNoDash ${dep})
    string(REPLACE "." "" depFnStr ${depNoDash})
    string(TOUPPER ${dep} DEP)
    if(((NOT XP_PRO_${DEP}) AND (NOT XP_DEFAULT)) OR NOT TARGET ${dep}) # Verify that all dependencies are included
      list(APPEND omittedDeps ${dep})
    else()
      list(APPEND buildDeps ${dep})
      list(APPEND includedDeps ${dep})
      if(TARGET ${dep}_bld) # If the dependency has a build step, add it to the list
        list(APPEND buildDeps ${dep}_bld)
      elseif(COMMAND build_${depFnStr}) # build targets may not be created yet
        wpRunFn(build_${depFnStr})
        if(TARGET ${dep}_bld) # Only add the dependency if there is a target associated with the build step
          list(APPEND buildDeps ${dep}_bld)
        endif()
      endif()
    endif()
  endforeach()
  if(NOT DEFINED includedDeps)
    message(SEND_ERROR "Included package ${packageName} has no dependencies included")
    return()
  endif()
  if(DEFINED omittedDeps)
    string(REPLACE ";" "\n\t" msg1 "${includedDeps}")
    string(REPLACE ";" "\n\t" msg2 "${omittedDeps}")
    message(STATUS "Included package ${packageName} including modules:\n\t${msg1}\nand omitting modules:\n\t${msg2}")
  else()
    message(STATUS "Included package ${packageName} including all module dependencies")
  endif()
  set(includedDeps ${includedDeps} PARENT_SCOPE)
  set(buildDeps ${buildDeps} PARENT_SCOPE)
endfunction()

macro(wpRunFn fn)
  set(outputFile ${CMAKE_BINARY_DIR}/wpRunFn/run_${fn}.cmake)
  file(WRITE ${outputFile} "${fn}()")
  include(${outputFile})
endmacro()

# INSTALL_PATH: for monolith repos, when packing only part of a repo
function(wpYarnPack)
  set(oneValueArgs VER NAME CACHE_NAME LIB_NAME INSTALL_PATH)
  set(multiValueArgs DEPENDS)
  cmake_parse_arguments(P "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  if(NOT DEFINED P_NAME OR TARGET ${P_NAME}_pack OR NOT TARGET ${P_NAME})
    message(FATAL_ERROR "${NAME} does not seem correct. This will lead to an incomplete webpro")
  endif()
  ExternalProject_Get_Property(${P_NAME} SOURCE_DIR)
  set(${P_NAME}_SOURCE ${SOURCE_DIR})
  ExternalProject_Get_Property(download_yarn DOWNLOAD_DIR)
  ExternalProject_Add(${P_NAME}_pack DEPENDS ${P_NAME} download_yarn ${P_DEPENDS}
    DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E make_directory "${STAGE_DIR}/yarn-offline-mirror"
    SOURCE_DIR ${NULL_DIR}
    BUILD_COMMAND ${NODE_EXE} ${DOWNLOAD_DIR}/yarn.js pack --ignore-scripts --filename ${STAGE_DIR}/yarn-offline-mirror/${P_CACHE_NAME}-${P_VER}.tgz
      --cache-folder ${CMAKE_CURRENT_BINARY_DIR}/cache
    BINARY_DIR ${${P_NAME}_SOURCE}/${P_INSTALL_PATH}
    INSTALL_COMMAND "" INSTALL_DIR ${NULL_DIR}
    )
endfunction()

# yarn installs downloaded repo to the download directory
# use for libraries that are manually downloaded from the git repo and possibly
# patched that still require a yarn install (usually needed if there are
# node_module dependencies)
function(wpBuildYarnModule)
  set(optionArgs IGNORE_SCRIPTS)
  set(oneValueArgs NAME RUN_BUILD)
  cmake_parse_arguments(P "${optionArgs}" "${oneValueArgs}" "" ${ARGN})
  string(TOLOWER ${P_NAME} prj)
  string(TOUPPER ${P_NAME} PRJ)
  if(TARGET ${prj}_bld)
    return()
  endif()
  if(XP_DEFAULT OR XP_PRO_${PRJ})
    ExternalProject_Get_Property(${prj} SOURCE_DIR)
    ExternalProject_Get_Property(download_yarn DOWNLOAD_DIR)
    if(DEFINED P_RUN_BUILD)
      set(BUILD_CMD ${NODE_EXE} ${DOWNLOAD_DIR}/yarn.js run ${P_RUN_BUILD})
    else()
      SET(BUILD_CMD "")
    endif()
    if(P_IGNORE_SCRIPTS)
      set(IGNORE_FLAG --ignore-scripts)
    endif()
    if(NOT TARGET node_gyp)
      if(NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/wpStamp")
        file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/wpStamp")
      endif()
      add_custom_command(OUTPUT "${CMAKE_BINARY_DIR}/wpStamp/node_gyp_cmd"
        COMMAND ${NODE_EXE} ${DOWNLOAD_DIR}/yarn.js global add node-gyp@9.0.0
        COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_BINARY_DIR}/wpStamp/node_gyp_cmd"
        DEPENDS download_yarn
        )
      add_custom_target(node_gyp ALL DEPENDS "${CMAKE_BINARY_DIR}/wpStamp/node_gyp_cmd")
      set_property(TARGET node_gyp PROPERTY ${bld_folder})
    endif()
    ExternalProject_Add(${prj}_bld DEPENDS ${prj} download_yarn node_gyp
      DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
      CONFIGURE_COMMAND ${NODE_EXE} ${DOWNLOAD_DIR}/yarn.js install --pure-lockfile --ignore-optional
        --cache-folder ${CMAKE_CURRENT_BINARY_DIR}/cache/${P_NAME} --network-timeout 100000
        ${IGNORE_FLAG}
      SOURCE_DIR ${SOURCE_DIR}
      BUILD_COMMAND "${BUILD_CMD}"
      BINARY_DIR ${SOURCE_DIR}
      INSTALL_COMMAND "" INSTALL_DIR ${NULL_DIR}
      )
    set_property(TARGET ${prj}_bld PROPERTY FOLDER ${bld_folder})
    ExternalProject_Add_Step(${prj}_bld ${prj}_bld_lock
      COMMAND ${CMAKE_COMMAND}
        -DSOURCE_DIR:FILEPATH=${SOURCE_DIR}
        -DNODE_EXE:FILEPATH=${NODE_EXE}
        -DDOWNLOAD_DIR:FILEPATH=${DOWNLOAD_DIR}
        -DWP_UPDATE_LOCK:FILEPATH=${WP_UPDATE_LOCK}
        -DWP_MODULES_DIR:FILEPATH=${WP_MODULES_DIR}
        -DCACHE_FOLDER=${CMAKE_CURRENT_BINARY_DIR}/cache/${P_NAME}
        -DdirtyFlag:STRING=${dirtyFlag}
        -P ${WP_MODULES_DIR}/install.cmake
        WORKING_DIRECTORY ${SOURCE_DIR}
        DEPENDERS configure
        )
  endif()
endfunction()

function(wpCreateBadges)
  if(NOT ${XP_STEP} STREQUAL "build")
    execute_process(COMMAND ${NODE_EXE} ${CMAKE_SOURCE_DIR}/modules/addSecurityBadges.js ${CMAKE_SOURCE_DIR}/projects/README.md)
  endif()
endfunction()

################## Public Helpers ######################
function(wpVerifyWebproDir)
  if(NOT webpro_DIR)
    message(FATAL_ERROR "webpro_DIR is undefined")
  endif()
endfunction()

function(wpVerifyTargetName targetName)
  if(NOT DEFINED ${targetName})
    message(FATAL_ERROR "Target name is required but not provided")
  endif()
endfunction()

function(wpVerifyCMakeLists)
  if(NOT DEFINED P_CMAKELIST)
    if(EXISTS ${CommonLibraries_SOURCE_DIR}/cmake/toplevel.cmake)
      set(P_CMAKELIST ${CommonLibraries_SOURCE_DIR}/cmake/toplevel.cmake)
      set(P_CMAKELIST ${P_CMAKE_LIST} PARENT_SCOPE)
    else()
      message(WARNING "The CMakeLists where webpro is set is not given. This may not rebuild when it needs to")
    endif()
  endif()
endfunction()

function(wpVerifyWorkingDirectory)
  if(NOT DEFINED P_WORKING_DIRECTORY OR P_WORKING_DIRECTORY STREQUAL "")
    set(P_WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    set(P_WORKING_DIRECTORY ${P_WORKING_DIRECTORY} PARENT_SCOPE)
  endif()
  if(NOT EXISTS ${P_WORKING_DIRECTORY})
    message(FATAL_ERROR "Working directory must exist")
  endif()
endfunction()

function(wpGetNodePath)
  if(NOT DEFINED NODE_EXE)
    xpGetPkgVar(Node EXE) # sets NODE_EXE
    set(NODE_EXE ${NODE_EXE} PARENT_SCOPE)
  endif()
endfunction()

function(wpGetYarnPath)
  if(NOT DEFINED YARN_SCRIPT)
    xpGetPkgVar(yarn SCRIPT) # sets YARN_SCRIPT
    set(YARN_SCRIPT ${YARN_SCRIPT} PARENT_SCOPE)
  endif()
endfunction()

function(wpGetAngularPath)
  if(NOT DEFINED ANGULAR-CLI_SCRIPT)
    xpGetPkgVar(angular-cli SCRIPT) # sets ANGULAR-CLI_SCRIPT
    set(ANGULAR-CLI_SCRIPT ${ANGULAR-CLI_SCRIPT} PARENT_SCOPE)
  endif()
endfunction()

function(wpVerifySrcs srcs)
  if(NOT DEFINED ${srcs})
    message(FATAL_ERROR "No sources were given, this target will not rebuild correctly")
  endif()
endfunction()

function(wpVerifyFolder)
  if(DEFINED P_FOLDER)
    set(P_FOLDER FOLDER ${P_FOLDER})
  elseif(DEFINED folder)
    set(P_FOLDER FOLDER ${folder})
  endif()
  set(P_FOLDER ${P_FOLDER} PARENT_SCOPE)
endfunction()

function(wpVerifyTestDir)
  if(NOT DEFINED P_TEST_DIR)
    set(P_TEST_DIR test)
    set(P_TEST_DIR ${P_TEST_DIR} PARENT_SCOPE)
  endif()
endfunction()

function(wpVerifyTestFolder)
  if(DEFINED P_TEST_FOLDER)
    set(P_TEST_FOLDER FOLDER ${P_TEST_FOLDER})
  elseif(DEFINED folder_unittest)
    set(P_TEST_FOLDER FOLDER ${folder_unittest})
  endif()
  set(P_TEST_FOLDER ${P_TEST_FOLDER} PARENT_SCOPE)
endfunction()

function(wpVerifyYarnTarget)
  if(NOT DEFINED P_YARN_TARGET)
    message(FATAL_ERROR "This target requires a dependency upon an install target")
  endif()
  list(APPEND P_DEPENDS ${P_YARN_TARGET})
  set(P_DEPENDS ${P_DEPENDS} PARENT_SCOPE)
endfunction()

function(wpSetBuildProperties target)
  set_property(TARGET ${target} PROPERTY STAMP ${build_stamp})
  if(DEFINED P_FOLDER)
    set_property(TARGET ${target} PROPERTY ${P_FOLDER})
  endif()
  if(DEFINED build_dir)
    set_property(TARGET ${target} PROPERTY BUILD_DIR ${build_dir})
  endif()
endfunction()

function(wpCalculateDependencies)
  if(NOT DEFINED P_DEPENDS)
    message(FATAL_ERROR "No dependencies were given")
  endif()
  foreach(depend ${P_DEPENDS})
    list(APPEND depends ${depend})
    get_target_property(stampFile ${depend} STAMP)
    if(NOT "${stampFile}" STREQUAL stampFile-NOTFOUND)
      list(APPEND depends ${stampFile})
    endif()
  endforeach()
  set(depends ${depends} PARENT_SCOPE)
endfunction()

function(wpGetInstallComponent)
  if(DEFINED P_INSTALL_COMPONENT)
    set(component COMPONENT ${P_INSTALL_COMPONENT})
    set(component ${component} PARENT_SCOPE)
  endif()
endfunction()

function(wpInstallBuildDir)
  if(DEFINED P_INSTALL_DESTINATION)
    wpGetInstallComponent()
    install(DIRECTORY ${build_dir}/ DESTINATION ${P_INSTALL_DESTINATION} ${component} PATTERN "bin/Node*.node" EXCLUDE)
  endif()
endfunction()

function(wpSetIfNotDefined)
  if(NOT DEFINED ${ARGV0})
    set(${ARGV0} ${ARGV1} PARENT_SCOPE)
  endif()
endfunction()

function(wpSetIfDefined arg)
  if(DEFINED P_${arg})
    set(P_${arg} ${arg} "${P_${arg}}")
    set(P_${arg} ${P_${arg}} PARENT_SCOPE)
  endif()
endfunction()

function(wpAddTypescriptLibrary)
  if(ARGV0 OR ARGV1)
    return()
  endif()
  get_property(ecmaScriptTargets GLOBAL PROPERTY ecmaScriptTargets_property)
  list(APPEND ecmaScriptTargets ${CMAKE_CURRENT_SOURCE_DIR})
  set_property(GLOBAL PROPERTY ecmaScriptTargets_property "${ecmaScriptTargets}")
endfunction()

function(wpAddTestTarget target)
  wpVerifyTestDir() # Can set P_TEST_DIR
  wpVerifyFolder() # Can set P_FOLDER
  set(projectName ${target}Test)
  ipParseDir(${P_TEST_DIR} "")
  list(APPEND P_DEPENDS ${target})
  add_custom_target(${projectName} ALL DEPENDS ${P_DEPENDS} SOURCES ${${projectName}_srcs})
  if(DEFINED P_FOLDER)
    set_property(TARGET ${projectName} PROPERTY ${P_FOLDER})
  endif()
  xpSourceListAppend(${${projectName}_srcs})
endfunction()

################## Public #############################
# ARGV0 - What to name the target
# CMAKELIST - Where is webpro version specified
# FOLDER - What folder to put the target under
# WORKING_DIRECTORY - Where to perform the install
function(wpAddYarnTarget)
  set(YARN_TARGET ${ARGV0})
  set(oneValueArgs CMAKELIST FOLDER WORKING_DIRECTORY)
  cmake_parse_arguments(P "" "${oneValueArgs}" "" ${ARGN})
  wpVerifyWebproDir()
  wpVerifyTargetName(YARN_TARGET)
  wpVerifyCMakeLists()
  wpVerifyWorkingDirectory() # Can set P_WORKING_DIRECTORY
  wpGetNodePath() # sets NODE_EXE
  wpGetYarnPath() # sets YARN_SCRIPT
  wpVerifyFolder() # Can set P_FOLDER
  if(TARGET ${YARN_TARGET})
    return()
  endif()
  configure_file(${webpro_DIR}/share/cmake/.yarnrc.in ${CMAKE_CURRENT_BINARY_DIR}/.yarnrc)
  set(build_stamp ${P_WORKING_DIRECTORY}/node_modules/.yarn-integrity)
  add_custom_command(OUTPUT ${build_stamp}
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${webpro_DIR}/share/yarn.lock ${P_WORKING_DIRECTORY}
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_BINARY_DIR}/.yarnrc ${P_WORKING_DIRECTORY}
    COMMAND ${NODE_EXE} ${YARN_SCRIPT} install --offline --pure-lockfile --ignore-scripts
      --mutex network 2>&1
    COMMENT "Installing ${YARN_TARGET}"
    WORKING_DIRECTORY ${P_WORKING_DIRECTORY}
    DEPENDS ${P_WORKING_DIRECTORY}/package.json ${P_CMAKELIST}
    )
  add_custom_target(${YARN_TARGET} ALL
    DEPENDS ${build_stamp} ${P_CMAKELIST}
    SOURCES ${P_WORKING_DIRECTORY}/package.json
    WORKING_DIRECTORY ${P_WORKING_DIRECTORY}
    )
  wpSetBuildProperties(${YARN_TARGET})
endfunction()

# ARGV0 - What to name the target
# FOLDER - What folder to put the target under
# VERSION_DEST - Where to put the version file
function(wpAddGenerateVersion)
  set(VERSION_TARGET ${ARGV0})
  set(oneValueArgs FOLDER VERSION_DEST)
  cmake_parse_arguments(P "" "${oneValueArgs}" "" ${ARGN})
  wpVerifyWebproDir()
  wpVerifyTargetName(VERSION_TARGET)
  wpVerifyFolder() # Can set P_FOLDER
  if(NOT DEFINED P_VERSION_DEST)
    message(FATAL_ERROR "wpAddGenerateVersion requires a destination")
  endif()
  if(P_VERSION_DEST MATCHES ".*ts")
    set(versionToMake ts)
  elseif(P_VERSION_DEST MATCHES ".*js")
    set(versionToMake js)
  else()
    message(FATAL_ERROR "wpAddGenerateVersion only supports .ts or .js")
  endif()
  wpSetIfNotDefined(PACKAGE_VERSION_MAJOR ${CMAKE_PROJECT_VERSION_MAJOR})
  wpSetIfNotDefined(PACKAGE_VERSION_MINOR ${CMAKE_PROJECT_VERSION_MINOR})
  wpSetIfNotDefined(PACKAGE_VERSION_PATCH ${CMAKE_PROJECT_VERSION_PATCH})
  wpSetIfNotDefined(PACKAGE_VERSION_TWEAK ${CMAKE_PROJECT_VERSION_TWEAK})
  wpSetIfNotDefined(FILE_VERSION_MAJOR ${CMAKE_PROJECT_VERSION_MAJOR})
  wpSetIfNotDefined(FILE_VERSION_MINOR ${CMAKE_PROJECT_VERSION_MINOR})
  wpSetIfNotDefined(FILE_VERSION_PATCH ${CMAKE_PROJECT_VERSION_PATCH})
  wpSetIfNotDefined(FILE_VERSION_TWEAK ${CMAKE_PROJECT_VERSION_TWEAK})
  xpCreateVersionString(PACKAGE) # Sets PACKAGE_VERSION_NUM and PACKAGE_STR
  xpCreateVersionString(FILE) # Sets FILE_VERSION_NUM and FILE_STR
  string(TIMESTAMP PACKAGE_CURRENT_YEAR %Y)
  if(NOT DEFINED FILE_DESC)
    if(DEFINED PACKAGE_NAME AND DEFINED exe_name)
      set(FILE_DESC "${PACKAGE_NAME} ${exe_name}")
    elseif(DEFINED PACKAGE_NAME)
      set(FILE_DESC "${PACKAGE_NAME}")
    elseif(NOT DEFINED PACKAGE_NAME)
      set(FILE_DESC ${CMAKE_PROJECT_NAME})
    endif()
  endif()
  set(REVISION_TXT "${CMAKE_BINARY_DIR}/revision.txt")
  if(XP_CLAS_REPO)
    set(isClassifiedBuild "true")
  else()
    set(isClassifiedBuild "false")
  endif()
  configure_file(${webpro_DIR}/share/cmake/version.${versionToMake}.in ${CMAKE_CURRENT_BINARY_DIR}/version.es.in @ONLY)
  include(${webpro_DIR}/share/cmake/versionjs.cmake)
  set(versionTarget Version_js PARENT_SCOPE)
  set(version_ts_src ${version_ts_src} PARENT_SCOPE)
endfunction()

# ARGV0 - What to name the target
# FOLDER - What folder to put the target under
# PROTO_DEST - Where to put the messages files
# PROTO_SRCS - The list of the proto files to process
# TARGET_FORMAT - The target format for the generated files
# WORKING_DIRECTORY - Where to perform the command
# YARN_TARGET - What install target is depended upon
function(wpAddGenerateProto)
  set(GENERATE_TARGET ${ARGV0})
  set(oneValueArgs FOLDER PROTO_DEST TARGET_FORMAT WORKING_DIRECTORY YARN_TARGET)
  set(multiValueArgs PROTO_SRCS)
  cmake_parse_arguments(P "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  wpVerifyWebproDir()
  wpVerifyTargetName(GENERATE_TARGET)
  wpVerifyFolder() # Can set P_FOLDER
  wpVerifyWorkingDirectory() # Can set P_WORKING_DIRECTORY
  wpVerifyYarnTarget()
  file(GLOB P_PROTO_SRCS ${P_PROTO_SRCS})
  wpVerifySrcs(P_PROTO_SRCS)
  wpGetNodePath() # sets NODE_EXE
  if(NOT DEFINED P_PROTO_DEST)
    message(FATAL_ERROR "wpAddGenerateProto requires a destination")
  endif()
  if(NOT DEFINED P_TARGET_FORMAT)
    set(P_TARGET_FORMAT "static-module")
  endif()
  if(NOT DEFINED PROTOBUFJS-CLI_SCRIPT OR NOT DEFINED PROTOBUFJS-CLI_PBTS_SCRIPT)
    xpGetPkgVar(Protobufjs-cli SCRIPT PBTS_SCRIPT) # sets PROTOBUFJS-CLI_SCRIPT and PROTOBUFJS-CLI_PBTS_SCRIPT (relative path)
  endif()
  set(protobufJsOut ${P_PROTO_DEST}/messages.js)
  set(protobufTsOut ${P_PROTO_DEST}/messages.d.ts)
  set(build_stamp ${protobufJsOut} ${protobufTsOut})
  add_custom_command(OUTPUT ${build_stamp}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${P_PROTO_DEST}
    COMMAND ${NODE_EXE} ${P_WORKING_DIRECTORY}/${PROTOBUFJS-CLI_SCRIPT} --keep-case -t ${P_TARGET_FORMAT} -w commonjs
      -o ${protobufJsOut} -l eslint-disable -r ${ARGV0} ${P_PROTO_SRCS}
    COMMAND ${NODE_EXE} ${PROTOBUFJS-CLI_PBTS_SCRIPT} -o ${protobufTsOut} ${protobufJsOut}
    COMMAND ${CMAKE_COMMAND} -E touch ${protobufJsOut} ${protobufTsOut}
    DEPENDS ${P_YARN_TARGET} ${P_PROTO_SRCS}
    WORKING_DIRECTORY ${P_WORKING_DIRECTORY}
    )
  add_custom_target(${GENERATE_TARGET} ALL
    DEPENDS ${P_YARN_TARGET}
    SOURCES ${P_PROTO_SRCS}
    )
  wpSetBuildProperties(${GENERATE_TARGET})
endfunction()

# ARGV0 - What to name the target
# DEPENDS - What targets does this target depend on
# FOLDER - What folder to put the target under
# LIBRARY_DIR - It is a directory of libraries and has no code
# SKIP_YARN_TARGET - Whether there is a yarn target associated with the project
# SRCS - What files are part of this target
# TEST_TOOL - Whether the target is a test tool or not (to be scanned with fortify)
# WORKING_DIRECTORY - Where to perform the command
# YARN_TARGET - What install target is depended upon
function(wpAddSharedLibrary)
  set(BUILD_TARGET ${ARGV0})
  set(optionArgs LIBRARY_DIR SKIP_YARN_TARGET TEST_TOOL)
  set(oneValueArgs FOLDER WORKING_DIRECTORY YARN_TARGET)
  set(multiValueArgs SRCS DEPENDS)
  cmake_parse_arguments(P "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  wpVerifyWebproDir()
  wpVerifyTargetName(BUILD_TARGET)
  wpVerifyFolder() # Can set P_FOLDER
  wpVerifyWorkingDirectory() # Can set P_WORKING_DIRECTORY
  if(NOT P_SKIP_YARN_TARGET)
    wpVerifyYarnTarget() # appends YARN_TARGET to P_DEPENDS
    wpCalculateDependencies() # returns: depends
  endif()
  wpVerifySrcs(P_SRCS)
  set(build_dir ${CMAKE_CURRENT_BINARY_DIR}/build)
  set(build_stamp ${CMAKE_CURRENT_BINARY_DIR}/wpStamp/${BUILD_TARGET}.stamp)
  add_custom_command(OUTPUT ${build_stamp}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/wpStamp
    COMMAND ${CMAKE_COMMAND} -E touch ${build_stamp}
    COMMENT "Building ${BUILD_TARGET}"
    WORKING_DIRECTORY ${P_WORKING_DIRECTORY}
    DEPENDS ${P_SRCS} ${depends}
    )
  add_custom_target(${BUILD_TARGET} ALL
    DEPENDS ${build_stamp} ${depends}
    SOURCES ${P_SRCS}
    WORKING_DIRECTORY ${P_WORKING_DIRECTORY}
    )
  wpSetBuildProperties(${BUILD_TARGET})
  wpAddTypescriptLibrary(${P_TEST_TOOL} ${P_LIBRARY_DIR})
endfunction()

# ARGV0 - What to name the target
# DEPENDS - What targets does this target depend on
# EXCLUDE_WEB_LIBRARIES - Whether to build the shared libraries
# FOLDER - What folder to put the target under
# INSTALL_COMPONENT - What component to put the files in the installer
# INSTALL_DESTINATION - Where to put the files in the dist
# INSTALL_NODE_DESTINATION - Where to put the node exe in the dist
# OUTPUT_FILES - What files will be generated from webpack
# SRCS - What files are part of this target
# TEST_TOOL - Whether the target is a test tool or not (to be scanned with fortify)
# WORKING_DIRECTORY - Where to perform the command
# YARN_TARGET - What install target is depended upon
function(wpAddBuildWebpack)
  set(BUILD_TARGET ${ARGV0})
  set(optionArgs EXCLUDE_WEB_LIBRARIES TEST_TOOL)
  set(oneValueArgs FOLDER INSTALL_COMPONENT INSTALL_DESTINATION INSTALL_NODE_DESTINATION WORKING_DIRECTORY YARN_TARGET)
  set(multiValueArgs SRCS DEPENDS OUTPUT_FILES)
  cmake_parse_arguments(P "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  wpVerifyWebproDir()
  wpVerifyTargetName(BUILD_TARGET)
  wpVerifyFolder() # Can set P_FOLDER
  wpVerifyWorkingDirectory() # Can set P_WORKING_DIRECTORY
  wpVerifyYarnTarget() # appends YARN_TARGET to P_DEPENDS
  wpVerifySrcs(P_SRCS)
  wpGetNodePath() # sets NODE_EXE
  wpCalculateDependencies() # returns: depends
  if(NOT DEFINED WEBPACK-CLI_SCRIPT)
    xpGetPkgVar(webpack-cli SCRIPT) # sets WEBPACK-CLI_SCRIPT
  endif()
  if(P_EXCLUDE_WEB_LIBRARIES)
    set(build_stamp ${CMAKE_CURRENT_BINARY_DIR}/wpStamp/${BUILD_TARGET}.stamp)
    set(commandToRun ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/wpStamp
      COMMAND ${CMAKE_COMMAND} -E touch ${build_stamp}
      )
  else()
    set(build_dir ${CMAKE_CURRENT_BINARY_DIR}/build)
    list(LENGTH P_OUTPUT_FILES l)
    if(${l} EQUAL 0)
      list(APPEND P_OUTPUT_FILES "main")
    endif()
    set(build_stamp ${P_OUTPUT_FILES})
    list(TRANSFORM build_stamp PREPEND ${build_dir}/)
    list(TRANSFORM build_stamp APPEND .js)
    set(commandToRun ${CMAKE_COMMAND} -E env BROWSERSLIST_IGNORE_OLD_DATA=True ${NODE_EXE} ${WEBPACK-CLI_SCRIPT} --output-path ${build_dir} --env context=${CMAKE_CURRENT_SOURCE_DIR})
  endif()
  add_custom_command(OUTPUT ${build_stamp}
    COMMAND ${commandToRun}
    COMMENT "Building ${BUILD_TARGET}"
    WORKING_DIRECTORY ${P_WORKING_DIRECTORY}
    DEPENDS ${P_SRCS} ${depends}
    )
  add_custom_target(${BUILD_TARGET} ALL
    DEPENDS ${build_stamp} ${depends}
    SOURCES ${P_SRCS}
    WORKING_DIRECTORY ${P_WORKING_DIRECTORY}
    )
  wpSetBuildProperties(${BUILD_TARGET})
  if(NOT P_EXCLUDE_WEB_LIBRARIES)
    wpInstallBuildDir()
    wpGetInstallComponent() # Sets component
    if(NOT DEFINED P_INSTALL_NODE_DESTINATION)
      set(P_INSTALL_NODE_DESTINATION bin)
    endif()
    install(PROGRAMS ${NODE_EXE} DESTINATION ${P_INSTALL_NODE_DESTINATION} ${component})
  endif()
  wpAddTypescriptLibrary(${P_TEST_TOOL} FALSE)
endfunction()

# ARGV0 - What to name the target
# ANGULAR_PROJECT - What angular project to build
# ARCHIVE_BUILD - Whether to archive the build
# DEPENDS - What targets does this target depend on
# EXCLUDE_WEB_LIBRARIES - Whether to build the shared libraries
# EXTRA_PACKAGE_FILES - Files to add to the angular package
# FOLDER - What folder to put the target under
# INSTALL_COMPONENT - What component to put the files in the installer
# INSTALL_DESTINATION - Where to put the files in the dist
# SRCS - What files are part of this target
# TEST_TOOL - Whether the target is a test tool or not (to be scanned with fortify)
# WORKING_DIRECTORY - Where to perform the command
# YARN_TARGET - What install target is depended upon
function(wpAddBuildAngular)
  set(BUILD_TARGET ${ARGV0})
  set(optionArgs ARCHIVE_BUILD EXCLUDE_WEB_LIBRARIES TEST_TOOL)
  set(oneValueArgs ANGULAR_PROJECT FOLDER INSTALL_COMPONENT INSTALL_DESTINATION WORKING_DIRECTORY YARN_TARGET)
  set(multiValueArgs SRCS DEPENDS EXTRA_PACKAGE_FILES)
  cmake_parse_arguments(P "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  wpVerifyWebproDir()
  wpVerifyTargetName(BUILD_TARGET)
  wpVerifyFolder() # Can set P_FOLDER
  wpVerifyWorkingDirectory() # Can set P_WORKING_DIRECTORY
  wpVerifyYarnTarget() # appends YARN_TARGET to P_DEPENDS
  wpVerifySrcs(P_SRCS)
  wpGetNodePath() # sets NODE_EXE
  wpCalculateDependencies() # returns: depends
  wpGetAngularPath() # sets ANGULAR-CLI_SCRIPT
  if(DEFINED P_ANGULAR_PROJECT)
    set(project --project=${P_ANGULAR_PROJECT})
  endif()
  if(P_EXCLUDE_WEB_LIBRARIES)
    set(build_stamp ${CMAKE_CURRENT_BINARY_DIR}/wpStamp/${BUILD_TARGET}.stamp)
    set(commandToRun -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/wpStamp
      COMMAND ${CMAKE_COMMAND} -E touch ${build_stamp}
      )
  else()
    set(build_dir ${CMAKE_CURRENT_BINARY_DIR}/build)
    set(build_stamp ${build_dir}/index.html)
    set(commandToRun -P ${webpro_DIR}/share/cmake/NodePath.cmake ${P_WORKING_DIRECTORY}
      ${NODE_EXE} ${CMAKE_COMMAND} -E env BROWSERSLIST_IGNORE_OLD_DATA=True ${NODE_EXE} ${ANGULAR-CLI_SCRIPT} build ${project}
      --configuration production --output-path ${build_dir} --no-progress 2>&1
      )
  endif()
  add_custom_command(OUTPUT ${build_stamp}
    COMMAND ${CMAKE_COMMAND} ${commandToRun}
    COMMENT "Building ${BUILD_TARGET}"
    WORKING_DIRECTORY ${P_WORKING_DIRECTORY}
    DEPENDS ${P_SRCS} ${depends}
    )
  if(P_ARCHIVE_BUILD)
    if(DEFINED P_ANGULAR_PROJECT)
      set(archive ${CMAKE_CURRENT_BINARY_DIR}/${P_ANGULAR_PROJECT}.tar.gz)
    else()
      set(archive ${CMAKE_CURRENT_BINARY_DIR}/app.tar.gz)
    endif()
    if(DEFINED P_EXTRA_PACKAGE_FILES)
      set(copyCmd COMMAND ${CMAKE_COMMAND} -E copy ${P_EXTRA_PACKAGE_FILES} ${build_dir})
    endif()
    add_custom_command(OUTPUT ${archive}
      ${copyCmd}
      COMMAND ${CMAKE_COMMAND} -E tar -czf ${archive} .
      COMMENT "Compressing ${BUILD_TARGET}"
      WORKING_DIRECTORY ${build_dir}
      DEPENDS ${build_stamp}
      )
  endif()
  add_custom_target(${BUILD_TARGET} ALL
    DEPENDS ${build_stamp} ${depends} ${archive}
    SOURCES ${P_SRCS}
    WORKING_DIRECTORY ${P_WORKING_DIRECTORY}
    )
  wpSetBuildProperties(${BUILD_TARGET})
  if(NOT P_EXCLUDE_WEB_LIBRARIES)
    if(DEFINED archive AND P_INSTALL_DESTINATION)
      wpGetInstallComponent()
      install(FILES ${archive} DESTINATION ${P_INSTALL_DESTINATION} ${component})
    else()
      wpInstallBuildDir()
    endif()
  endif()
  wpAddTypescriptLibrary(${P_TEST_TOOL} FALSE)
endfunction()

# ARGV0 - What to name the target
# ADD_SUBMODULE_TEST_LABEL - Should it add the submodule-unit-test label
# DEPENDS - What targets does the test depend on
# FOLDER - What folder to put the target under
# TEST_DIR - Where are the test files
# WORKING_DIRECTORY - Where to perform the command
function(wpAddJasmineTest)
  set(BUILD_TARGET ${ARGV0})
  set(optionArgs ADD_SUBMODULE_TEST_LABEL EXCLUDE_COVERAGE)
  set(oneValueArgs FOLDER TEST_DIR WORKING_DIRECTORY)
  set(multiValueArgs DEPENDS)
  cmake_parse_arguments(P "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  wpVerifyWebproDir()
  wpVerifyTargetName(BUILD_TARGET)
  wpVerifyWorkingDirectory() # Can set P_WORKING_DIRECTORY
  wpGetNodePath() # Sets NODE_EXE
  if(NOT DEFINED JASMINE_SCRIPT)
    xpGetPkgVar(jasmine SCRIPT) # Sets JASMINE_SCRIPT
  endif()
  if(NOT DEFINED TS-NODE_SCRIPT)
    xpGetPkgVar(ts-node SCRIPT) # Sets TS-NODE_SCRIPT
  endif()
  wpAddTestTarget(${BUILD_TARGET}) # Uses DEPENDS, FOLDER, TEST_DIR
  if(P_EXCLUDE_COVERAGE)
    set(JS_SERVER_COVERAGE_FLAGS)
  else()
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/src)
      set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
    else()
      set(SRC_DIR '**')
    endif()
    cmake_path(RELATIVE_PATH SRC_DIR BASE_DIRECTORY ${P_WORKING_DIRECTORY})
    list(TRANSFORM JS_SERVER_COVERAGE_FLAGS REPLACE "@SRC_DIR@" "${SRC_DIR}")
    list(TRANSFORM JS_SERVER_COVERAGE_FLAGS REPLACE "@BUILD_TARGET@" "${BUILD_TARGET}")
  endif()
  add_test(NAME ${BUILD_TARGET}Test
    COMMAND ${JS_SERVER_COVERAGE_FLAGS} ${NODE_EXE} ${P_WORKING_DIRECTORY}/${TS-NODE_SCRIPT} --project ${CMAKE_CURRENT_SOURCE_DIR}/tsconfig.spec.json
      ${JASMINE_SCRIPT} --config=${CMAKE_CURRENT_SOURCE_DIR}/jasmine.json
    WORKING_DIRECTORY ${P_WORKING_DIRECTORY}
    )
  if(P_ADD_SUBMODULE_TEST_LABEL)
    set_tests_properties(${BUILD_TARGET}Test PROPERTIES LABELS submodule-unit-test)
  endif()
  xpSourceListAppend()
endfunction()

# ARGV0 - What to name the target
# ADD_SUBMODULE_TEST_LABEL - Should it add the submodule-unit-test label
# ANGULAR_PROJECT - What angular project to build
# DEPENDS - What targets does the test depend on
# FOLDER - What folder to put the target under
# TEST_DIR - Where are the test files
# WORKING_DIRECTORY - Where to perform the command
function(wpAddAngularTest)
  set(BUILD_TARGET ${ARGV0})
  set(optionArgs ADD_SUBMODULE_TEST_LABEL)
  set(oneValueArgs ANGULAR_PROJECT FOLDER TEST_DIR WORKING_DIRECTORY)
  set(multiValueArgs DEPENDS)
  cmake_parse_arguments(P "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  wpVerifyWebproDir()
  wpVerifyTargetName(BUILD_TARGET)
  wpVerifyWorkingDirectory() # Can set P_WORKING_DIRECTORY
  wpGetNodePath() # sets NODE_EXE
  wpGetAngularPath() # sets ANGULAR-CLI_SCRIPT
  if(WIN32)
    set(unit_test_browser ChromeHeadless)
  else()
    set(unit_test_browser ChromeHeadlessNoSandbox)
  endif()
  if(DEFINED P_ANGULAR_PROJECT)
    set(project --project=${P_ANGULAR_PROJECT})
  endif()
  wpAddTestTarget(${BUILD_TARGET})
  add_test(NAME ${BUILD_TARGET}Test
    COMMAND ${NODE_EXE} ${ANGULAR-CLI_SCRIPT} test ${project}
      --no-watch --no-progress --browsers=${unit_test_browser} ${JS_CLIENT_COVERAGE_FLAGS}
    WORKING_DIRECTORY ${P_WORKING_DIRECTORY}
    )
  if(P_ADD_SUBMODULE_TEST_LABEL)
    set_tests_properties(${BUILD_TARGET}Test PROPERTIES LABELS submodule-unit-test)
  endif()
  xpSourceListAppend()
endfunction()

# ARGV0 - What to name the target
# FOLDER - What folder to put the target under
# INPUT - Where are the routes found
# OUTPUT - Where to output the api docs
# WORKING_DIRECTORY - Where to perform the command
# YARN_TARGET - What install target is depended upon
function(wpGenerateApiDoc)
  set(GENERATE_TARGET ${ARGV0})
  set(oneValueArgs FOLDER INPUT OUTPUT WORKING_DIRECTORY YARN_TARGET)
  cmake_parse_arguments(P "" "${oneValueArgs}" "" ${ARGN})
  wpVerifyFolder() # Can set P_FOLDER
  wpGetNodePath() # sets NODE_EXE
  wpVerifyWorkingDirectory() # Can set P_WORKING_DIRECTORY
  if(NOT DEFINED APIDOC_SCRIPT)
    xpGetPkgVar(Apidoc SCRIPT) # sets APIDOC_SCRIPT
  endif()
  if(NOT DEFINED P_INPUT)
    message(FATAL_ERROR "Input files must be set to generate api docs")
  endif()
  if(NOT DEFINED P_OUTPUT)
    set(P_OUTPUT apidoc)
  endif()
  file(GLOB_RECURSE routeSrcs ${P_INPUT}/**)
  set(build_stamp ${CMAKE_CURRENT_BINARY_DIR}/${P_OUTPUT}/index.html)
  add_custom_command(OUTPUT ${build_stamp}
    COMMAND ${NODE_EXE} ${P_WORKING_DIRECTORY}/${APIDOC_SCRIPT} -i ${P_INPUT} -o ${CMAKE_CURRENT_BINARY_DIR}/${P_OUTPUT}
    COMMAND ${CMAKE_COMMAND} -E touch ${build_stamp}
    WORKING_DIRECTORY ${P_WORKING_DIRECTORY}
    DEPENDS ${routeSrcs} ${P_YARN_TARGET}
    )
  add_custom_target(${GENERATE_TARGET} ALL DEPENDS ${build_stamp})
  wpSetBuildProperties(${GENERATE_TARGET})
endfunction()

# ARGV0 - What to name the targets
# ADD_SUBMODULE_TEST_LABEL - Should it add the submodule-unit-test label
# ADD_TO_TEST - Should it add a test for the target
# ANGULAR_PROJECT - What angular project to build
# APIDOC_INPUT - Where are the routes found
# APIDOC_OUTPUT - Where to output the api docs
# ARCHIVE_BUILD - Whether to archive the build
# CMAKELIST - Where is webpro version specified
# DEPENDS - What targets does this target depend on
# EXCLUDE_WEB_LIBRARIES - Whether to build the shared libraries
# EXTRA_PACKAGE_FILES - Files to add to the angular package
# FOLDER - What folder to put the target under
# INSTALL_COMPONENT - What component to put the files in the installer
# INSTALL_DESTINATION - Where to put the files in the dist
# INSTALL_NODE_DESTINATION - Where to put the node exe in the dist
# LIBRARY_DIR - It is a directory of libraries and has no code
# OUTPUT_FILES - What files will be generated from webpack
# PROTO_DEST - Where to put the messages files
# PROTO_SRCS - The list of the proto files to process
# TARGET_FORMAT - The target format for the generated files
# TEST_DIR - Where are the test files
# TEST_DEPENDS - What targets does the test depend on
# TEST_FOLDER - What folder to put the test target in
# TEST_TOOL - Whether the target is a test tool or not (to be scanned with fortify)
# TYPE - What type of project
# VERSION_DEST - Where to put the version file
# WORKING_DIRECTORY - Where to perform the command
# YARN_TARGET - What install target is depended upon
function(wpInstallNBuild)
  set(BUILD_TARGET ${ARGV0})
  set(optionArgs ADD_SUBMODULE_TEST_LABEL ADD_TO_TEST ARCHIVE_BUILD EXCLUDE_WEB_LIBRARIES LIBRARY_DIR TEST_TOOL)
  set(oneValueArgs
    ANGULAR_PROJECT
    APIDOC_INPUT
    APIDOC_OUTPUT
    CMAKELIST
    FOLDER
    INSTALL_COMPONENT
    INSTALL_DESTINATION
    INSTALL_NODE_DESTINATION
    PROTO_DEST
    TARGET_FORMAT
    TEST_DIR
    TEST_FOLDER
    TYPE
    VERSION_DEST
    WORKING_DIRECTORY
    YARN_TARGET
    )
  set(multiValueArgs DEPENDS EXTRA_PACKAGE_FILES OUTPUT_FILES PROTO_SRCS SRCS TEST_DEPENDS)
  cmake_parse_arguments(P "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  if(NOT DEFINED P_YARN_TARGET)
    if(NOT DEFINED PROJECT_NAME)
      message(FATAL_ERROR "If YARN_TARGET is not given, PROJECT_NAME must be set")
    endif()
    set(P_YARN_TARGET ${PROJECT_NAME}Deps)
  endif()
  wpSetIfDefined(CMAKELIST) # Sets P_CMAKELIST
  wpVerifyFolder() # Sets P_FOLDER
  if(DEFINED P_FOLDER AND (DEFINED P_APIDOC_INPUT OR DEFINED P_PROTO_SRCS OR NOT TARGET ${P_YARN_TARGET}))
    set(P_FOLDER ${P_FOLDER}/${BUILD_TARGET}Targets)
  endif()
  wpSetIfDefined(WORKING_DIRECTORY) # Sets P_WORKING_DIRECTORY
  wpAddYarnTarget(${P_YARN_TARGET} ${P_CMAKELIST} ${P_FOLDER} ${P_WORKING_DIRECTORY})
  set(P_YARN_TARGET YARN_TARGET ${P_YARN_TARGET})
  wpSetIfDefined(DEPENDS) # Sets P_DEPENDS
  if(DEFINED P_VERSION_DEST)
    wpAddGenerateVersion(${BUILD_TARGET}_version ${P_FOLDER} VERSION_DEST ${P_VERSION_DEST})
    list(APPEND P_DEPENDS ${BUILD_TARGET}_version)
  endif()
  if(DEFINED P_PROTO_SRCS)
    wpSetIfDefined(PROTO_DEST) # Sets P_PROTO_DEST
    wpSetIfDefined(PROTO_SRCS) # Sets P_PROTO_SRCS
    wpSetIfDefined(TARGET_FORMAT) # Sets P_TARGET_FORMAT
    wpAddGenerateProto(${BUILD_TARGET}-pb
      ${P_FOLDER}
      ${P_PROTO_DEST}
      ${P_PROTO_SRCS}
      ${P_TARGET_FORMAT}
      ${P_WORKING_DIRECTORY}
      ${P_YARN_TARGET}
      )
    list(APPEND P_DEPENDS ${BUILD_TARGET}-pb)
  endif()
  wpSetIfDefined(SRCS) # Sets P_SRCS
  wpSetIfDefined(INSTALL_COMPONENT) # Sets P_INSTALL_COMPONENT
  wpSetIfDefined(INSTALL_DESTINATION) # Sets P_INSTALL_DESTINATION
  wpSetIfDefined(ANGULAR_PROJECT) # Sets P_ANGULAR_PROJECT
  wpSetIfDefined(EXCLUDE_FROM_ALL) # Sets P_EXCLUDE_FROM_ALL
  if(P_EXCLUDE_WEB_LIBRARIES)
    set(EXCLUDE_WEB_LIBRARIES EXCLUDE_WEB_LIBRARIES)
  endif()
  if(P_TEST_TOOL)
    set(TEST_TOOL TEST_TOOL)
  endif()
  if(P_TYPE STREQUAL "shared")
    if(P_LIBRARY_DIR)
      set(LIBRARY_DIR LIBRARY_DIR)
    endif()
    wpAddSharedLibrary(${BUILD_TARGET} ${P_DEPENDS} ${P_FOLDER} ${LIBRARY_DIR} ${P_SRCS} ${TEST_TOOL} ${P_WORKING_DIRECTORY} ${P_YARN_TARGET})
  elseif(P_TYPE STREQUAL "webpack")
    wpSetIfDefined(OUTPUT_FILES) # Sets P_OUTPUT_FILES
    wpSetIfDefined(INSTALL_NODE_DESTINATION) # Sets P_INSTALL_NODE_DESTINATION
    wpAddBuildWebpack(${BUILD_TARGET}
      ${EXCLUDE_WEB_LIBRARIES}
      ${P_DEPENDS}
      ${P_FOLDER}
      ${P_INSTALL_COMPONENT}
      ${P_INSTALL_DESTINATION}
      ${P_INSTALL_NODE_DESTINATION}
      ${P_OUTPUT_FILES}
      ${P_SRCS}
      ${TEST_TOOL}
      ${P_WORKING_DIRECTORY}
      ${P_YARN_TARGET}
      )
  elseif(P_TYPE STREQUAL "angular")
    if(P_ARCHIVE_BUILD)
      set(ARCHIVE_BUILD ARCHIVE_BUILD)
    endif()
    wpSetIfDefined(EXTRA_PACKAGE_FILES) # Sets P_EXTRA_PACKAGE_FILES
    wpAddBuildAngular(${BUILD_TARGET}
      ${EXCLUDE_WEB_LIBRARIES}
      ${P_ANGULAR_PROJECT}
      ${ARCHIVE_BUILD}
      ${P_DEPENDS}
      ${P_EXTRA_PACKAGE_FILES}
      ${P_FOLDER}
      ${P_INSTALL_COMPONENT}
      ${P_INSTALL_DESTINATION}
      ${P_SRCS}
      ${TEST_TOOL}
      ${P_WORKING_DIRECTORY}
      ${P_YARN_TARGET}
      )
  endif()
  if(P_ADD_TO_TEST)
    wpSetIfDefined(TEST_DIR) # Sets P_TEST_DIR
    if(DEFINED P_TEST_DEPENDS)
      set(P_TEST_DEPENDS DEPENDS ${P_TEST_DEPENDS})
    endif()
    if(P_ADD_SUBMODULE_TEST_LABEL)
      set(ADD_SUBMODULE_TEST_LABEL ADD_SUBMODULE_TEST_LABEL)
    endif()
    wpVerifyTestFolder() # Sets P_TEST_FOLDER
    if(P_TYPE STREQUAL "angular")
      wpAddAngularTest(${BUILD_TARGET} ${ADD_SUBMODULE_TEST_LABEL} ${P_ANGULAR_PROJECT} ${P_TEST_DEPENDS} ${P_TEST_DIR} ${P_TEST_FOLDER} ${P_WORKING_DIRECTORY} ${P_YARN_TARGET})
    else()
      wpAddJasmineTest(${BUILD_TARGET} ${ADD_SUBMODULE_TEST_LABEL} ${P_TEST_DIR} ${P_TEST_DEPENDS} ${P_TEST_FOLDER} ${P_WORKING_DIRECTORY})
    endif()
  endif()
  if(DEFINED P_APIDOC_INPUT)
    wpGenerateApiDoc(${BUILD_TARGET}apidoc
      ${P_FOLDER}
      INPUT ${P_APIDOC_INPUT}
      OUTPUT ${P_APIDOC_OUTPUT}
      ${P_WORKING_DIRECTORY}
      ${P_YARN_TARGET}
      )
  endif()
  xpSourceListAppend()
endfunction()

# ARGV0 - What to name the test target (without test)
# ADD_SUBMODULE_TEST_LABEL - Should it add the submodule-unit-test label
# CMAKELIST - Where is webpro version specified
# FOLDER - What folder to put the target under
# DEPENDS - What targets does the test depend on
# TEST_DIR - Where are the test files
# WORKING_DIRECTORY - Where to perform the command
function(wpAddAddonTest)
  set(TEST_TARGET ${ARGV0})
  set(optionArgs ADD_SUBMODULE_TEST_LABEL)
  set(oneValueArgs CMAKELIST FOLDER TEST_DIR WORKING_DIRECTORY)
  set(multiValueArgs DEPENDS)
  cmake_parse_arguments(P "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  wpVerifyCMakeLists(CMAKELIST) # Sets P_CMAKELIST
  if(NOT DEFINED P_FOLDER AND DEFINED folder_unittest)
    set(P_FOLDER FOLDER ${folder_unittest}/${TEST_TARGET})
  endif()
  set(P_TEST_FOLDER ${P_FOLDER})
  if(P_ADD_SUBMODULE_TEST_LABEL)
    set(ADD_SUBMODULE_TEST_LABEL ADD_SUBMODULE_TEST_LABEL)
  endif()
  wpVerifyTestFolder() # Sets P_TEST_FOLDER
  wpSetIfDefined(TEST_DIR) # Sets P_TEST_DIR
  wpSetIfDefined(DEPENDS) # Sets P_DEPENDS
  wpSetIfDefined(WORKING_DIRECTORY) # Sets P_WORKING_DIRECTORY
  wpAddYarnTarget(${TEST_TARGET}Deps ${P_CMAKELIST} ${P_TEST_FOLDER} ${P_WORKING_DIRECTORY})
  list(APPEND P_DEPENDS ${TEST_TARGET}Deps)
  wpAddJasmineTest(${TEST_TARGET} ${ADD_SUBMODULE_TEST_LABEL} ${P_DEPENDS} EXCLUDE_COVERAGE ${P_TEST_FOLDER} ${P_TEST_DIR} ${P_WORKING_DIRECTORY})
  xpSourceListAppend()
endfunction()

function(wpAddTypescriptEchoTarget)
  if(CMAKE_BINARY_DIR STREQUAL CMAKE_CURRENT_BINARY_DIR)
    get_property(ecmaScriptTargets GLOBAL PROPERTY ecmaScriptTargets_property)
    add_custom_target(ListTypescript
      COMMAND ${CMAKE_COMMAND} -E echo ${ecmaScriptTargets}
      )
  endif()
endfunction()
