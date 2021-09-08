#
# Copyright © 2021 Barry Schwartz
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License, as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received copies of the GNU General Public License
# along with this program. If not, see
# <https://www.gnu.org/licenses/>.
#

#--------------------------------------------------------------------------

AC_PREREQ([2.71])
AC_INIT([ats2-hashmap],[1.0.0],[],[ats2-hashmap],[])

AC_CONFIG_SRCDIR([hashmap/SATS/hashmap.sats])

AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_AUX_DIR([build-aux])
AC_CANONICAL_BUILD                 dnl On what platform are we compiling?
AC_CANONICAL_HOST                  dnl For what platform are we compiling?
AC_USE_SYSTEM_EXTENSIONS           dnl Define such macros as _GNU_SOURCE.

AM_INIT_AUTOMAKE
AM_SILENT_RULES
AM_MAINTAINER_MODE
LT_INIT

AC_ARG_VAR([PATSHOME],[the home of the ATS2 compiler])

AC_ARG_VAR([PKGCONFIG_PATSHOME],
  [The PATSHOME setting to put in the pkg-config file [default="${PATSHOME}"]])
if test -z "${PKGCONFIG_PATSHOME}"; then
  PKGCONFIG_PATSHOME="${PATSHOME}"
fi
if test -z "${PKGCONFIG_PATSHOME}"; then
  AC_MSG_ERROR([Please set PKGCONFIG_PATSHOME on the configure command line.])
fi

AM_CONDITIONAL([DEPENDENCY_TRACKING],
  [test x"${enable_dependency_tracking}" != xno])

#--------------------------------------------------------------------------
#
# Checks for programs.

AC_PROG_CC
AC_PROG_CC_C_O
AC_CHECK_PROGS([M4],[m4])
AC_CHECK_PROGS([PATSOPT],[patsopt])
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_MKDIR_P
AC_PROG_AWK
AC_PROG_SED
AC_PROG_FGREP
AC_PROG_EGREP

# Enable optional code coverage analysis.
AX_CODE_COVERAGE

AM_CONDITIONAL([DEPENDENCY_TRACKING],
  [test x"${enable_dependency_tracking}" != xno])

#--------------------------------------------------------------------------
#
# Checks for libraries.

#--------------------------------------------------------------------------
#
# Checks for header files.

#--------------------------------------------------------------------------
#
# Checks for typedefs, structures, and compiler characteristics.

AC_CHECK_SIZEOF([unsigned short int])
AC_CHECK_SIZEOF([unsigned int])
AC_CHECK_SIZEOF([unsigned long int])
AC_CHECK_SIZEOF([unsigned long long int])
AC_CHECK_SIZEOF([size_t])
AC_CHECK_SIZEOF([uintptr_t])
AC_CHECK_SIZEOF([uint8_t])
AC_CHECK_SIZEOF([uint16_t])
AC_CHECK_SIZEOF([uint32_t])
AC_CHECK_SIZEOF([uint64_t])

AC_CHECK_TYPE([unsigned __int128])
if test x"${ac_cv_type_unsigned___int128}" = xyes ; then
  HAVE_UINT128=1
else
  HAVE_UINT128=0
fi
AC_SUBST([HAVE_UINT128])

#--------------------------------------------------------------------------
#
# Checks for library functions.

#--------------------------------------------------------------------------

CPPFLAGS="${CPPFLAGS}${CPPFLAGS+ }\$(CODE_COVERAGE_CPPFLAGS)"
CFLAGS="${CFLAGS}${CFLAGS+ }\$(CODE_COVERAGE_CFLAGS)"

# You can use ‘@GNU@’ to make GNU Make constructs unbothersome to
# Automake. (By the way, you often can use ‘$(eval ...)’ as well, but
# @GNU@ here may be better.)
AC_SUBST([GNU],[])

StM_REQUIRE_GNU_MAKE_IN_PATH
StM_CONFIG_MAKEFILES

#AC_CONFIG_FILES([ats2-hashmap.pc])
#AC_CONFIG_FILES([hashmap.pc])

AC_SUBST([SIZEOF_USINT],[${ac_cv_sizeof_unsigned_short_int}])
AC_SUBST([SIZEOF_UINT],[${ac_cv_sizeof_unsigned_int}])
AC_SUBST([SIZEOF_ULINT],[${ac_cv_sizeof_unsigned_long_int}])
AC_SUBST([SIZEOF_ULLINT],[${ac_cv_sizeof_unsigned_long_long_int}])
AC_SUBST([SIZEOF_SIZE],[${ac_cv_sizeof_size_t}])
AC_SUBST([SIZEOF_UINTPTR],[${ac_cv_sizeof_uintptr_t}])
AC_SUBST([SIZEOF_UINT8],[${ac_cv_sizeof_uint8_t}])
AC_SUBST([SIZEOF_UINT16],[${ac_cv_sizeof_uint16_t}])
AC_SUBST([SIZEOF_UINT32],[${ac_cv_sizeof_uint32_t}])
AC_SUBST([SIZEOF_UINT64],[${ac_cv_sizeof_uint64_t}])

AC_SUBST([BITSIZEOF_USINT],[`expr 8 '*' ${ac_cv_sizeof_unsigned_short_int}`])
AC_SUBST([BITSIZEOF_UINT],[`expr 8 '*' ${ac_cv_sizeof_unsigned_int}`])
AC_SUBST([BITSIZEOF_ULINT],[`expr 8 '*' ${ac_cv_sizeof_unsigned_long_int}`])
AC_SUBST([BITSIZEOF_ULLINT],[`expr 8 '*' ${ac_cv_sizeof_unsigned_long_long_int}`])
AC_SUBST([BITSIZEOF_SIZE],[`expr 8 '*' ${ac_cv_sizeof_size_t}`])
AC_SUBST([BITSIZEOF_UINTPTR],[`expr 8 '*' ${ac_cv_sizeof_uintptr_t}`])
AC_SUBST([BITSIZEOF_UINT8],[`expr 8 '*' ${ac_cv_sizeof_uint8_t}`])
AC_SUBST([BITSIZEOF_UINT16],[`expr 8 '*' ${ac_cv_sizeof_uint16_t}`])
AC_SUBST([BITSIZEOF_UINT32],[`expr 8 '*' ${ac_cv_sizeof_uint32_t}`])
AC_SUBST([BITSIZEOF_UINT64],[`expr 8 '*' ${ac_cv_sizeof_uint64_t}`])

AC_SUBST([MIN_SIZEOF_BITINDEX],[4])
AC_SUBST([MAX_SIZEOF_BITINDEX],[8])

AC_SUBST([MAXVALOF_BITINDEX_4],[15])
AC_SUBST([MAXVALOF_BITINDEX_5],[31])
AC_SUBST([MAXVALOF_BITINDEX_6],[63])
AC_SUBST([MAXVALOF_BITINDEX_7],[127])
AC_SUBST([MAXVALOF_BITINDEX_8],[255])

bits_in_index_of ()
{
  if test 32 -le $1 ; then
    echo 8
  elif test 16 -le $1 ; then
    echo 7
  elif test 8 -le $1 ; then
    echo 6
  elif test 4 -le $1 ; then
    echo 5
  elif test 2 -le $1 ; then
    echo 4
  else
    AC_MSG_ERROR([uintptr_t must be at least 2 bytes long])
  fi
}
AC_SUBST([SIZEOF_BITINDEXOF_UINTPTR],[`bits_in_index_of ${ac_cv_sizeof_uintptr_t}`])

AC_CONFIG_FILES([hashmap/HATS/config.hats])
AC_CONFIG_FILES([hashmap/HATS/bits-source-include.hats])

AC_CONFIG_FILES([common-macros.m4])
AC_CONFIG_FILES([hashmap/DATS/bits-source-uintNN.dats.m4])
AC_CONFIG_FILES([hashmap/DATS/bits-source-uint16.dats.m4])
AC_CONFIG_FILES([hashmap/DATS/bits-source-uint32.dats.m4])
AC_CONFIG_FILES([hashmap/DATS/bits-source-uint64.dats.m4])
AC_CONFIG_FILES([tests/test-bits-source-uint64-uint64.dats])

AC_CONFIG_FILES([list-ats-dependencies.dats])

# What to use as the shell in shebangs.
#AC_ARG_VAR([POSIX_SH],[The full absolute path of a POSIX shell])
#POSIX_SH=${POSIX_SH-`command -p -v sh`}

AC_OUTPUT

#--------------------------------------------------------------------------
# local variables:
# coding: utf-8
# end:
