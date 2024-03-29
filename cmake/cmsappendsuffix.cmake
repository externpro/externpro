file(GLOB files ${src})
foreach(f ${files})
  get_filename_component(dir ${f} DIRECTORY)
  get_filename_component(ext ${f} EXT)
  get_filename_component(nam ${f} NAME_WE)
  execute_process(COMMAND ${CMAKE_COMMAND} -E rename ${f} ${dir}/${nam}${suffix}${ext})
endforeach()
