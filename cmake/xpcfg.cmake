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

macro(xpcfgTargetCpu var)
  ####################
  # exporting the TARGET_CPU string
  execute_process(COMMAND ${CMAKE_C_COMPILER} -dumpmachine
    OUTPUT_VARIABLE ${var}
    OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET
    )
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

# called from: apr/configure.cmake
macro(xpcfgSockCloexec var)
  # Define if the SOCK_CLOEXEC flag is supported
  check_c_source_compiles("
${XP_INCLUDES}
int main(void)
{
  return socket(AF_INET, SOCK_STREAM|SOCK_CLOEXEC, 0) == -1;
}
"   ${var}
    )
endmacro()

# called from: apr/configure.cmake
macro(xpcfgTcpNodelayWithCork var)
  # Define if TCP_NODELAY and TCP_CORK can be enabled at the same time
  check_c_source_compiles("
${XP_INCLUDES}
int main(void)
{
  int fd, flag, rc;
  fd = socket(AF_INET, SOCK_STREAM, 0);
  if (fd < 0) {
    exit(1);
  }
  flag = 1;
  rc = setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, &flag, sizeof flag);
  if (rc < 0) {
    perror(\"setsockopt TCP_NODELAY\");
    exit(2);
  }
  flag = 1;
  rc = setsockopt(fd, IPPROTO_TCP, TCP_CORK, &flag, sizeof flag);
  if (rc < 0) {
    perror(\"setsockopt TCP_CORK\");
    exit(3);
  }
  exit(0);
}
"   ${var}
    )
endmacro()

# called from: apr/configure.cmake
macro(xpcfgONonblockInherited var)
  # Is the O_NONBLOCK flag inherited from listening sockets?
  # Platform-specific overrides
  if(CMAKE_SYSTEM_NAME MATCHES "OpenBSD" OR CMAKE_SYSTEM_NAME MATCHES "NetBSD")
    set(${var} "1" CACHE INTERNAL "O_NONBLOCK inheritance")
    return()
  endif()
  # Complete test program to check O_NONBLOCK inheritance
  set(TEST_SOURCE "
${XP_INCLUDES}
int main(void) {
  int listen_s, connected_s, client_s;
  int listen_port, rc, flags;
  struct sockaddr_in sa;
  socklen_t sa_len;
  fd_set fds;
  struct timeval tv;
  /* Create listening socket */
  listen_s = socket(AF_INET, SOCK_STREAM, 0);
  if (listen_s < 0) {
    perror(\"socket\");
    return 1;
  }
  /* Bind to an ephemeral port */
  memset(&sa, 0, sizeof(sa));
  sa.sin_family = AF_INET;
  sa.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
  if (bind(listen_s, (struct sockaddr *)&sa, sizeof(sa)) < 0) {
    perror(\"bind\");
    close(listen_s);
    return 1;
  }
  /* Get the port number */
  sa_len = sizeof(sa);
  if (getsockname(listen_s, (struct sockaddr *)&sa, &sa_len) < 0) {
    perror(\"getsockname\");
    close(listen_s);
    return 1;
  }
  listen_port = ntohs(sa.sin_port);
  /* Set up listening socket */
  if (listen(listen_s, 5) < 0) {
    perror(\"listen\");
    close(listen_s);
    return 1;
  }
  /* Set O_NONBLOCK on listening socket */
  if (fcntl(listen_s, F_SETFL, O_NONBLOCK) < 0) {
    perror(\"fcntl(F_SETFL)\");
    close(listen_s);
    return 1;
  }
  /* Create client socket */
  client_s = socket(AF_INET, SOCK_STREAM, 0);
  if (client_s < 0) {
    perror(\"socket (client)\");
    close(listen_s);
    return 1;
  }
  /* Connect to server */
  memset(&sa, 0, sizeof(sa));
  sa.sin_family = AF_INET;
  sa.sin_port = htons(listen_port);
  sa.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
  if (connect(client_s, (struct sockaddr *)&sa, sizeof(sa)) < 0) {
    perror(\"connect\");
    close(listen_s);
    close(client_s);
    return 1;
  }
  /* Accept the connection */
  sa_len = sizeof(sa);
  connected_s = accept(listen_s, (struct sockaddr *)&sa, &sa_len);
  if (connected_s < 0) {
    perror(\"accept\");
    close(listen_s);
    close(client_s);
    return 1;
  }
  /* Check if O_NONBLOCK is set on the accepted socket */
  flags = fcntl(connected_s, F_GETFL, 0);
  if (flags == -1) {
    perror(\"fcntl(F_GETFL)\");
    close(listen_s);
    close(client_s);
    close(connected_s);
    return 1;
  }
  /* Clean up */
  close(connected_s);
  close(client_s);
  close(listen_s);
  /* Return 0 if O_NONBLOCK is set, 1 otherwise */
  return (flags & O_NONBLOCK) ? 0 : 1;
}
")
  check_c_source_runs("${TEST_SOURCE}" ${var})
  # If test didn't run (cross-compiling), default to "yes"
  if(NOT DEFINED ${var})
    set(${var} "1" CACHE INTERNAL "O_NONBLOCK inheritance (default)")
  endif()
endmacro(xpcfgONonblockInherited)

# Process 64-bit integer literals
# called from: apr/configure.cmake
function(xpcfgInt64Literal int64_literal_var uint64_literal_var)
  cmake_push_check_state(RESET)
  include(CheckTypeSize)
  check_type_size("long long" SIZEOF_LONG_LONG)
  check_type_size("__int64" SIZEOF___INT64)
  check_type_size("int64_t" SIZEOF_INT64_T)
  check_type_size("int" SIZEOF_INT)
  check_type_size("long" SIZEOF_LONG)
  # Determine 64-bit integer type and set appropriate literals
  if(HAVE_SIZEOF_INT64_T)
    # Prefer using the standard INT64_C/UINT64_C macros with parentheses
    set(INT64_C "INT64_C(val)")
    set(UINT64_C "UINT64_C(val)")
  elseif(HAVE_SIZEOF_LONG_LONG AND SIZEOF_LONG_LONG EQUAL 8)
    # Fall back to long long if int64_t is not available
    set(INT64_C "val##LL")
    set(UINT64_C "val##ULL")
  elseif(HAVE_SIZEOF___INT64 AND SIZEOF___INT64 EQUAL 8)
    # Windows-specific 64-bit type
    set(INT64_C "val##i64")
    set(UINT64_C "val##ui64")
  elseif(HAVE_SIZEOF_LONG AND SIZEOF_LONG EQUAL 8)
    # Some systems have 64-bit long
    set(INT64_C "val##L")
    set(UINT64_C "val##UL")
  else()
    message(FATAL_ERROR "No 64-bit integer type found")
  endif()
  # Process the format strings
  string(CONFIGURE "${${int64_literal_var}}" formatted_int64_literal @ONLY)
  string(CONFIGURE "${${uint64_literal_var}}" formatted_uint64_literal @ONLY)
  # Set the results in the parent scope
  set(${int64_literal_var} "${formatted_int64_literal}" PARENT_SCOPE)
  set(${uint64_literal_var} "${formatted_uint64_literal}" PARENT_SCOPE)
  cmake_pop_check_state()
endfunction(xpcfgInt64Literal)

# Process 64-bit integer format specifiers
# called from: apr/configure.cmake
function(xpcfgInt64Format int64_t_fmt_var uint64_t_fmt_var uint64_t_hex_fmt_var long_value_var)
  cmake_push_check_state(RESET)
  include(CheckTypeSize)
  check_type_size("long long" SIZEOF_LONG_LONG)
  check_type_size("__int64" SIZEOF___INT64)
  check_type_size("int64_t" SIZEOF_INT64_T)
  check_type_size("int" SIZEOF_INT)
  check_type_size("long" SIZEOF_LONG)
  # Determine 64-bit integer type and set appropriate format specifiers
  if(HAVE_SIZEOF_INT64_T AND SIZEOF_INT64_T EQUAL 8)
    # Prefer using the standard int64_t with PRId64/PRIu64/PRIx64 macros
    set(INT64_T_FMT "PRId64")
    set(UINT64_T_FMT "PRIu64")
    set(UINT64_T_HEX_FMT "PRIx64")
    set(LONG_VALUE 0)
  elseif(HAVE_SIZEOF_LONG_LONG AND SIZEOF_LONG_LONG EQUAL 8)
    # Fall back to long long with ll length modifier
    set(INT64_T_FMT "\"lld\"")
    set(UINT64_T_FMT "\"llu\"")
    set(UINT64_T_HEX_FMT "\"llx\"")
    set(LONG_VALUE 0)
  elseif(HAVE_SIZEOF___INT64 AND SIZEOF___INT64 EQUAL 8)
    # Windows-specific 64-bit type with I64 prefix
    set(INT64_T_FMT "\"I64d\"")
    set(UINT64_T_FMT "\"I64u\"")
    set(UINT64_T_HEX_FMT "\"I64x\"")
    set(LONG_VALUE 0)
  elseif(HAVE_SIZEOF_LONG AND SIZEOF_LONG EQUAL 8)
    # Some systems have 64-bit long
    set(INT64_T_FMT "\"ld\"")
    set(UINT64_T_FMT "\"lu\"")
    set(UINT64_T_HEX_FMT "\"lx\"")
    set(LONG_VALUE 1)
  else()
    message(FATAL_ERROR "No 64-bit integer type found")
  endif()
  # Process the format strings
  string(CONFIGURE "${${int64_t_fmt_var}}" formatted_int64_t_fmt @ONLY)
  string(CONFIGURE "${${uint64_t_fmt_var}}" formatted_uint64_t_fmt @ONLY)
  string(CONFIGURE "${${uint64_t_hex_fmt_var}}" formatted_uint64_t_hex_fmt @ONLY)
  string(CONFIGURE "${${long_value_var}}" formatted_long_value @ONLY)
  # Set the results in the parent scope
  set(${int64_t_fmt_var} "${formatted_int64_t_fmt}" PARENT_SCOPE)
  set(${uint64_t_fmt_var} "${formatted_uint64_t_fmt}" PARENT_SCOPE)
  set(${uint64_t_hex_fmt_var} "${formatted_uint64_t_hex_fmt}" PARENT_SCOPE)
  set(${long_value_var} "${formatted_long_value}" PARENT_SCOPE)
  cmake_pop_check_state()
endfunction(xpcfgInt64Format)

# Determine the appropriate string conversion functions for 64-bit integers and off_t
# called from: apr/configure.cmake
function(xpcfgStrfn int64_strfn_var off_t_strfn_var)
  cmake_push_check_state(RESET)
  include(CheckTypeSize)
  # First check the size of various types to match the configure script's logic
  check_type_size("long" SIZEOF_LONG)
  check_type_size("long long" SIZEOF_LONG_LONG)
  # Determine the 64-bit string conversion function based on type sizes and platform
  if(APPLE)
    # On macOS/Darwin, always use strtoll regardless of type sizes
    set(int64_strfn "strtoll")
  elseif(SIZEOF_LONG EQUAL 8)
    # If long is 8 bytes, use strtol
    set(int64_strfn "strtol")
  elseif(SIZEOF_LONG_LONG EQUAL 8)
    # If long long is 8 bytes, use strtoll
    set(int64_strfn "strtoll")
  else()
    # Fallback: check for available functions in order of preference
    check_c_source_compiles("
#include <inttypes.h>
#include <stdlib.h>
int main() { strtoimax(\"0\", NULL, 10); return 0; }
"     HAVE_STRTOIMAX
      )
    check_c_source_compiles("
#include <stdlib.h>
int main() { strtoll(\"0\", NULL, 10); return 0; }
"     HAVE_STRTOLL
      )
    check_c_source_compiles("
#include <stdlib.h>
int main() { strtoq(\"0\", NULL, 10); return 0; }
"     HAVE_STRTOQ
      )
    if(HAVE_STRTOIMAX)
      set(int64_strfn "strtoimax")
    elseif(HAVE_STRTOLL)
      set(int64_strfn "strtoll")
    elseif(HAVE_STRTOQ)
      set(int64_strfn "strtoq")
    else()
      # Final fallback
      set(int64_strfn "strtol")
    endif()
  endif()
  # For off_t, use strtoll on macOS, otherwise follow the same logic as int64_strfn
  check_type_size("off_t" SIZEOF_OFF_T)
  if(APPLE)
    # On macOS, always use strtoll for off_t to match configure script
    set(off_t_strfn "strtoll")
  elseif(SIZEOF_OFF_T EQUAL SIZEOF_LONG)
    # If off_t is same size as long, use strtol
    set(off_t_strfn "strtol")
  else()
    # Otherwise use the same function as for int64_t
    set(off_t_strfn "${int64_strfn}")
  endif()
  # Set the output variables
  set(${int64_strfn_var} "${int64_strfn}" PARENT_SCOPE)
  set(${off_t_strfn_var} "${off_t_strfn}" PARENT_SCOPE)
  cmake_pop_check_state()
endfunction(xpcfgStrfn)

# check and set format specifiers for size_t and ssize_t
# called from: apr/configure.cmake
function(xpcfgSizeTypeFormat ssize_t_fmt_var size_t_fmt_var)
  cmake_push_check_state(RESET)
  # Default format specifiers for size_t and ssize_t
  set(SSIZE_T_FMT "\"ld\"")
  set(SIZE_T_FMT "\"lu\"")
  # Process the format specifiers
  string(CONFIGURE "${${ssize_t_fmt_var}}" formatted_ssize_t_fmt @ONLY)
  string(CONFIGURE "${${size_t_fmt_var}}" formatted_size_t_fmt @ONLY)
  # Set the results in the parent scope
  set(${ssize_t_fmt_var} "${formatted_ssize_t_fmt}" PARENT_SCOPE)
  set(${size_t_fmt_var} "${formatted_size_t_fmt}" PARENT_SCOPE)
  cmake_pop_check_state()
endfunction()

# check and set format specifiers for off_t
# called from: apr/configure.cmake
function(xpcfgOffFormat off_t_fmt_var)
  cmake_parse_arguments(ARG "" "INT64_T_FMT" "" ${ARGN})
  if(NOT DEFINED ARG_INT64_T_FMT)
    set(ARG_INT64_T_FMT "INT64_T_FMT")
  endif()
  cmake_push_check_state(RESET)
  # Check off_t format specifier
  check_type_size("off_t" SIZEOF_OFF_T)
  if(HAVE_SIZEOF_OFF_T)
    if(APPLE AND SIZEOF_OFF_T EQUAL 8)
      # On macOS, use "lld" for 64-bit off_t
      set(_off_t_fmt "lld")
    elseif(SIZEOF_OFF_T EQUAL SIZEOF_LONG)
      set(_off_t_fmt "ld")
    elseif(SIZEOF_OFF_T EQUAL SIZEOF_INT)
      set(_off_t_fmt "d")
    elseif(SIZEOF_OFF_T EQUAL SIZEOF_LONG_LONG)
      set(_off_t_fmt "${ARG_INT64_T_FMT}")
    else()
      message(FATAL_ERROR "could not determine the size of off_t")
    endif()
  else()
    message(FATAL_ERROR "could not determine off_t size")
  endif()
  # Process off_t format specifier
  if(DEFINED _off_t_fmt)
    if(_off_t_fmt STREQUAL ARG_INT64_T_FMT)
      set(OFF_T_FMT "${_off_t_fmt}")
    else()
      set(OFF_T_FMT "\"${_off_t_fmt}\"")
    endif()
    string(CONFIGURE "${${off_t_fmt_var}}" formatted_off_t_fmt @ONLY)
    set(${off_t_fmt_var} "${formatted_off_t_fmt}" PARENT_SCOPE)
  endif()
  cmake_pop_check_state()
endfunction(xpcfgOffFormat)

# check and set format specifiers for pid_t
# called from: apr/configure.cmake
function(xpcfgPidFormat pid_t_fmt_var)
  cmake_parse_arguments(ARG "" "INT64_T_FMT" "" ${ARGN})
  if(NOT DEFINED ARG_INT64_T_FMT)
    set(ARG_INT64_T_FMT "INT64_T_FMT")
  endif()
  cmake_push_check_state(RESET)
  # Check pid_t format specifier
  check_type_size("pid_t" SIZEOF_PID_T)
  if(HAVE_SIZEOF_PID_T)
    if(SIZEOF_PID_T EQUAL SIZEOF_SHORT)
      set(_pid_t_fmt "hd")
    elseif(SIZEOF_PID_T EQUAL SIZEOF_INT)
      set(_pid_t_fmt "d")
    elseif(SIZEOF_PID_T EQUAL SIZEOF_LONG)
      set(_pid_t_fmt "ld")
    elseif(SIZEOF_PID_T EQUAL SIZEOF_LONG_LONG)
      set(_pid_t_fmt "${ARG_INT64_T_FMT}")
    else()
      message(FATAL_ERROR "could not determine the size of pid_t")
    endif()
  else()
    message(FATAL_ERROR "could not determine pid_t size")
  endif()
  # Process pid_t format specifier
  if(DEFINED _pid_t_fmt)
    if(_pid_t_fmt STREQUAL ARG_INT64_T_FMT)
      set(PID_T_FMT "${_pid_t_fmt}")
    else()
      set(PID_T_FMT "\"${_pid_t_fmt}\"")
    endif()
    string(CONFIGURE "${${pid_t_fmt_var}}" formatted_pid_t_fmt @ONLY)
    set(${pid_t_fmt_var} "${formatted_pid_t_fmt}" PARENT_SCOPE)
  endif()
  cmake_pop_check_state()
endfunction(xpcfgPidFormat)

# Check for TCP_NOPUSH or TCP_CORK socket option
# called from: apr/configure.cmake
function(xpcfgDetermineTcpNopushFlag out_var)
  cmake_push_check_state(RESET)
  # Check for TCP_NOPUSH first
  check_c_source_compiles("
${XP_INCLUDES}
int main(void) {
  int opt = TCP_NOPUSH;
  return 0;
}
"   HAVE_TCP_NOPUSH
    )
  if(HAVE_TCP_NOPUSH)
    set(result "TCP_NOPUSH")
  else()
    # Fall back to TCP_CORK if available
    check_c_source_compiles("
${XP_INCLUDES}
int main(void) {
  int opt = TCP_CORK;
  return 0;
}
"   HAVE_TCP_CORK
    )
    if(HAVE_TCP_CORK)
      set(result "TCP_CORK")
    else()
      # Fallback to TCP_CORK as default
      set(result "TCP_CORK")
      message(STATUS "Could not determine TCP_NOPUSH or TCP_CORK, defaulting to TCP_CORK")
    endif()
  endif()
  set(${out_var} ${result} PARENT_SCOPE)
  cmake_pop_check_state()
endfunction(xpcfgDetermineTcpNopushFlag)

# Check if getaddrinfo returns negative error codes
# called from: apr/configure.cmake
function(xpcfgNegativeEai var)
  cmake_push_check_state()
  set(CMAKE_REQUIRED_INCLUDES "${CMAKE_REQUIRED_INCLUDES}")
  set(CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS}")
  # First check if we can compile with the EAI_* macros
  check_c_source_compiles("
#include <netdb.h>
int main(void) {
#if defined(EAI_ADDRFAMILY) || defined(EAI_AGAIN) || defined(EAI_BADFLAGS) || \
    defined(EAI_FAIL) || defined(EAI_FAMILY) || defined(EAI_MEMORY) || \
    defined(EAI_NODATA) || defined(EAI_NONAME) || defined(EAI_SERVICE) || \
    defined(EAI_SOCKTYPE) || defined(EAI_SYSTEM)
  return 0;
#else
  #error EAI_* macros not defined
#endif
}" HAVE_EAI_MACROS)
  if(HAVE_EAI_MACROS)
    # Only check for negative values if EAI_* macros are defined
    check_c_source_runs("
#include <netdb.h>
#include <stdio.h>
int main(void) {
  int negative_found = 0;
#if defined(EAI_ADDRFAMILY) && (EAI_ADDRFAMILY < 0)
  negative_found = 1;
#endif
#if defined(EAI_AGAIN) && (EAI_AGAIN < 0)
  negative_found = 1;
#endif
#if defined(EAI_BADFLAGS) && (EAI_BADFLAGS < 0)
  negative_found = 1;
#endif
#if defined(EAI_FAIL) && (EAI_FAIL < 0)
  negative_found = 1;
#endif
#if defined(EAI_FAMILY) && (EAI_FAMILY < 0)
  negative_found = 1;
#endif
#if defined(EAI_MEMORY) && (EAI_MEMORY < 0)
  negative_found = 1;
#endif
#if defined(EAI_NODATA) && (EAI_NODATA < 0)
  negative_found = 1;
#endif
#if defined(EAI_NONAME) && (EAI_NONAME < 0)
  negative_found = 1;
#endif
#if defined(EAI_SERVICE) && (EAI_SERVICE < 0)
  negative_found = 1;
#endif
#if defined(EAI_SOCKTYPE) && (EAI_SOCKTYPE < 0)
  negative_found = 1;
#endif
#if defined(EAI_SYSTEM) && (EAI_SYSTEM < 0)
  negative_found = 1;
#endif
  return negative_found ? 0 : 1;
}
"     ${var}
      )
  else()
    set(${var} 0)
  endif()
  if(${var})
    message(STATUS "Negative EAI error codes found")
  else()
    message(STATUS "No negative EAI error codes found")
  endif()
  cmake_pop_check_state()
  set(${var} ${${var}} PARENT_SCOPE)
endfunction(xpcfgNegativeEai)

# Check if SYS_getrandom is declared in sys/syscall.h
# called from: apr/configure.cmake
macro(xpcfgDeclSysGetrandom var)
  cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_INCLUDES "${CMAKE_REQUIRED_INCLUDES}")
  set(CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS}")
  check_c_source_compiles("
#include <sys/syscall.h>
#ifdef SYS_getrandom
int main() { return 0; }
#else
#error SYS_getrandom not defined
#endif
"
    ${var}
    )
  cmake_pop_check_state()
endmacro()

# Check for epoll support and reliable timeout
# Parameters:
#   epoll_var - output variable that will be set to 1 if epoll is supported, 0 otherwise
#   reliable_timeout_var - output variable that will be set to 1 if epoll_wait has reliable timeout, 0 otherwise
# called from: apr/configure.cmake
function(xpcfgCheckEpoll epoll_var reliable_timeout_var)
  cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_INCLUDES "${CMAKE_REQUIRED_INCLUDES}")
  set(CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS}")
  # First check for basic epoll support
  check_c_source_compiles("
#include <sys/epoll.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
int main() {
    int epfd = epoll_create(1);
    if (epfd == -1) return 1;
    close(epfd);
    return 0;
}
"   HAVE_EPOLL
    )
  # Check for epoll_create1
  check_c_source_compiles("
#include <sys/epoll.h>
#include <unistd.h>
int main() {
    int epfd = epoll_create1(0);
    if (epfd == -1) return 1;
    close(epfd);
    return 0;
}
"   HAVE_EPOLL_CREATE1
    )
  # Check for reliable timeout in epoll_wait
  if(HAVE_EPOLL)
    check_c_source_compiles("
#include <sys/epoll.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/time.h>
int main() {
  struct epoll_event events[1];
  int fd, i;
  struct timeval start, end;
  long elapsed;
#ifdef HAVE_EPOLL_CREATE1
  fd = epoll_create1(0);
#else
  fd = epoll_create(1);
#endif
  if (fd == -1) return 1;
  gettimeofday(&start, NULL);
  i = epoll_wait(fd, events, 1, 100);
  gettimeofday(&end, NULL);
  elapsed = (end.tv_sec - start.tv_sec) * 1000000 + (end.tv_usec - start.tv_usec);
  close(fd);
  /* Should have timed out after ~100ms */
  return (i == 0 && elapsed >= 50000) ? 0 : 1;
}
"     HAVE_EPOLL_WAIT_RELIABLE_TIMEOUT
      )
  else()
    set(HAVE_EPOLL_WAIT_RELIABLE_TIMEOUT 0)
  endif()
  # Set the results in the parent scope
  set(${epoll_var} ${HAVE_EPOLL} PARENT_SCOPE)
  set(${reliable_timeout_var} ${HAVE_EPOLL_WAIT_RELIABLE_TIMEOUT} PARENT_SCOPE)
  cmake_pop_check_state()
endfunction(xpcfgCheckEpoll)

# Check for sys_siglist declaration
# Parameters:
#   var - output variable that will be set to 1 if sys_siglist is declared, 0 otherwise
# called from: apr/configure.cmake
macro(xpcfgCheckSysSiglist var)
  cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_INCLUDES "${CMAKE_REQUIRED_INCLUDES}")
  set(CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS}")
  # Try const version first (modern systems)
  check_c_source_compiles("
#include <signal.h>
#include <stdio.h>
int main() {
  extern const char *const sys_siglist[];
  (void)sys_siglist;
  return 0;
}
"   ${var}
    )
  # If that fails, try non-const version (older systems)
  if(NOT ${var})
    check_c_source_compiles("
#include <signal.h>
#include <stdio.h>
int main() {
  extern char *sys_siglist[];
  (void)sys_siglist;
  return 0;
}
"     ${var}
      )
  endif()
  cmake_pop_check_state()
endmacro(xpcfgCheckSysSiglist)

# Check for get name style of network functions
# Parameters:
#   hostbyname_r_glibc2_var - variable that will be set to 1 if gethostbyname_r is glibc2 style, 0 otherwise
#   hostbyname_r_data_var - variable that will be set to 1 if gethostbyname_r uses hostent_data, 0 otherwise
#   servbyname_r_glibc2_var - variable that will be set to 1 if getservbyname_r is glibc2 style, 0 otherwise
#   servbyname_r_osf1_var - variable that will be set to 1 if getservbyname_r is OSF1 style, 0 otherwise
#   servbyname_r_solaris_var - variable that will be set to 1 if getservbyname_r is Solaris style, 0 otherwise
# called from: apr/configure.cmake
macro(xpcfgCheckGetNameStyle
  hostbyname_r_glibc2_var
  hostbyname_r_data_var
  servbyname_r_glibc2_var
  servbyname_r_osf1_var
  servbyname_r_solaris_var
)
  cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_INCLUDES "${CMAKE_REQUIRED_INCLUDES}")
  set(CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS}")
  set(CMAKE_REQUIRED_LIBRARIES "${CMAKE_REQUIRED_LIBRARIES}")
  # Check for gethostbyname_r variants
  check_c_source_compiles("
#include <netdb.h>
#include <netinet/in.h>
int main() {
  char *name = \"localhost\";
  struct hostent he, *result;
  char buffer[8192];
  int h_errnop;
  /* Check for glibc2 style */
  if (gethostbyname_r(name, &he, buffer, sizeof(buffer), &result, &h_errnop) == 0) {
    return 0;
  }
  return 1;
}
"   ${hostbyname_r_glibc2_var}
    )
  # Check for gethostbyname_r with hostent_data (Solaris style)
  check_c_source_compiles("
#include <netdb.h>
#include <netinet/in.h>
int main() {
  char *name = \"localhost\";
  struct hostent he;
  struct hostent_data data;
  /* Check for Solaris style with hostent_data */
  if (gethostbyname_r(name, &he, &data) == 0) {
    return 0;
  }
  return 1;
}
"   ${hostbyname_r_data_var}
    )
  # Check for getservbyname_r variants
  check_c_source_compiles("
#include <netdb.h>
int main() {
  struct servent se, *result;
  char buffer[8192];
  /* Check for glibc2 style */
  if (getservbyname_r(\"http\", \"tcp\", &se, buffer, sizeof(buffer), &result) == 0) {
    return 0;
  }
  return 1;
}
"   ${servbyname_r_glibc2_var}
    )
  # Check for OSF1 style getservbyname_r
  check_c_source_compiles("
#include <netdb.h>
int main() {
  struct servent_data data;
  /* Check for OSF1 style */
  if (getservbyname_r(\"http\", \"tcp\", NULL, &data) == 0) {
    return 0;
  }
  return 1;
}
"   ${servbyname_r_osf1_var}
    )
  # Check for Solaris style getservbyname_r
  check_c_source_compiles("
#include <netdb.h>
int main() {
    struct servent se;
    char buffer[8192];
    /* Check for Solaris style */
    if (getservbyname_r(\"http\", \"tcp\", &se, buffer, sizeof(buffer)) != NULL) {
        return 0;
    }
    return 1;
}
"   ${servbyname_r_solaris_var}
    )
  cmake_pop_check_state()
endmacro(xpcfgCheckGetNameStyle)

# Check for SEM_UNDO constant in sys/sem.h
# Parameters:
#   var - variable that will be set to 1 if SEM_UNDO is defined, 0 otherwise
# called from: apr/configure.cmake
macro(xpcfgCheckSysVSemaphores var)
  cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_INCLUDES "${CMAKE_REQUIRED_INCLUDES}")
  set(CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS}")
  # Check that SEM_UNDO constant compiles
  check_c_source_compiles("
#include <sys/sem.h>
int main(void) {
  int x = SEM_UNDO;
  return 0;
}
"   ${var}
    )
  cmake_pop_check_state()
endmacro()

# Check for pthread features
# Parameters:
#   recursive_var - variable that will be set if PTHREAD_MUTEX_RECURSIVE is supported
#   robust_var - variable that will be set if PTHREAD_MUTEX_ROBUST is supported
#   robust_np_var - variable that will be set if PTHREAD_MUTEX_ROBUST_NP is supported
#   rwlocks_var - variable that will be set if pthread rwlocks are supported
# called from: apr/configure.cmake
macro(xpcfgCheckPthreadFeatures recursive_var robust_var robust_np_var rwlocks_var)
  cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_INCLUDES "${CMAKE_REQUIRED_INCLUDES}")
  set(CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS}")
  set(CMAKE_REQUIRED_LIBRARIES "${CMAKE_REQUIRED_LIBRARIES} pthread")
  # Check for PTHREAD_MUTEX_RECURSIVE
  check_c_source_compiles("
#include <pthread.h>
int main() {
  pthread_mutexattr_t attr;
  pthread_mutex_t m;
  return pthread_mutexattr_init(&attr) ||
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE) ||
    pthread_mutex_init(&m, &attr);
}
"   ${recursive_var}
    )
  # Check for PTHREAD_MUTEX_ROBUST
  check_c_source_compiles("
#include <pthread.h>
int main() {
  pthread_mutexattr_t attr;
  pthread_mutex_t m;
  return pthread_mutexattr_init(&attr) ||
    pthread_mutexattr_setrobust(&attr, PTHREAD_MUTEX_ROBUST) ||
    pthread_mutex_init(&m, &attr);
}
"   ${robust_var}
    )
  # Check for PTHREAD_MUTEX_ROBUST_NP
  check_c_source_compiles("
#include <pthread.h>
#include <errno.h>
int main() {
  pthread_mutexattr_t attr;
  pthread_mutex_t m;
  int rc;
#if !defined(PTHREAD_MUTEX_ROBUST_NP) && !defined(PTHREAD_MUTEX_STALLED)
#error PTHREAD_MUTEX_ROBUST_NP not defined
#endif
  if (pthread_mutexattr_init(&attr) != 0)
    return 1;
  rc = pthread_mutexattr_setrobust_np(&attr, PTHREAD_MUTEX_ROBUST_NP);
  if (rc != 0 && rc != ENOTSUP) {
    pthread_mutexattr_destroy(&attr);
    return 1;
  }
  rc = pthread_mutex_init(&m, &attr);
  pthread_mutexattr_destroy(&attr);
  if (rc != 0)
    return 1;
  pthread_mutex_destroy(&m);
  return 0;
}
"   ${robust_np_var}
    )
  # Check for pthread rwlocks
  check_c_source_compiles("
#include <pthread.h>
int main() {
  pthread_rwlock_t lock;
  return pthread_rwlock_init(&lock, NULL) ||
    pthread_rwlock_rdlock(&lock) ||
    pthread_rwlock_unlock(&lock) ||
    pthread_rwlock_wrlock(&lock) ||
    pthread_rwlock_unlock(&lock) ||
    pthread_rwlock_destroy(&lock);
}
"   ${rwlocks_var}
    )
  cmake_pop_check_state()
endmacro(xpcfgCheckPthreadFeatures)

# Check if strerror_r returns an int (POSIX) or char* (GNU)
# This determines if we should check the return value or the buffer for the error message
# Sets ${var} to 1 if strerror_r returns int, 0 otherwise
# called from: apr/configure.cmake
macro(xpcfgStrerrorRReturnType var)
  cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS "-D_GNU_SOURCE")
  # First check if strerror_r is available
  check_c_source_compiles(
"#include <errno.h>
#include <string.h>
int main(void) {
  char buf[1024];
  strerror_r(ERANGE, buf, sizeof buf);
  return 0;
}
"   HAVE_STRERROR_R_IN_MACRO
    )
  if(HAVE_STRERROR_R_IN_MACRO)
    # Then check if it returns int (POSIX) or char* (GNU)
    check_c_source_runs(
"#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
int main(void) {
  char buf[1024];
  if (strerror_r(ERANGE, buf, sizeof buf) < 1) {
    return 0;
  } else {
    return 1;
  }
}
"     ${var}
      )
  else()
    set(${var} 0)
  endif()
  message(STATUS "strerror_r returns int: ${${var}}") # TODO remove
  cmake_pop_check_state()
endmacro(xpcfgStrerrorRReturnType)

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
      if(NOT "${line}" IN_LIST undefs)
        set(prevUndef "${line}")
        list(APPEND undefs "${line}")
      else()
        # TRICKY: if this #undef has been seen before, it is probably meant to be an #undef
        set(outContent "${outContent}${line}\n")
      endif()
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
