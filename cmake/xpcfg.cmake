include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckFunctionExists)
include(CheckIncludeFile)
include(CheckLibraryExists)
include(CheckSymbolExists)
include(CheckTypeSize)
include(CMakePushCheckState)

function(xpcfgSetDefine var)
  if(${ARGC} GREATER 1 AND ${var})
    set(DEFINE_${var} cmakedefine01 PARENT_SCOPE)
  else()
    set(DEFINE_${var} cmakedefine PARENT_SCOPE)
  endif()
endfunction()

function(xpcfgSetDefineList)
  foreach(var ${ARGN})
    xpcfgSetDefine(${var} 1)
    set(DEFINE_${var} ${DEFINE_${var}} PARENT_SCOPE)
  endforeach()
endfunction()

macro(xpcfgCheckIncludeFile incfile var)
  check_include_file("${incfile}" ${var})
  xpcfgSetDefine(${var} 1)
  if(${var})
    list(APPEND XP_INCLUDES ${incfile})
  endif(${var})
endmacro()

macro(xpcfgCheckSymFnExists func var)
  check_symbol_exists("${func}" "${XP_INCLUDES}" ${var})
  if(NOT ${var})
    unset(${var} CACHE)
    check_function_exists("${func}" ${var})
  endif()
  xpcfgSetDefine(${var} 1)
endmacro()

macro(xpcfgCheckLibraryExists lib symbol var)
  check_library_exists("${lib};${FOO_SYSTEM_LIBS}" ${symbol} "${CMAKE_LIBRARY_PATH}" ${var})
  xpcfgSetDefine(${var} 1)
  if(${var})
    set(FOO_SYSTEM_LIBS ${lib} ${FOO_SYSTEM_LIBS})
  endif(${var})
endmacro()

macro(xpcfgCheckTypeSize)
  cmake_push_check_state(RESET)
  check_type_size(off_t SIZEOF_OFF_T) # sets HAVE_SIZEOF_OFF_T
  check_type_size(size_t SIZEOF_SIZE_T) # sets HAVE_SIZEOF_SIZE_T
  cmake_pop_check_state()
endmacro()

macro(xpcfgLtObjdir var)
  ####################
  # Define to the sub-directory in which libtool stores uninstalled libraries.
  execute_process(COMMAND libtool --version
    OUTPUT_QUIET ERROR_QUIET RESULT_VARIABLE hasLibtool
    )
  if(hasLibtool EQUAL 0) # 0 == success
    set(${var} .libs/)
  endif()
endmacro()

macro(xpcfgStdcHeaders var)
  ########################################
  # Define to 1 if you have the ANSI C header files.
  check_c_source_compiles("
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <float.h>
int main()
{
  ;
  return 0;
}
"   ${var}
    )
  xpcfgSetDefine(${var} 1)
endmacro(xpcfgStdcHeaders)

macro(xpcfgHugeFileSupport)
  # enabling huge-file support (64 bit file pointers)
  set(_FILE_OFFSET_BITS 64)
  set(_LARGEFILE_SOURCE 1)
  set(_LARGE_FILE 1)
endmacro()

macro(xpcfgConst)
  ########################################
  # Define to empty if `const' does not conform to ANSI C.
  check_c_source_compiles("
int main()
{
#ifndef __cplusplus
  /* Ultrix mips cc rejects this sort of thing.  */
  typedef int charset[2];
  const charset cs = { 0, 0 };
  /* SunOS 4.1.1 cc rejects this.  */
  char const *const *pcpcc;
  char **ppc;
  /* NEC SVR4.0.2 mips cc rejects this.  */
  struct point {int x, y;};
  static struct point const zero = {0,0};
  /* AIX XL C 1.02.0.0 rejects this.
     It does not let you subtract one const X* pointer from another in
     an arm of an if-expression whose if-part is not a constant
     expression */
  const char *g = \"string\";
  pcpcc = &g + (g ? g-g : 0);
  /* HPUX 7.0 cc rejects these. */
  ++pcpcc;
  ppc = (char**) pcpcc;
  pcpcc = (char const *const *) ppc;
  { /* SCO 3.2v4 cc rejects this sort of thing.  */
    char tx;
    char *t = &tx;
    char const *s = 0 ? (char *) 0 : (char const *) 0;

    *t++ = 0;
    if (s) return 0;
  }
  { /* Someone thinks the Sun supposedly-ANSI compiler will reject this.  */
    int x[] = {25, 17};
    const int *foo = &x[0];
    ++foo;
  }
  { /* Sun SC1.0 ANSI compiler rejects this -- but not the above. */
    typedef const int *iptr;
    iptr p = 0;
    ++p;
  }
  { /* AIX XL C 1.02.0.0 rejects this sort of thing, saying
       \"k.c\", line 2.27: 1506-025 (S) Operand must be a modifiable lvalue. */
    struct s { int j; const int *ap[3]; } bx;
    struct s *b = &bx; b->j = 5;
  }
  { /* ULTRIX-32 V3.1 (Rev 9) vcc rejects this */
    const int foo = 10;
    if (!foo) return 0;
  }
  return !cs[0] && !zero.x;
#endif
  ;
  return 0;
}
"   ANSI_CONST
    )
  if(NOT ANSI_CONST)
    set(const /**/)
  endif()
endmacro(xpcfgConst)

macro(xpcfgFnEmptyStringBug fn var)
  ########################################
  # checking whether specified fn (stat/lstat) accepts an empty string
  check_c_source_runs("
#include <sys/stat.h>
#include <stdlib.h>
int main()
{
  struct stat sbuf;
  return (${fn}(\"\", &sbuf) == 0)? EXIT_SUCCESS : EXIT_FAILURE;
}
"   ${var}
    )
  xpcfgSetDefine(${var} 1)
endmacro()

macro(xpcfgLstatFollowsSlashedSymlink var)
  ########################################
  # whether lstat correctly handles trailing slash
  # https://www.gnu.org/software/autoconf/manual/autoconf-2.60/html_node/Particular-Functions.html#index-AC_005fFUNC_005fLSTAT_005fFOLLOWS_005fSLASHED_005fSYMLINK-381
  # this check is for ancient systems, just set it to ON
  set(${var} ON)
  xpcfgSetDefine(${var} 1)
endmacro()

macro(xpcfgTimeWithSysTime var)
  ########################################
  # whether can safely include both <sys/time.h> and <time.h>
  # https://www.gnu.org/software/autoconf/manual/autoconf-2.67/html_node/Particular-Headers.html#AC_005fHEADER_005fTIME
  # this check is for ancient systems, just set it to OFF so the var isn't defined
  set(${var} OFF)
  xpcfgSetDefine(${var} 1)
endmacro()

macro(xpcfgTmInHdr hdr var)
  ########################################
  # checking whether struct tm is in specified hdr (sys/time.h or time.h)
  check_c_source_compiles("
#include <${hdr}>
int main()
{
  struct tm tm;
  int *p = &tm.tm_sec;
  return !p;
}
"   ${var}
    )
  xpcfgSetDefine(${var} 1)
endmacro()

macro(xpcfgVolatile var)
  ########################################
  # checking for working volatile
  check_c_source_compiles("
int main()
{
  volatile int x;
  int * volatile y = (int *) 0;
  return !x && !y;
}
"   ${var}Compiles
    )
  if(${var}Compiles)
    unset(${var})
  else()
    set(${var} /**/)
  endif()
endmacro()

macro(xpcfgTargetCpu var)
  ####################
  # exporting the TARGET_CPU string
  execute_process(COMMAND ${CMAKE_C_COMPILER} -dumpmachine
    OUTPUT_VARIABLE ${var}
    OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET
    )
endmacro()
