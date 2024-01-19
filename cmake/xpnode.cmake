# this file (xpnode.cmake) installed to share/cmake
get_filename_component(XP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(XP_ROOTDIR ${XP_ROOTDIR} ABSOLUTE) # remove relative parts
if(MSVC)
  if(NOT TARGET xpro::node)
    add_library(xpro::node STATIC IMPORTED)
    set_property(TARGET xpro::node APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
    set_target_properties(xpro::node PROPERTIES
      IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C;CXX"
      IMPORTED_LOCATION_RELEASE "${XP_ROOTDIR}/lib/node.lib"
      )
  endif()
else()
  if(NOT TARGET xpro::node)
    add_library(xpro::node INTERFACE IMPORTED)
  endif()
endif()
set(incDirs
  ${XP_ROOTDIR}/include/node_${nodeVer}
  ${XP_ROOTDIR}/include/node_${nodeVer}/node
  )
set_target_properties(xpro::node PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${incDirs}"
  )
