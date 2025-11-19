# @param[in] src : source
# @param[in] dst : destination
# @param[in] md5 : MD5 hash (or checksum)
# @param[in] wg : workgroup
while(NOT EXISTS ${dst})
  execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${dst})
  if(NOT EXISTS ${dst})
    execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 5)
  endif()
endwhile()
get_filename_component(fn ${src} NAME)
string(REGEX MATCH "^//" uncpath ${src})
if((NOT WIN32) AND (NOT ${uncpath} STREQUAL ""))
  if(NOT EXISTS ${dst}/${fn})
    # smbget - wget-like utility for download files over SMB
    set(smbget_cmd smbget --keep-permissions
      --username=$ENV{USER} --workgroup=${wg} #--password=
      )
    execute_process(COMMAND ${smbget_cmd} smb:${src} WORKING_DIRECTORY ${dst})
  endif()
else()
  file(COPY ${src} DESTINATION ${dst} USE_SOURCE_PERMISSIONS)
endif()
file(MD5 ${dst}/${fn} md5sum)
if(NOT ${md5sum} STREQUAL ${md5})
  message(FATAL_ERROR
    "* MD5 mismatch: ${fn}\n"
    "  MD5 expected: ${md5}\n"
    "  MD5 computed: ${md5sum}"
    )
endif()
