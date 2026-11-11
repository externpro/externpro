if(SCENARIO STREQUAL "other_dir")
  # GLOBAL target created in a subdir: globally visible but NOT in the
  # top-level dir's ImportedTargets map
  add_library(dep::dep INTERFACE IMPORTED GLOBAL)
elseif(SCENARIO STREQUAL "local_dep")
  add_library(dep::dep INTERFACE IMPORTED)
endif()
