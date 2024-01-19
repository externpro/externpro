########################################
# cmscopymanuals.cmake - copy manuals
# @param[in] manDef - filepath to cmake file with manual definitions
#  should define localwarning, dstDir, and srcDirs,doc,md5 lists
set(thisFile cmscopymanuals.cmake)
if(NOT DEFINED manDef)
  message(FATAL_ERROR "${thisFile}: manDef must be defined")
endif()
include(${manDef})
if(NOT EXISTS ${dstDir})
  execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${dstDir})
endif()
foreach(dir ${srcDirs})
  if(EXISTS ${dir} AND IS_DIRECTORY ${dir})
    set(srcDir ${dir})
    break()
  endif()
endforeach()
if(${srcDir} STREQUAL ${dstDir})
  message(AUTHOR_WARNING "${thisFile}: ${localwarning}")
endif()
message(STATUS "manual source directory: ${srcDir}")
########################################
list(LENGTH doc doclen)
list(LENGTH md5 md5len)
if(NOT ${doclen} EQUAL ${md5len})
  message(FATAL_ERROR "${thisFile}: doc md5 lengths don't match")
endif()
math(EXPR len "${doclen} - 1")
foreach(val RANGE ${len})
  list(GET doc ${val} _doc)
  list(GET md5 ${val} _md5)
  if(EXISTS ${dstDir}/${_doc})
    file(MD5 ${dstDir}/${_doc} md5chk)
    if(NOT ${md5chk} STREQUAL ${_md5})
      file(COPY ${srcDir}/${_doc} DESTINATION ${dstDir})
      message(STATUS "updated: ${_doc}")
    else()
      file(MD5 ${srcDir}/${_doc} md5src)
      if(NOT ${md5src} STREQUAL ${_md5})
        # file has been updated at source, but not in cmake
        file(COPY ${dstDir}/${_doc} DESTINATION ${dstDir}/oldVersions)
        file(COPY ${srcDir}/${_doc} DESTINATION ${dstDir})
        message(FATAL_ERROR
          "* MD5 mismatch: ${_doc}\n"
          "  MD5 expected: ${_md5}\n"
          "  MD5 computed: ${md5src}\n"
          "  ACTION REQUIRED: update ${manDef} with new MD5 for new revision."
          )
      else()
        message(STATUS "exists: ${_doc}")
      endif()
    endif()
  else() # doesn't exist in destination, yet
    file(COPY ${srcDir}/${_doc} DESTINATION ${dstDir})
    message(STATUS "copied: ${_doc}")
  endif()
  # check md5
  file(MD5 ${dstDir}/${_doc} md5sum)
  if(NOT ${md5sum} STREQUAL ${_md5})
    message(FATAL_ERROR
      "* MD5 mismatch: ${_doc}\n"
      "  MD5 expected: ${_md5}\n"
      "  MD5 computed: ${md5sum}\n"
      "  ACTION REQUIRED: update ${manDef} with new MD5 for new revision."
      )
  endif()
endforeach()
