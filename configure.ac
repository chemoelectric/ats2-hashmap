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

AC_SUBST([ATS_PACKNAME],[ats2-hashmap])
AC_SUBST([ATS_EXTERN_PREFIX],[ats2_hashmap_])
AC_SUBST([ATS_CATS_DIRECTORY],[hashmap/CATS])
AC_SUBST([ATS_SATS_DIRECTORY],[hashmap/SATS])
AC_SUBST([ATS_DATS_DIRECTORY],[hashmap/DATS])

# The unsigned integer type to use for population maps.
AC_SUBST([POPULATION_MAP_T],[uint64])
AC_SUBST([POPULATION_MAP_KIND],[uint64_kind])

# The maximum number of bits to take at a time from a hash.
# Equals log2 of the number of bits in a POPULATION_MAP_T.
AC_SUBST([BITS_SOURCE_NUM_BITS],[6])

# The maximum numeric value of bits taken from a hash.
# Equals 2**BITS_SOURCE_NUM_BITS - 1
AC_SUBST([BITS_SOURCE_MAXVAL],[63])

# A bit mask to use when extracting bits from a hash.
# Equals 2**BITS_SOURCE_NUM_BITS - 1
AC_SUBST([BITS_SOURCE_MASK],[63])

# The number of bits in a uint64.
# Equals 2**BITS_SOURCE_NUM_BITS
AC_SUBST([BITS_SOURCE_EXPT2],[64])

# Which hash functions/packages to support.
AC_ARG_WITH([hash],
  [AS_HELP_STRING([--with-hash=HASH_LIST],
    [HASH_LIST=no,spookyhash,murmurhash3_32,halfsiphash_32,halfsiphash_64,siphash_64,siphash_128 @{:@comma-separated; @&t@ preferred hash listed first@:}@ @<:@--with-hash=spookyhash@:>@])],
  [],
  [with_hash=spookyhash])

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

AM_CONDITIONAL([DEPENDENCY_TRACKING],
  [test x"${enable_dependency_tracking}" != xno])

PKG_PROG_PKG_CONFIG
PKG_CONFIG="${PKG_CONFIG} --define-variable=PATSHOME=\"${PATSHOME}\""
PKG_INSTALLDIR

#--------------------------------------------------------------------------
#
# Checks for libraries.

default_hash=
with_spookyhash=no
with_murmurhash3_32=no
with_halfsiphash_32=no
with_halfsiphash_64=no
with_siphash_64=no
with_siphash_128=no
with_ats2_spookyhash=no
with_ats2_murmurhash3=no
with_ats2_siphash=no
for hash in `printf "%s" "${with_hash}" | ${SED} -e 's/,/ /g'`; do
  test x"${default_hash}" = x && default_hash="${hash}"
  AS_CASE([x"${hash}"],
    [xno],[],
    [xspookyhash],[with_spookyhash=yes
                   with_ats2_spookyhash=yes],
    [xmurmurhash3_32],[with_murmurhash3_32=yes
                       with_ats2_murmurhash3=yes],
    [xhalfsiphash_32],[with_halfsiphash_32=yes
                       with_ats2_siphash=yes],
    [xhalfsiphash_64],[with_halfsiphash_64=yes
                       with_ats2_siphash=yes],
    [xsiphash_64],[with_siphash_64=yes
                   with_ats2_siphash=yes],
    [xsiphash_128],[with_siphash_128=yes
                    with_ats2_siphash=yes],
    [x*],[AC_MSG_ERROR([--with-hash entry not supported: "${hash}"])])
done
DEFAULT_HASH=
AS_IF([test x"${default_hash}" != xno],
      [DEFAULT_HASH="${default_hash}"])
AC_SUBST([DEFAULT_HASH])

AS_IF([test "x${with_ats2_spookyhash}" != xno],
  [PKG_CHECK_MODULES([ATS2_SPOOKYHASH],[ats2-spookyhash],
    [REQUIRES_PRIVATE_PKGS="${REQUIRES_PRIVATE_PKGS}${REQUIRES_PRIVATE_PKGS+ }ats2-spookyhash"
     PKG_CHECK_VAR([ATS2_SPOOKYHASH_PATSOPTFLAGS],[ats2-spookyhash],[PATSOPTFLAGS])],
    [AC_MSG_FAILURE([ats2-spookyhash not found. Consider installing it, configuring --without-hash, etc.])])
])

AS_IF([test "x${with_ats2_murmurhash3}" != xno],
  [PKG_CHECK_MODULES([ATS2_MURMURHASH3],[ats2-murmurhash3],
    [REQUIRES_PRIVATE_PKGS="${REQUIRES_PRIVATE_PKGS}${REQUIRES_PRIVATE_PKGS+ }ats2-murmurhash3"
     PKG_CHECK_VAR([ATS2_MURMURHASH3_PATSOPTFLAGS],[ats2-murmurhash3],[PATSOPTFLAGS])],
    [AC_MSG_FAILURE([ats2-murmurhash3 not found. Consider installing it or configuring without it])])
])

AS_IF([test "x${with_ats2_siphash}" != xno],
  [PKG_CHECK_MODULES([ATS2_SIPHASH],[ats2-siphash],
    [REQUIRES_PRIVATE_PKGS="${REQUIRES_PRIVATE_PKGS}${REQUIRES_PRIVATE_PKGS+ }ats2-siphash"
     PKG_CHECK_VAR([ATS2_SIPHASH_PATSOPTFLAGS],[ats2-siphash],[PATSOPTFLAGS])],
    [AC_MSG_FAILURE([ats2-siphash not found. Consider installing it or configuring without it])])
])

PKG_CHECK_MODULES([ATS2_POPCOUNT],[ats2-popcount],
  [REQUIRES_PRIVATE_PKGS="${REQUIRES_PRIVATE_PKGS}${REQUIRES_PRIVATE_PKGS+ }ats2-popcount"
   PKG_CHECK_VAR([ATS2_POPCOUNT_PATSOPTFLAGS],[ats2-popcount],[PATSOPTFLAGS])],
  [AC_MSG_FAILURE([ats2-popcount was not found.])])

AC_SUBST([REQUIRES_PRIVATE_PKGS])

#--------------------------------------------------------------------------
#
# Checks for header files.

#--------------------------------------------------------------------------
#
# Checks for typedefs, structures, and compiler characteristics.

AC_SUBST([WARNING_CFLAGS])
if test -z "${WARNING_CFLAGS}"; then
   StM_GNU_C_FLAGS([WARNING_CFLAGS],
      [-Wpointer-arith],
      [-Wl[,]--warn-common])
fi
if test -n "${WARNING_CFLAGS}"; then
  CFLAGS="${CFLAGS}${CFLAGS+ }${WARNING_CFLAGS}"
fi

#--------------------------------------------------------------------------
#
# Checks for library functions.

#--------------------------------------------------------------------------

# You can use ‘@GNU@’ to make GNU Make constructs unbothersome to
# Automake. (By the way, you often can use ‘$(eval ...)’ as well, but
# @GNU@ here may be better.)
AC_SUBST([GNU],[])

StM_REQUIRE_GNU_MAKE_IN_PATH
StM_CONFIG_MAKEFILES

#AC_CONFIG_FILES([ats2-hashmap.pc])
#AC_CONFIG_FILES([hashmap.pc])

AC_CONFIG_FILES([common-macros.m4])

AC_CONFIG_FILES([hashmap/SATS/bits_source-parameters.sats])
AC_CONFIG_FILES([hashmap/DATS/bits_source_UINTnn.dats.m4])
AC_CONFIG_FILES([hashmap/DATS/bits_source_uint8.dats.m4])
AC_CONFIG_FILES([hashmap/DATS/bits_source_uint16.dats.m4])
AC_CONFIG_FILES([hashmap/DATS/bits_source_uint32.dats.m4])
AC_CONFIG_FILES([hashmap/DATS/bits_source_uint64.dats.m4])
AC_CONFIG_FILES([hashmap/DATS/bits_source_uint64_uint64.dats.m4])

AC_CONFIG_FILES([hashmap/SATS/array-proofs.sats])
AC_CONFIG_FILES([hashmap/DATS/array-proofs.dats])

AC_CONFIG_FILES([hashmap/CATS/memory.cats])
AC_CONFIG_FILES([hashmap/SATS/memory.sats])
AC_CONFIG_FILES([hashmap/DATS/memory.dats])

AC_CONFIG_FILES([list-ats-dependencies.dats])

AC_CONFIG_FILES([tests/2021.10.28.11.59.16.structure.reference])
AC_CONFIG_FILES([tests/2021.10.28.12.10.38.structure.reference])
AC_CONFIG_FILES([tests/2021.10.28.12.13.23.structure.reference])
AC_CONFIG_FILES([tests/2021.10.28.12.16.30.structure.reference])
AC_CONFIG_FILES([tests/2021.10.28.15.41.28.structure.reference])
AC_CONFIG_FILES([tests/2021.10.29.06.20.08.structure.reference])
AC_CONFIG_FILES([tests/2021.10.29.06.31.29.structure.reference])
AC_CONFIG_FILES([tests/2021.10.29.13.44.21.structure.reference])
AC_CONFIG_FILES([tests/2021.10.29.13.58.50.structure.reference])
AC_CONFIG_FILES([tests/2021.10.29.14.01.48.structure.reference])
AC_CONFIG_FILES([tests/2021.10.29.14.02.11.structure.reference])
AC_CONFIG_FILES([tests/2021.10.31.10.54.20.structure.reference])
AC_CONFIG_FILES([tests/2021.10.31.11.39.37.structure.reference])
AC_CONFIG_FILES([tests/2021.10.31.13.08.40.structure.reference])
AC_CONFIG_FILES([tests/2021.10.31.13.19.39.structure.reference])
AC_CONFIG_FILES([tests/2021.10.31.13.23.10.structure.reference])
AC_CONFIG_FILES([tests/2021.11.02.08.39.34.structure.reference])
AC_CONFIG_FILES([tests/2021.11.02.09.07.40.structure.reference])
AC_CONFIG_FILES([tests/2021.11.02.09.11.02.structure.reference])
AC_CONFIG_FILES([tests/2021.11.02.09.17.00.structure.reference])
AC_CONFIG_FILES([tests/2021.11.02.09.19.00.structure.reference])
AC_CONFIG_FILES([tests/2021.11.04.12.03.51.structure.reference])
AC_CONFIG_FILES([tests/2021.11.04.12.09.50.structure.reference])
AC_CONFIG_FILES([tests/2021.11.04.12.12.30.structure.reference])
AC_CONFIG_FILES([tests/2021.11.04.12.17.00.structure.reference])
AC_CONFIG_FILES([tests/2021.11.04.12.21.07.structure.reference])
AC_CONFIG_FILES([tests/2021.11.04.12.24.49.structure.reference])
AC_CONFIG_FILES([tests/2021.11.04.12.49.55.structure.reference])
AC_CONFIG_FILES([tests/2021.11.04.12.52.24.structure.reference])
AC_CONFIG_FILES([tests/2021.11.04.12.56.31.structure.reference])
AC_CONFIG_FILES([tests/2021.11.04.12.58.34.structure.reference])
AC_CONFIG_FILES([tests/2021.11.04.13.01.28.structure.reference])
AC_CONFIG_FILES([tests/2021.11.04.13.03.31.structure.reference])
AC_CONFIG_FILES([tests/2021.11.04.15.37.36.structure.reference])
AC_CONFIG_FILES([tests/2021.11.04.15.42.11.structure.reference])
AC_CONFIG_FILES([tests/2021.11.04.15.45.14.structure.reference])
AC_CONFIG_FILES([tests/2021.11.04.15.47.40.structure.reference])
AC_CONFIG_FILES([tests/2021.11.04.15.49.22.structure.reference])
AC_CONFIG_FILES([tests/2021.11.04.15.51.36.structure.reference])
AC_CONFIG_FILES([tests/2021.11.05.08.58.41.structure.reference])
AC_CONFIG_FILES([tests/2021.11.05.09.01.02.structure.reference])
AC_CONFIG_FILES([tests/2021.11.05.09.06.12.structure.reference])
AC_CONFIG_FILES([tests/2021.11.05.09.12.56.structure.reference])
AC_CONFIG_FILES([tests/2021.11.05.09.19.39.structure.reference])
AC_CONFIG_FILES([tests/2021.11.05.09.19.40.structure.reference])
AC_CONFIG_FILES([tests/2021.11.05.09.19.41.structure.reference])
AC_CONFIG_FILES([tests/2021.11.05.09.19.42.structure.reference])
AC_CONFIG_FILES([tests/2021.11.06.15.34.58.structure.reference])
AC_CONFIG_FILES([tests/2021.11.06.15.34.59.structure.reference])
AC_CONFIG_FILES([tests/2021.11.06.15.55.46.structure.reference])
AC_CONFIG_FILES([tests/2021.11.06.15.55.47.structure.reference])
AC_CONFIG_FILES([tests/2021.11.06.15.55.48.structure.reference])
AC_CONFIG_FILES([tests/2021.11.06.15.55.49.structure.reference])
AC_CONFIG_FILES([tests/2021.11.06.15.55.50.structure.reference])
AC_CONFIG_FILES([tests/2021.11.06.15.55.51.structure.reference])

AM_CONDITIONAL([WITH_DEFAULT_HASH_SPOOKYHASH],
               [test "x${DEFAULT_HASH}" = xspookyhash])
AM_CONDITIONAL([WITH_DEFAULT_HASH_MURMURHASH3_32],
               [test "x${DEFAULT_HASH}" = xmurmurhash3_32])
AM_CONDITIONAL([WITH_DEFAULT_HASH_HALFSIPHASH_32],
               [test "x${DEFAULT_HASH}" = xhalfsiphash_32])
AM_CONDITIONAL([WITH_DEFAULT_HASH_HALFSIPHASH_64],
               [test "x${DEFAULT_HASH}" = xhalfsiphash_64])
AM_CONDITIONAL([WITH_DEFAULT_HASH_SIPHASH_64],
               [test "x${DEFAULT_HASH}" = xsiphash_64])
AM_CONDITIONAL([WITH_DEFAULT_HASH_SIPHASH_128],
               [test "x${DEFAULT_HASH}" = xsiphash_128])

AM_CONDITIONAL([WITH_SPOOKYHASH],
               [test "x${with_spookyhash}" != xno])
AM_CONDITIONAL([WITH_MURMURHASH3_32],
               [test "x${with_murmurhash3_32}" != xno])
AM_CONDITIONAL([WITH_HALFSIPHASH_32],
               [test "x${with_halfsiphash_32}" != xno])
AM_CONDITIONAL([WITH_HALFSIPHASH_64],
               [test "x${with_halfsiphash_64}" != xno])
AM_CONDITIONAL([WITH_SIPHASH_64],
               [test "x${with_siphash_64}" != xno])
AM_CONDITIONAL([WITH_SIPHASH_128],
               [test "x${with_siphash_128}" != xno])

AM_CONDITIONAL([WITH_ATS2_SPOOKYHASH],
               [test "x${with_ats2_spookyhash}" != xno])
AM_CONDITIONAL([WITH_ATS2_MURMURHASH3],
               [test "x${with_ats2_murmurhash3}" != xno])
AM_CONDITIONAL([WITH_ATS2_SIPHASH],
               [test "x${with_ats2_siphash}" != xno])

AC_OUTPUT

#--------------------------------------------------------------------------
# local variables:
# coding: utf-8
# end:
