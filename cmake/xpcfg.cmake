include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckFunctionExists)
include(CheckIncludeFile)
include(CheckLibraryExists)
include(CheckStructHasMember)
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

# called from: apr/configure.cmake
function(xpcfgSet01 var boolVar)
  if(${boolVar})
    set(${var} 1 PARENT_SCOPE)
  else()
    set(${var} 0 PARENT_SCOPE)
  endif()
endfunction()

# called from: apr/configure.cmake
macro(xpcfgCheckIncludeFile incfile var)
  check_include_file("${incfile}" ${var})
  if(${var})
    list(APPEND XP_INCLUDE_LIST ${incfile})
    string(APPEND XP_INCLUDES "#include <${incfile}>\n")
  endif(${var})
endmacro()

# called from: apr/configure.cmake
macro(xpcfgCheckSymFnExists func var)
  check_symbol_exists("${func}" "${XP_INCLUDE_LIST}" ${var})
  if(NOT ${var})
    unset(${var} CACHE)
    check_function_exists("${func}" ${var})
  endif()
endmacro()

# called from: apr/configure.cmake
macro(xpcfgCheckSymExistsInHdr sym hdr var)
  check_symbol_exists("${sym}" "${hdr}" ${var})
endmacro()

# called from: apr/configure.cmake
macro(xpcfgCheckLibraryExists lib symbol var)
  check_library_exists("${lib};${XP_SYSTEM_LIBS}" ${symbol} "${CMAKE_LIBRARY_PATH}" ${var})
  if(${var})
    set(XP_SYSTEM_LIBS ${lib} ${XP_SYSTEM_LIBS})
  endif(${var})
endmacro()

# called from: apr/configure.cmake
macro(xpcfgCheckStructHasMember struct member header variable)
  check_struct_has_member("${struct}" "${member}" "${header}" ${variable})
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

macro(xpcfgHugeFileSupport)
  # enabling huge-file support (64 bit file pointers)
  set(_FILE_OFFSET_BITS 64)
  set(_LARGEFILE_SOURCE 1)
  set(_LARGE_FILE 1)
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

# called from: apr/configure.cmake
macro(xpcfgConst var)
  # Define to empty if 'const' does not conform to ANSI C.
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
  if(ANSI_CONST)
    set(${var} 0) # cmakedefine
  else()
    set(${var} /**/)
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

# called from: apr/configure.cmake
macro(xpcfgGaiAddrconfig var)
  # Define if getaddrinfo accepts the AI_ADDRCONFIG flag
  check_c_source_compiles("
${XP_INCLUDES}
int main(int argc, char **argv)
{
  struct addrinfo hints, *ai;
  memset(&hints, 0, sizeof(hints));
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_flags = AI_ADDRCONFIG;
  return getaddrinfo(\"localhost\", NULL, &hints, &ai) != 0;
}
"   ${var}
    )
endmacro()

# called from: apr/configure.cmake
macro(xpcfgGetaddrinfo var)
  # Define to 1 if getaddrinfo exists and works well enough
  check_c_source_compiles("
${XP_INCLUDES}
int main(void)
{
  struct addrinfo hints;
  struct addrinfo *ai = 0;
  int error;
  memset(&hints, 0, sizeof(hints));
  hints.ai_flags = AI_NUMERICHOST;
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;
  error = getaddrinfo(\"127.0.0.1\", NULL, &hints, &ai);
  if(error || !ai || ai->ai_addr->sa_family != AF_INET)
    exit(1); /* fail */
  exit(0);
}
"   ${var}
    )
endmacro()

# called from: apr/configure.cmake
macro(xpcfgInetAddr var)
  check_c_source_compiles("
${XP_INCLUDES}
int main(void)
{
  inet_addr(\"127.0.0.1\");
  ;
  return 0;
}
"   ${var}
    )
endmacro()

# called from: apr/configure.cmake
macro(xpcfgInetNetwork var)
  check_c_source_compiles("
${XP_INCLUDES}
int main(void)
{
  inet_network(\"127.0.0.1\");
  ;
  return 0;
}
"   ${var}
    )
endmacro()

# called from: apr/configure.cmake
macro(xpcfgUnionSemun var)
  check_c_source_compiles("
${XP_INCLUDES}
int main(void)
{
  union semun arg;
  semctl(0,0,0,arg);
  ;
  return 0;
}
"   ${var}
    )
endmacro()

# called from: apr/configure.cmake
macro(xpcfgSctp var)
  check_c_source_compiles("
${XP_INCLUDES}
int main(void)
{
  int s, opt = 1;
  if ((s = socket(AF_INET, SOCK_STREAM, IPPROTO_SCTP)) < 0)
    exit(1);
  if (setsockopt(s, IPPROTO_SCTP, SCTP_NODELAY, &opt, sizeof(int)) < 0)
    exit(2);
  exit(0);
}
"   ${var}
    )
endmacro()

macro(xpcfgInt64C var)
  check_c_source_compiles("
${XP_INCLUDES}
int main(void)
{
#ifdef INT64_C
  return 0;
#else
  return 1;
#endif
}
"   ${var}
    )
endmacro()

macro(xpcfgTargetCpu var)
  ####################
  # exporting the TARGET_CPU string
  execute_process(COMMAND ${CMAKE_C_COMPILER} -dumpmachine
    OUTPUT_VARIABLE ${var}
    OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET
    )
endmacro()

# called from: apr/configure.cmake
function(xpcfgDotinFile in out)
  cmake_path(GET out FILENAME outFilename)
  cmake_path(GET in FILENAME inFilename)
  set(outContent "/* ${outFilename}.  Generated from ${inFilename} by configure.cmake. */\n")
  # handle relative paths by prepending with ${CMAKE_CURRENT_SOURCE_DIR} if needed
  if(NOT IS_ABSOLUTE "${in}")
    set(in "${CMAKE_CURRENT_SOURCE_DIR}/${in}")
  endif()
  # handle relative paths by prepending with ${CMAKE_CURRENT_BINARY_DIR} if needed
  if(NOT IS_ABSOLUTE "${out}")
    set(out "${CMAKE_CURRENT_BINARY_DIR}/${out}")
  endif()
  # read the input file
  file(READ "${in}" inContent)
  # replace any semicolons with a unique placeholder
  string(REPLACE ";" "$<SEMICOLON>" inContent "${inContent}")
  # split the content into lines
  string(REPLACE "\n" ";" lines "${inContent}")
  # initialize variables
  set(prevUndef "")
  # process each line
  foreach(line IN LISTS lines)
    if(prevUndef)
      # extract both the indentation after # and the symbol name
      string(REGEX REPLACE "^#([ \t]*)undef[ \t]+([A-Za-z_][A-Za-z0-9_]*).*$" "\\1;\\2" result "${prevUndef}")
      list(GET result 0 indent)
      list(GET result 1 symbol)
      if(DEFINED DEFINE_${symbol}) # check if there is a matching DEFINE_ variable
        # replace the #undef with #@DEFINE_*@, where * is the symbol name
        set(outContent "${outContent}#${indent}${DEFINE_${symbol}} ${symbol}\n")
      # see cmakedefine vs cmakedefine01
      # https://cmake.org/cmake/help/latest/command/configure_file.html#transformations
      elseif(DEFINED ${symbol} AND ("${${symbol}}" STREQUAL "1" OR "${${symbol}}" STREQUAL "TRUE"))
        set(outContent "${outContent}#${indent}cmakedefine01 ${symbol}\n")
      elseif(DEFINED ${symbol} AND ("${${symbol}}" STREQUAL "0" OR "${${symbol}}" STREQUAL "FALSE"))
        set(outContent "${outContent}#${indent}cmakedefine ${symbol}\n")
      elseif(DEFINED ${symbol})
        set(outContent "${outContent}#${indent}cmakedefine ${symbol} ${${symbol}}\n")
      else()
        # if we get here, either no match or invalid symbol after #undef
        set(outContent "${outContent}${prevUndef}\n")
      endif()
      set(prevUndef "")
    endif()
    # check if this line begins with a # and is followed by undef and a symbol name
    if(line MATCHES "^#[ \t]*undef[ \t]+([A-Za-z_][A-Za-z0-9_]*)")
      set(prevUndef "${line}")
    else()
      set(prevUndef "")
      string(REPLACE "$<SEMICOLON>" ";" line "${line}")
      set(outContent "${outContent}${line}\n")
    endif()
  endforeach()
  string(REGEX REPLACE "[\r\n]$" "" outContent "${outContent}") # remove final newline
  cmake_path(GET in STEM inStem)
  set(cmakeDotin "${CMAKE_CURRENT_BINARY_DIR}/${inStem}.cmake.in")
  file(WRITE "${cmakeDotin}" "${outContent}")
  configure_file("${cmakeDotin}" "${out}")
endfunction(xpcfgDotinFile)
