set(buildpro_REV latest)
include(xpfunmac)
if(NOT DEFINED externpro_REV)
  set(externpro_REV 24.05)
endif()
find_package(externpro REQUIRED) # github.com/smanders/externpro
if(webpro)
  set(webpro_REV 24.05)
  find_package(webpro REQUIRED)
  include(xpweb)
endif()
if(NOT DEFINED XP_SANITIZER)
  set(XP_SANITIZER "ASAN")
endif()
if(NOT DEFINED XP_COVERAGE)
  set(XP_COVERAGE ON)
endif()
list(APPEND XP_COVERAGE_RM '*/test/*' '*/tool/*')
xpSetFlags()
set(GRAPHVIZ_EXTERNAL_LIBS FALSE)
set(GRAPHVIZ_GENERATE_PER_TARGET FALSE)
set(GRAPHVIZ_GENERATE_DEPENDERS FALSE)
if(NOT DEFINED cppCoverage)
  set(cppCoverage ON)
endif()
if(cppCoverage)
  list(APPEND langs CPP)
endif()
if(webpro)
  list(APPEND langs JS)
endif()
if(csharpCoverage)
  list(APPEND langs CSharp)
endif()
xpAddCoverage(${langs})
