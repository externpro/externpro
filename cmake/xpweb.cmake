# ipweb prefix = private web functions (intended to be used only internally)
# xpweb prefix = public web functions
set(xpThisDir ${CMAKE_CURRENT_LIST_DIR})

function(ipwebVerifyWebproDir)
  if(NOT webpro_DIR)
    message(FATAL_ERROR "webpro_DIR is undefined")
  endif()
endfunction()

function(ipwebVerifyTargetName targetName)
  if(NOT DEFINED ${targetName})
    message(FATAL_ERROR "Target name is required but not provided")
  endif()
endfunction()

function(ipwebVerifyCMakeLists)
  if(NOT DEFINED P_CMAKELIST)
    if(EXISTS ${CMAKE_SOURCE_DIR}/.devcontainer/cmake/xptoplevel.cmake)
      set(P_CMAKELIST ${CMAKE_SOURCE_DIR}/.devcontainer/cmake/xptoplevel.cmake)
      set(P_CMAKELIST ${P_CMAKE_LIST} PARENT_SCOPE)
    else()
      message(WARNING "The CMakeLists where webpro is set is not given. This may not rebuild when it needs to")
    endif()
  endif()
endfunction()

function(ipwebVerifyWorkingDirectory)
  if(NOT DEFINED P_WORKING_DIRECTORY OR P_WORKING_DIRECTORY STREQUAL "")
    set(P_WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    set(P_WORKING_DIRECTORY ${P_WORKING_DIRECTORY} PARENT_SCOPE)
  endif()
  if(NOT EXISTS ${P_WORKING_DIRECTORY})
    message(FATAL_ERROR "Working directory must exist")
  endif()
endfunction()

function(ipwebGetNodeXpPath)
  if(NOT DEFINED NODEXP_EXE)
    xpGetPkgVar(nodexp EXE) # sets NODEXP_EXE
    set(NODEXP_EXE ${NODEXP_EXE} PARENT_SCOPE)
  endif()
endfunction()

function(ipwebGetNodeNgPath)
  if(NOT DEFINED NODENG_EXE)
    xpGetPkgVar(nodeng EXE) # sets NODENG_EXE
    set(NODENG_EXE ${NODENG_EXE} PARENT_SCOPE)
  endif()
endfunction()

function(ipwebGetYarnPath)
  if(NOT DEFINED YARN_SCRIPT)
    xpGetPkgVar(yarn SCRIPT) # sets YARN_SCRIPT
    set(YARN_SCRIPT ${YARN_SCRIPT} PARENT_SCOPE)
  endif()
endfunction()

function(ipwebGetAngularPath)
  if(NOT DEFINED ANGULAR-CLI_SCRIPT)
    xpGetPkgVar(angular-cli SCRIPT) # sets ANGULAR-CLI_SCRIPT
    set(ANGULAR-CLI_SCRIPT ${ANGULAR-CLI_SCRIPT} PARENT_SCOPE)
  endif()
endfunction()

function(ipwebVerifySrcs srcs)
  if(NOT DEFINED ${srcs})
    message(FATAL_ERROR "No sources were given, this target will not rebuild correctly")
  endif()
endfunction()

function(ipwebVerifyFolder)
  if(DEFINED P_FOLDER)
    set(P_FOLDER FOLDER ${P_FOLDER})
  elseif(DEFINED folder)
    set(P_FOLDER FOLDER ${folder})
  endif()
  set(P_FOLDER ${P_FOLDER} PARENT_SCOPE)
endfunction()

function(ipwebVerifyTestDir)
  if(NOT DEFINED P_TEST_DIR)
    set(P_TEST_DIR test)
    set(P_TEST_DIR ${P_TEST_DIR} PARENT_SCOPE)
  endif()
endfunction()

function(ipwebVerifyTestFolder)
  if(DEFINED P_TEST_FOLDER)
    set(P_TEST_FOLDER FOLDER ${P_TEST_FOLDER})
  elseif(DEFINED folder_unittest)
    set(P_TEST_FOLDER FOLDER ${folder_unittest})
  endif()
  set(P_TEST_FOLDER ${P_TEST_FOLDER} PARENT_SCOPE)
endfunction()

function(ipwebVerifyYarnTarget)
  if(NOT DEFINED P_YARN_TARGET)
    message(FATAL_ERROR "This target requires a dependency upon an install target")
  endif()
  list(APPEND P_DEPENDS ${P_YARN_TARGET})
  set(P_DEPENDS ${P_DEPENDS} PARENT_SCOPE)
endfunction()

function(ipwebSetBuildProperties target)
  set_property(TARGET ${target} PROPERTY STAMP ${build_stamp})
  if(DEFINED P_FOLDER)
    set_property(TARGET ${target} PROPERTY ${P_FOLDER})
  endif()
  if(DEFINED build_dir)
    set_property(TARGET ${target} PROPERTY BUILD_DIR ${build_dir})
  endif()
endfunction()

function(ipwebCalculateDependencies)
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

function(ipwebGetInstallComponent)
  if(DEFINED P_INSTALL_COMPONENT)
    set(component COMPONENT ${P_INSTALL_COMPONENT})
    set(component ${component} PARENT_SCOPE)
  endif()
endfunction()

function(ipwebInstallBuildDir)
  if(DEFINED P_INSTALL_DESTINATION)
    ipwebGetInstallComponent()
    install(DIRECTORY ${build_dir}/ DESTINATION ${P_INSTALL_DESTINATION} ${component} PATTERN "bin/Node*.node" EXCLUDE)
  endif()
endfunction()

function(ipwebSetIfNotDefined)
  if(NOT DEFINED ${ARGV0})
    set(${ARGV0} ${ARGV1} PARENT_SCOPE)
  endif()
endfunction()

function(ipwebSetIfDefined arg)
  if(DEFINED P_${arg})
    set(P_${arg} ${arg} "${P_${arg}}")
    set(P_${arg} ${P_${arg}} PARENT_SCOPE)
  endif()
endfunction()

function(ipwebAddTypescriptLibrary)
  if(ARGV0 OR ARGV1)
    return()
  endif()
  get_property(ecmaScriptTargets GLOBAL PROPERTY ecmaScriptTargets_property)
  list(APPEND ecmaScriptTargets ${CMAKE_CURRENT_SOURCE_DIR})
  set_property(GLOBAL PROPERTY ecmaScriptTargets_property "${ecmaScriptTargets}")
endfunction()

function(ipwebAddTestTarget target)
  ipwebVerifyTestDir() # Can set P_TEST_DIR
  ipwebVerifyFolder() # Can set P_FOLDER
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
function(xpwebAddYarnTarget)
  set(YARN_TARGET ${ARGV0})
  set(oneValueArgs CMAKELIST FOLDER WORKING_DIRECTORY)
  cmake_parse_arguments(P "" "${oneValueArgs}" "" ${ARGN})
  ipwebVerifyWebproDir()
  ipwebVerifyTargetName(YARN_TARGET)
  ipwebVerifyCMakeLists()
  ipwebVerifyWorkingDirectory() # Can set P_WORKING_DIRECTORY
  ipwebGetNodeXpPath() # sets NODEXP_EXE
  ipwebGetYarnPath() # sets YARN_SCRIPT
  ipwebVerifyFolder() # Can set P_FOLDER
  if(TARGET ${YARN_TARGET})
    return()
  endif()
  configure_file(${webpro_DIR}/share/cmake/.yarnrc.in ${CMAKE_CURRENT_BINARY_DIR}/.yarnrc)
  set(build_stamp ${P_WORKING_DIRECTORY}/node_modules/.yarn-integrity)
  add_custom_command(OUTPUT ${build_stamp}
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${webpro_DIR}/share/yarn.lock ${P_WORKING_DIRECTORY}
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_BINARY_DIR}/.yarnrc ${P_WORKING_DIRECTORY}
    COMMAND ${NODEXP_EXE} ${YARN_SCRIPT} install --offline --pure-lockfile --ignore-scripts
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
  ipwebSetBuildProperties(${YARN_TARGET})
endfunction()

# ARGV0 - What to name the target
# FOLDER - What folder to put the target under
# VERSION_DEST - Where to put the version file
function(xpwebGenerateVersion)
  set(VERSION_TARGET ${ARGV0})
  set(oneValueArgs FOLDER VERSION_DEST)
  cmake_parse_arguments(P "" "${oneValueArgs}" "" ${ARGN})
  ipwebVerifyWebproDir()
  ipwebVerifyTargetName(VERSION_TARGET)
  ipwebVerifyFolder() # Can set P_FOLDER
  if(NOT DEFINED P_VERSION_DEST)
    message(FATAL_ERROR "xpwebGenerateVersion requires a destination")
  endif()
  if(P_VERSION_DEST MATCHES ".*ts")
    set(versionToMake ts)
  elseif(P_VERSION_DEST MATCHES ".*js")
    set(versionToMake js)
  else()
    message(FATAL_ERROR "xpwebGenerateVersion only supports .ts or .js")
  endif()
  ipwebSetIfNotDefined(PACKAGE_VERSION_MAJOR ${CMAKE_PROJECT_VERSION_MAJOR})
  ipwebSetIfNotDefined(PACKAGE_VERSION_MINOR ${CMAKE_PROJECT_VERSION_MINOR})
  ipwebSetIfNotDefined(PACKAGE_VERSION_PATCH ${CMAKE_PROJECT_VERSION_PATCH})
  ipwebSetIfNotDefined(PACKAGE_VERSION_TWEAK ${CMAKE_PROJECT_VERSION_TWEAK})
  ipwebSetIfNotDefined(FILE_VERSION_MAJOR ${CMAKE_PROJECT_VERSION_MAJOR})
  ipwebSetIfNotDefined(FILE_VERSION_MINOR ${CMAKE_PROJECT_VERSION_MINOR})
  ipwebSetIfNotDefined(FILE_VERSION_PATCH ${CMAKE_PROJECT_VERSION_PATCH})
  ipwebSetIfNotDefined(FILE_VERSION_TWEAK ${CMAKE_PROJECT_VERSION_TWEAK})
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
  configure_file(${xpThisDir}/version.${versionToMake}.in ${CMAKE_CURRENT_BINARY_DIR}/version.es.in @ONLY)
  include(versionjs)
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
function(xpwebGenerateProto)
  set(GENERATE_TARGET ${ARGV0})
  set(oneValueArgs FOLDER PROTO_DEST TARGET_FORMAT WORKING_DIRECTORY YARN_TARGET)
  set(multiValueArgs PROTO_SRCS)
  cmake_parse_arguments(P "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  ipwebVerifyWebproDir()
  ipwebVerifyTargetName(GENERATE_TARGET)
  ipwebVerifyFolder() # Can set P_FOLDER
  ipwebVerifyWorkingDirectory() # Can set P_WORKING_DIRECTORY
  ipwebVerifyYarnTarget()
  file(GLOB P_PROTO_SRCS ${P_PROTO_SRCS})
  ipwebVerifySrcs(P_PROTO_SRCS)
  ipwebGetNodeXpPath() # sets NODEXP_EXE
  if(NOT DEFINED P_PROTO_DEST)
    message(FATAL_ERROR "xpwebGenerateProto requires a destination")
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
    COMMAND ${NODEXP_EXE} ${P_WORKING_DIRECTORY}/${PROTOBUFJS-CLI_SCRIPT} --keep-case -t ${P_TARGET_FORMAT} -w commonjs
      -o ${protobufJsOut} -l eslint-disable -r ${ARGV0} ${P_PROTO_SRCS}
    COMMAND ${NODEXP_EXE} ${PROTOBUFJS-CLI_PBTS_SCRIPT} -o ${protobufTsOut} ${protobufJsOut}
    COMMAND ${CMAKE_COMMAND} -E touch ${protobufJsOut} ${protobufTsOut}
    DEPENDS ${P_YARN_TARGET} ${P_PROTO_SRCS}
    WORKING_DIRECTORY ${P_WORKING_DIRECTORY}
    )
  add_custom_target(${GENERATE_TARGET} ALL
    DEPENDS ${P_YARN_TARGET}
    SOURCES ${P_PROTO_SRCS}
    )
  ipwebSetBuildProperties(${GENERATE_TARGET})
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
function(xpwebAddLibrary)
  set(BUILD_TARGET ${ARGV0})
  set(optionArgs LIBRARY_DIR SKIP_YARN_TARGET TEST_TOOL)
  set(oneValueArgs FOLDER WORKING_DIRECTORY YARN_TARGET)
  set(multiValueArgs SRCS DEPENDS)
  cmake_parse_arguments(P "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  ipwebVerifyWebproDir()
  ipwebVerifyTargetName(BUILD_TARGET)
  ipwebVerifyFolder() # Can set P_FOLDER
  ipwebVerifyWorkingDirectory() # Can set P_WORKING_DIRECTORY
  if(NOT P_SKIP_YARN_TARGET)
    ipwebVerifyYarnTarget() # appends YARN_TARGET to P_DEPENDS
    ipwebCalculateDependencies() # returns: depends
  endif()
  ipwebVerifySrcs(P_SRCS)
  set(build_dir ${CMAKE_CURRENT_BINARY_DIR}/build)
  set(build_stamp ${CMAKE_CURRENT_BINARY_DIR}/xpwebStamp/${BUILD_TARGET}.stamp)
  add_custom_command(OUTPUT ${build_stamp}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/xpwebStamp
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
  ipwebSetBuildProperties(${BUILD_TARGET})
  ipwebAddTypescriptLibrary(${P_TEST_TOOL} ${P_LIBRARY_DIR})
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
function(xpwebAddBuildWebpack)
  set(BUILD_TARGET ${ARGV0})
  set(optionArgs EXCLUDE_WEB_LIBRARIES TEST_TOOL)
  set(oneValueArgs FOLDER INSTALL_COMPONENT INSTALL_DESTINATION INSTALL_NODE_DESTINATION WORKING_DIRECTORY YARN_TARGET)
  set(multiValueArgs SRCS DEPENDS OUTPUT_FILES)
  cmake_parse_arguments(P "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  ipwebVerifyWebproDir()
  ipwebVerifyTargetName(BUILD_TARGET)
  ipwebVerifyFolder() # Can set P_FOLDER
  ipwebVerifyWorkingDirectory() # Can set P_WORKING_DIRECTORY
  ipwebVerifyYarnTarget() # appends YARN_TARGET to P_DEPENDS
  ipwebVerifySrcs(P_SRCS)
  ipwebGetNodeXpPath() # sets NODEXP_EXE
  ipwebCalculateDependencies() # returns: depends
  if(NOT DEFINED WEBPACK-CLI_SCRIPT)
    xpGetPkgVar(webpack-cli SCRIPT) # sets WEBPACK-CLI_SCRIPT
  endif()
  if(P_EXCLUDE_WEB_LIBRARIES)
    set(build_stamp ${CMAKE_CURRENT_BINARY_DIR}/xpwebStamp/${BUILD_TARGET}.stamp)
    set(commandToRun ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/xpwebStamp
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
    set(commandToRun ${CMAKE_COMMAND} -E env BROWSERSLIST_IGNORE_OLD_DATA=True ${NODEXP_EXE} ${WEBPACK-CLI_SCRIPT} --output-path ${build_dir} --env context=${CMAKE_CURRENT_SOURCE_DIR})
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
  ipwebSetBuildProperties(${BUILD_TARGET})
  if(NOT P_EXCLUDE_WEB_LIBRARIES)
    ipwebInstallBuildDir()
    ipwebGetInstallComponent() # Sets component
    if(NOT DEFINED P_INSTALL_NODE_DESTINATION)
      set(P_INSTALL_NODE_DESTINATION bin)
    endif()
    install(PROGRAMS ${NODEXP_EXE} DESTINATION ${P_INSTALL_NODE_DESTINATION} ${component})
  endif()
  ipwebAddTypescriptLibrary(${P_TEST_TOOL} FALSE)
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
function(xpwebAddBuildAngular)
  set(BUILD_TARGET ${ARGV0})
  set(optionArgs ARCHIVE_BUILD EXCLUDE_WEB_LIBRARIES TEST_TOOL)
  set(oneValueArgs ANGULAR_PROJECT FOLDER INSTALL_COMPONENT INSTALL_DESTINATION WORKING_DIRECTORY YARN_TARGET)
  set(multiValueArgs SRCS DEPENDS EXTRA_PACKAGE_FILES)
  cmake_parse_arguments(P "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  ipwebVerifyWebproDir()
  ipwebVerifyTargetName(BUILD_TARGET)
  ipwebVerifyFolder() # Can set P_FOLDER
  ipwebVerifyWorkingDirectory() # Can set P_WORKING_DIRECTORY
  ipwebVerifyYarnTarget() # appends YARN_TARGET to P_DEPENDS
  ipwebVerifySrcs(P_SRCS)
  ipwebGetNodeNgPath() # sets NODENG_EXE
  ipwebCalculateDependencies() # returns: depends
  ipwebGetAngularPath() # sets ANGULAR-CLI_SCRIPT
  if(DEFINED P_ANGULAR_PROJECT)
    set(project --project=${P_ANGULAR_PROJECT})
  endif()
  if(P_EXCLUDE_WEB_LIBRARIES)
    set(build_stamp ${CMAKE_CURRENT_BINARY_DIR}/xpwebStamp/${BUILD_TARGET}.stamp)
    set(commandToRun -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/xpwebStamp
      COMMAND ${CMAKE_COMMAND} -E touch ${build_stamp}
      )
  else()
    set(build_dir ${CMAKE_CURRENT_BINARY_DIR}/build)
    set(build_stamp ${build_dir}/index.html)
    set(commandToRun -P ${xpThisDir}/NodePath.cmake ${P_WORKING_DIRECTORY}
      ${NODENG_EXE} ${CMAKE_COMMAND} -E env BROWSERSLIST_IGNORE_OLD_DATA=True ${NODENG_EXE} ${ANGULAR-CLI_SCRIPT} build ${project}
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
  ipwebSetBuildProperties(${BUILD_TARGET})
  if(NOT P_EXCLUDE_WEB_LIBRARIES)
    if(DEFINED archive AND P_INSTALL_DESTINATION)
      ipwebGetInstallComponent()
      install(FILES ${archive} DESTINATION ${P_INSTALL_DESTINATION} ${component})
    else()
      ipwebInstallBuildDir()
    endif()
  endif()
  ipwebAddTypescriptLibrary(${P_TEST_TOOL} FALSE)
endfunction()

# ARGV0 - What to name the target
# ADD_SUBMODULE_TEST_LABEL - Should it add the submodule-unit-test label
# DEPENDS - What targets does the test depend on
# FOLDER - What folder to put the target under
# TEST_DIR - Where are the test files
# WORKING_DIRECTORY - Where to perform the command
function(xpwebAddTestJasmine)
  set(BUILD_TARGET ${ARGV0})
  set(optionArgs ADD_SUBMODULE_TEST_LABEL EXCLUDE_COVERAGE)
  set(oneValueArgs FOLDER TEST_DIR WORKING_DIRECTORY)
  set(multiValueArgs DEPENDS)
  cmake_parse_arguments(P "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  ipwebVerifyWebproDir()
  ipwebVerifyTargetName(BUILD_TARGET)
  ipwebVerifyWorkingDirectory() # Can set P_WORKING_DIRECTORY
  ipwebGetNodeXpPath() # Sets NODEXP_EXE
  if(NOT DEFINED JASMINE_SCRIPT)
    xpGetPkgVar(jasmine SCRIPT) # Sets JASMINE_SCRIPT
  endif()
  if(NOT DEFINED TS-NODE_SCRIPT)
    xpGetPkgVar(ts-node SCRIPT) # Sets TS-NODE_SCRIPT
  endif()
  ipwebAddTestTarget(${BUILD_TARGET}) # Uses DEPENDS, FOLDER, TEST_DIR
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
    COMMAND ${JS_SERVER_COVERAGE_FLAGS} ${NODEXP_EXE} ${P_WORKING_DIRECTORY}/${TS-NODE_SCRIPT} --project ${CMAKE_CURRENT_SOURCE_DIR}/tsconfig.spec.json
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
function(xpwebAddTestAngular)
  set(BUILD_TARGET ${ARGV0})
  set(optionArgs ADD_SUBMODULE_TEST_LABEL)
  set(oneValueArgs ANGULAR_PROJECT FOLDER TEST_DIR WORKING_DIRECTORY)
  set(multiValueArgs DEPENDS)
  cmake_parse_arguments(P "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  ipwebVerifyWebproDir()
  ipwebVerifyTargetName(BUILD_TARGET)
  ipwebVerifyWorkingDirectory() # Can set P_WORKING_DIRECTORY
  ipwebGetNodeNgPath() # sets NODENG_EXE
  ipwebGetAngularPath() # sets ANGULAR-CLI_SCRIPT
  if(WIN32)
    set(unit_test_browser ChromeHeadless)
  else()
    set(unit_test_browser ChromeHeadlessNoSandbox)
  endif()
  if(DEFINED P_ANGULAR_PROJECT)
    set(project --project=${P_ANGULAR_PROJECT})
  endif()
  ipwebAddTestTarget(${BUILD_TARGET})
  add_test(NAME ${BUILD_TARGET}Test
    COMMAND ${NODENG_EXE} ${ANGULAR-CLI_SCRIPT} test ${project}
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
function(xpwebGenerateApiDoc)
  set(GENERATE_TARGET ${ARGV0})
  set(oneValueArgs FOLDER INPUT OUTPUT WORKING_DIRECTORY YARN_TARGET)
  cmake_parse_arguments(P "" "${oneValueArgs}" "" ${ARGN})
  ipwebVerifyFolder() # Can set P_FOLDER
  ipwebGetNodeXpPath() # sets NODEXP_EXE
  ipwebVerifyWorkingDirectory() # Can set P_WORKING_DIRECTORY
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
    COMMAND ${NODEXP_EXE} ${P_WORKING_DIRECTORY}/${APIDOC_SCRIPT} -i ${P_INPUT} -o ${CMAKE_CURRENT_BINARY_DIR}/${P_OUTPUT}
    COMMAND ${CMAKE_COMMAND} -E touch ${build_stamp}
    WORKING_DIRECTORY ${P_WORKING_DIRECTORY}
    DEPENDS ${routeSrcs} ${P_YARN_TARGET}
    )
  add_custom_target(${GENERATE_TARGET} ALL DEPENDS ${build_stamp})
  ipwebSetBuildProperties(${GENERATE_TARGET})
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
function(xpwebInstallNBuild)
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
  ipwebSetIfDefined(CMAKELIST) # Sets P_CMAKELIST
  ipwebVerifyFolder() # Sets P_FOLDER
  if(DEFINED P_FOLDER AND (DEFINED P_APIDOC_INPUT OR DEFINED P_PROTO_SRCS OR NOT TARGET ${P_YARN_TARGET}))
    set(P_FOLDER ${P_FOLDER}/${BUILD_TARGET}Targets)
  endif()
  ipwebSetIfDefined(WORKING_DIRECTORY) # Sets P_WORKING_DIRECTORY
  xpwebAddYarnTarget(${P_YARN_TARGET} ${P_CMAKELIST} ${P_FOLDER} ${P_WORKING_DIRECTORY})
  set(P_YARN_TARGET YARN_TARGET ${P_YARN_TARGET})
  ipwebSetIfDefined(DEPENDS) # Sets P_DEPENDS
  if(DEFINED P_VERSION_DEST)
    xpwebGenerateVersion(${BUILD_TARGET}_version ${P_FOLDER} VERSION_DEST ${P_VERSION_DEST})
    list(APPEND P_DEPENDS ${BUILD_TARGET}_version)
  endif()
  if(DEFINED P_PROTO_SRCS)
    ipwebSetIfDefined(PROTO_DEST) # Sets P_PROTO_DEST
    ipwebSetIfDefined(PROTO_SRCS) # Sets P_PROTO_SRCS
    ipwebSetIfDefined(TARGET_FORMAT) # Sets P_TARGET_FORMAT
    xpwebGenerateProto(${BUILD_TARGET}-pb
      ${P_FOLDER}
      ${P_PROTO_DEST}
      ${P_PROTO_SRCS}
      ${P_TARGET_FORMAT}
      ${P_WORKING_DIRECTORY}
      ${P_YARN_TARGET}
      )
    list(APPEND P_DEPENDS ${BUILD_TARGET}-pb)
  endif()
  ipwebSetIfDefined(SRCS) # Sets P_SRCS
  ipwebSetIfDefined(INSTALL_COMPONENT) # Sets P_INSTALL_COMPONENT
  ipwebSetIfDefined(INSTALL_DESTINATION) # Sets P_INSTALL_DESTINATION
  ipwebSetIfDefined(ANGULAR_PROJECT) # Sets P_ANGULAR_PROJECT
  ipwebSetIfDefined(EXCLUDE_FROM_ALL) # Sets P_EXCLUDE_FROM_ALL
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
    xpwebAddLibrary(${BUILD_TARGET} ${P_DEPENDS} ${P_FOLDER} ${LIBRARY_DIR} ${P_SRCS} ${TEST_TOOL} ${P_WORKING_DIRECTORY} ${P_YARN_TARGET})
  elseif(P_TYPE STREQUAL "webpack")
    ipwebSetIfDefined(OUTPUT_FILES) # Sets P_OUTPUT_FILES
    ipwebSetIfDefined(INSTALL_NODE_DESTINATION) # Sets P_INSTALL_NODE_DESTINATION
    xpwebAddBuildWebpack(${BUILD_TARGET}
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
    ipwebSetIfDefined(EXTRA_PACKAGE_FILES) # Sets P_EXTRA_PACKAGE_FILES
    xpwebAddBuildAngular(${BUILD_TARGET}
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
    ipwebSetIfDefined(TEST_DIR) # Sets P_TEST_DIR
    if(DEFINED P_TEST_DEPENDS)
      set(P_TEST_DEPENDS DEPENDS ${P_TEST_DEPENDS})
    endif()
    if(P_ADD_SUBMODULE_TEST_LABEL)
      set(ADD_SUBMODULE_TEST_LABEL ADD_SUBMODULE_TEST_LABEL)
    endif()
    ipwebVerifyTestFolder() # Sets P_TEST_FOLDER
    if(P_TYPE STREQUAL "angular")
      xpwebAddTestAngular(${BUILD_TARGET} ${ADD_SUBMODULE_TEST_LABEL} ${P_ANGULAR_PROJECT} ${P_TEST_DEPENDS} ${P_TEST_DIR} ${P_TEST_FOLDER} ${P_WORKING_DIRECTORY} ${P_YARN_TARGET})
    else()
      xpwebAddTestJasmine(${BUILD_TARGET} ${ADD_SUBMODULE_TEST_LABEL} ${P_TEST_DIR} ${P_TEST_DEPENDS} ${P_TEST_FOLDER} ${P_WORKING_DIRECTORY})
    endif()
  endif()
  if(DEFINED P_APIDOC_INPUT)
    xpwebGenerateApiDoc(${BUILD_TARGET}apidoc
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
function(xpwebAddTestAddon)
  set(TEST_TARGET ${ARGV0})
  set(optionArgs ADD_SUBMODULE_TEST_LABEL)
  set(oneValueArgs CMAKELIST FOLDER TEST_DIR WORKING_DIRECTORY)
  set(multiValueArgs DEPENDS)
  cmake_parse_arguments(P "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  ipwebVerifyCMakeLists(CMAKELIST) # Sets P_CMAKELIST
  if(NOT DEFINED P_FOLDER AND DEFINED folder_unittest)
    set(P_FOLDER FOLDER ${folder_unittest}/${TEST_TARGET})
  endif()
  set(P_TEST_FOLDER ${P_FOLDER})
  if(P_ADD_SUBMODULE_TEST_LABEL)
    set(ADD_SUBMODULE_TEST_LABEL ADD_SUBMODULE_TEST_LABEL)
  endif()
  ipwebVerifyTestFolder() # Sets P_TEST_FOLDER
  ipwebSetIfDefined(TEST_DIR) # Sets P_TEST_DIR
  ipwebSetIfDefined(DEPENDS) # Sets P_DEPENDS
  ipwebSetIfDefined(WORKING_DIRECTORY) # Sets P_WORKING_DIRECTORY
  xpwebAddYarnTarget(${TEST_TARGET}Deps ${P_CMAKELIST} ${P_TEST_FOLDER} ${P_WORKING_DIRECTORY})
  list(APPEND P_DEPENDS ${TEST_TARGET}Deps)
  xpwebAddTestJasmine(${TEST_TARGET} ${ADD_SUBMODULE_TEST_LABEL} ${P_DEPENDS} EXCLUDE_COVERAGE ${P_TEST_FOLDER} ${P_TEST_DIR} ${P_WORKING_DIRECTORY})
  xpSourceListAppend()
endfunction()

function(xpwebAddTypescriptEchoTarget)
  if(CMAKE_BINARY_DIR STREQUAL CMAKE_CURRENT_BINARY_DIR)
    get_property(ecmaScriptTargets GLOBAL PROPERTY ecmaScriptTargets_property)
    add_custom_target(ListTypescript
      COMMAND ${CMAKE_COMMAND} -E echo ${ecmaScriptTargets}
      )
  endif()
endfunction()
