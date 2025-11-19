# runs a command with node in the path
# CMAKE_ARGV0 : CMake command
# CMAKE_ARGV1 : -P (being passed into CMake)
# CMAKE_ARGV2 : CMake script to run (This script)
# CMAKE_ARGV3 : Where to run the command
# CMAKE_ARGV4 : Where the node executable is
# CMAKE_ARGV5 : What command to run
if(NOT DEFINED CMAKE_ARGV3)
  message(FATAL_ERROR "Argv3 must be set to where to run the command")
endif()
if(NOT DEFINED CMAKE_ARGV4)
  message(FATAL_ERROR "Argv4 must be set to where node is")
endif()
if(NOT DEFINED CMAKE_ARGV5)
  message(FATAL_ERROR "Argv5 must be set to the command to run")
endif()
if(WIN32)
  set(pathToUse $ENV{PATH})
  string(REPLACE ";" "\\\;" pathToUse "${pathToUse}")
  set(pathToUse "\\\;${pathToUse}")
else()
  set(pathToUse :$ENV{PATH})
endif()
get_filename_component(nodePath ${CMAKE_ARGV4} DIRECTORY)
foreach(arg RANGE 5 ${CMAKE_ARGC})
  list(APPEND command "${CMAKE_ARGV${arg}}")
endforeach()
execute_process(
  COMMAND ${CMAKE_COMMAND} -E env PATH=${nodePath}${pathToUse} ${command}
  WORKING_DIRECTORY ${CMAKE_ARGV3}
  COMMAND_ECHO NONE
  RESULT_VARIABLE ret
  )
if(NOT ret EQUAL "0")
  message(FATAL_ERROR "${command} " failed)
endif()
