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

.DELETE_ON_ERROR:

ACLOCAL_AMFLAGS = -I m4 --install
AUTOMAKE_OPTIONS =
AUTOMAKE_OPTIONS += foreign
AUTOMAKE_OPTIONS += subdir-objects
AUTOMAKE_OPTIONS += -Wno-portability

include $(top_srcdir)/config-status-deps.am

@GNU@ include $(top_srcdir)/silent-rules.mk
@GNU@ -include ats-dependencies/*.mk

EXTRA_DIST =
MOSTLYCLEANFILES =
CLEANFILES =
DISTCLEANFILES =
BUILT_SOURCES =
AM_M4FLAGS =
AM_CPPFLAGS =
AM_CFLAGS =
AM_LDFLAGS =
TESTS =
LDADD =
bin_PROGRAMS =
lib_LTLIBRARIES =
EXTRA_PROGRAMS =
nobase_dist_pkginclude_HEADERS =
nobase_nodist_pkginclude_HEADERS =
nodist_pkgconfig_DATA =

EXTRA_DIST += silent-rules.mk
EXTRA_DIST += COPYING
EXTRA_DIST += INSTALL
EXTRA_DIST += README
EXTRA_DIST += AUTHORS

DISTCLEANFILES += Makefile
DISTCLEANFILES += GNUmakefile

# We will not be using exceptions.
AM_CPPFLAGS += -D_ATS_CCOMP_EXCEPTION_NONE

AM_CPPFLAGS += -I$(builddir)
AM_CPPFLAGS += -I$(srcdir)
AM_CPPFLAGS += -I$(builddir)/lib
AM_CPPFLAGS += -I$(srcdir)/lib
AM_CPPFLAGS += -I$(PATSHOME)
AM_CPPFLAGS += -I$(PATSHOME)/ccomp/runtime/

AM_CFLAGS += $(ATS2_POPCOUNT_CFLAGS)

clean-local: ats-includes-clean
clean-local: bits_source_bytes_clean
clean-local: tests-clean

#---------------------------------------------------------------------
#
# Some GNU Make aids you might want to use.
#

comma := ,
empty :=
space := $(empty) $(empty)

# Escape things for sed expressions, etc.
escape = $(subst $$,\$$,$(subst ^,\^,$(subst ],\],$(subst [,\[,$(subst .,\.,$(subst \,\\,$(1)))))))

#--------------------------------------------------------------------------

TOTAL_M4FLAGS =
TOTAL_M4FLAGS += $(AM_M4FLAGS)
TOTAL_M4FLAGS += $(M4FLAGS)
TOTAL_M4FLAGS += $(XM4FLAGS)

@GNU@ include $(top_srcdir)/m4-rules.mk
EXTRA_DIST += m4-rules.mk

#--------------------------------------------------------------------------

PATSOPT_DEPS =
PATSCC_DEPS =

AM_PATSOPTFLAGS =
AM_PATSOPTFLAGS += -IATS $(builddir)
AM_PATSOPTFLAGS += -IATS $(srcdir)
AM_PATSOPTFLAGS += $(ATS2_POPCOUNT_PATSOPTFLAGS)

TOTAL_PATSOPTFLAGS =
TOTAL_PATSOPTFLAGS += $(AM_PATSOPTFLAGS)
TOTAL_PATSOPTFLAGS += $(PATSOPTFLAGS)
TOTAL_PATSOPTFLAGS += $(XPATSOPTFLAGS)

TESTS_PATSOPTFLAGS =
TESTS_PATSOPTFLAGS += -IATS $(builddir)/tests
TESTS_PATSOPTFLAGS += -IATS $(srcdir)/tests

@GNU@ define write-dependencies-file =
@GNU@	$(MKDIR_P) ats-dependencies && \
@GNU@		echo $(1): $(shell ./list-ats-dependencies $(2)) \
@GNU@			> ats-dependencies/`echo $(@) | $(SED) 's|/|_057_|g'`.mk
@GNU@ endef

.PHONY: ats-includes-clean
ats-includes-clean:
	-rm -f -R ats-dependencies

%_depsprog.c: %.dats $(PATSOPT_DEPS)
	@$(MKDIR_P) $(@D)
	$(call v,PATSOPT)$(PATSOPT) -o $(@) $(TOTAL_PATSOPTFLAGS) -d $(<)

if DEPENDENCY_TRACKING
@GNU@ include $(top_srcdir)/ats-deptracking-rules.mk
else !DEPENDENCY_TRACKING
@GNU@ include $(top_srcdir)/ats-nodeptracking-rules.mk
endif !DEPENDENCY_TRACKING
EXTRA_DIST += ats-deptracking-rules.mk
EXTRA_DIST += ats-nodeptracking-rules.mk

#--------------------------------------------------------------------------
#
# The ATS2 libraries.
#

lib_LTLIBRARIES += libats2-hashmap.la

libats2_hashmap_la_SOURCES =
libats2_hashmap_la_DEPENDENCIES =
libats2_hashmap_la_LIBADD = $(ATS2_POPCOUNT_LIBS)

libats2_hashmap_la_SOURCES += hashmap/SATS/array-proofs_sats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/array-proofs_dats.c
CLEANFILES += hashmap/SATS/array-proofs_sats.c
CLEANFILES += hashmap/DATS/array-proofs_dats.c
EXTRA_DIST += hashmap/SATS/array-proofs.sats
EXTRA_DIST += hashmap/DATS/array-proofs.dats

#libats2_hashmap_la_SOURCES += hashmap/SATS/memory_sats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/memory_dats.c
#CLEANFILES += hashmap/SATS/memory_sats.c
#CLEANFILES += hashmap/DATS/memory_dats.c
#EXTRA_DIST += hashmap/SATS/memory.sats
#EXTRA_DIST += hashmap/DATS/memory.dats
#EXTRA_DIST += hashmap/CATS/memory.cats
#
#libats2_hashmap_la_SOURCES += hashmap/SATS/print-bitmap_sats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/print-bitmap_dats.c
#CLEANFILES += hashmap/SATS/print-bitmap_sats.c
#CLEANFILES += hashmap/DATS/print-bitmap_dats.c
#EXTRA_DIST += hashmap/SATS/print-bitmap.sats
#EXTRA_DIST += hashmap/DATS/print-bitmap.dats

libats2_hashmap_la_SOURCES += hashmap/SATS/bits_source-parameters_sats.c
libats2_hashmap_la_SOURCES += hashmap/SATS/bits_source_sats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_uint8_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_uint16_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_uint32_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_uint64_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_uint64_uint64_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_nbytes_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_1byte_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_2bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_3bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_4bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_5bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_6bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_7bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_8bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_9bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_10bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_11bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_12bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_13bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_14bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_15bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_16bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_17bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_18bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_19bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_20bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_21bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_22bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_23bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_24bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_25bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_26bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_27bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_28bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_29bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_30bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_31bytes_implementation_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_32bytes_implementation_dats.c
CLEANFILES += hashmap/SATS/bits_source-parameters_sats.c
CLEANFILES += hashmap/SATS/bits_source_sats.c
CLEANFILES += hashmap/DATS/bits_source_dats.c
CLEANFILES += hashmap/DATS/bits_source_uint8_dats.c
CLEANFILES += hashmap/DATS/bits_source_uint8.dats
CLEANFILES += hashmap/DATS/bits_source_uint16_dats.c
CLEANFILES += hashmap/DATS/bits_source_uint16.dats
CLEANFILES += hashmap/DATS/bits_source_uint32_dats.c
CLEANFILES += hashmap/DATS/bits_source_uint32.dats
CLEANFILES += hashmap/DATS/bits_source_uint64_dats.c
CLEANFILES += hashmap/DATS/bits_source_uint64.dats
CLEANFILES += hashmap/DATS/bits_source_uint64_uint64_dats.c
CLEANFILES += hashmap/DATS/bits_source_uint64_uint64.dats
CLEANFILES += hashmap/DATS/bits_source_nbytes_dats.c
nobase_nodist_pkginclude_HEADERS += hashmap/SATS/bits_source-parameters.sats
nobase_dist_pkginclude_HEADERS += hashmap/SATS/bits_source.sats
nobase_dist_pkginclude_HEADERS += hashmap/DATS/bits_source.dats
EXTRA_DIST += hashmap/DATS/bits_source_nbytes.dats
hashmap/DATS/bits_source_uint8.dats: hashmap/DATS/bits_source_uint8.dats.m4 \
									hashmap/DATS/bits_source_UINTnn.dats.m4
hashmap/DATS/bits_source_uint16.dats: hashmap/DATS/bits_source_uint16.dats.m4 \
									hashmap/DATS/bits_source_UINTnn.dats.m4
hashmap/DATS/bits_source_uint32.dats: hashmap/DATS/bits_source_uint32.dats.m4 \
									hashmap/DATS/bits_source_UINTnn.dats.m4
hashmap/DATS/bits_source_uint64.dats: hashmap/DATS/bits_source_uint64.dats.m4 \
									hashmap/DATS/bits_source_UINTnn.dats.m4
hashmap/DATS/bits_source_uint64_uint64.dats: hashmap/DATS/bits_source_uint64_uint64.dats.m4

BUILT_SOURCES += hashmap/DATS/bits_source_1byte_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_2bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_3bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_4bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_5bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_6bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_7bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_8bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_9bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_10bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_11bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_12bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_13bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_14bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_15bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_16bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_17bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_18bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_19bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_20bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_21bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_22bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_23bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_24bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_25bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_26bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_27bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_28bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_29bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_30bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_31bytes_implementation.dats
BUILT_SOURCES += hashmap/DATS/bits_source_32bytes_implementation.dats

.PHONY: bits_source_bytes_clean
bits_source_bytes_clean:
	-rm -f hashmap/DATS/bits_source_1byte_implementation{_dats.c,.dats}
	-rm -f hashmap/DATS/bits_source_*bytes_implementation{_dats.c,.dats}

hashmap/DATS/bits_source_1byte_implementation.dats: GNUmakefile
	$(call v,GEN)printf "%s\n%s\n%s\n%s\n%s\n%s\n%s\n" \
		'#define ATS_PACKNAME "ats2-hashmap"' \
		'#define ATS_EXTERN_PREFIX "ats2_hashmap_"' \
		'#define ATS_DYNLOADFLAG 0' \
		'staload "hashmap/SATS/bits_source.sats"' \
		'implement' \
	    'bits_source_1byte (hash, depth) =' \
		'  bits_source_nbytes (i2sz 1, hash, depth)' \
		> $(@)

hashmap/DATS/bits_source_%bytes_implementation.dats: GNUmakefile
	$(call v,GEN)printf "%s\n%s\n%s\n%s\n%s\n%s\n%s\n" \
		'#define ATS_PACKNAME "ats2-hashmap"' \
		'#define ATS_EXTERN_PREFIX "ats2_hashmap_"' \
		'#define ATS_DYNLOADFLAG 0' \
		'staload "hashmap/SATS/bits_source.sats"' \
		'implement' \
	    'bits_source_$(*)bytes (hash, depth) =' \
		'  bits_source_nbytes (i2sz $(*), hash, depth)' \
		> $(@)

libats2_hashmap_la_SOURCES += hashmap/SATS/population_map_sats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/population_map_dats.c
CLEANFILES += hashmap/SATS/population_map_sats.c
CLEANFILES += hashmap/DATS/population_map_dats.c
nobase_dist_pkginclude_HEADERS += hashmap/SATS/population_map.sats
nobase_dist_pkginclude_HEADERS += hashmap/DATS/population_map.dats

libats2_hashmap_la_SOURCES += hashmap/SATS/hashmap_sats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/hashmap_dats.c
CLEANFILES += hashmap/SATS/hashmap_sats.c
CLEANFILES += hashmap/DATS/hashmap_dats.c
nobase_dist_pkginclude_HEADERS += hashmap/SATS/hashmap.sats
nobase_dist_pkginclude_HEADERS += hashmap/DATS/hashmap.dats
nobase_dist_pkginclude_HEADERS += hashmap/HATS/hashmap.hats

#if WITH_ATS2_SPOOKYHASH
#libats2_hashmap_la_SOURCES += hashmap/SATS/strptr-map_sats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/strptr-map_dats.c
#endif WITH_ATS2_SPOOKYHASH
#CLEANFILES += hashmap/SATS/strptr-map_sats.c
#CLEANFILES += hashmap/DATS/strptr-map_dats.c
#EXTRA_DIST += hashmap/SATS/strptr-map.sats
#EXTRA_DIST += hashmap/DATS/strptr-map.dats
#if WITH_ATS2_SPOOKYHASH
#nobase_nodist_pkginclude_HEADERS += hashmap/SATS/strptr-map.sats
#nobase_nodist_pkginclude_HEADERS += hashmap/DATS/strptr-map.dats
#endif WITH_ATS2_SPOOKYHASH

#--------------------------------------------------------------------------
#
# Tests.
#

TESTS += $(check_PROGRAMS)

check_PROGRAMS =

check_PROGRAMS += tests/test-bits_source_uint8
tests_test_bits_source_uint8_SOURCES = tests/test-bits_source_uint8_dats.c
tests_test_bits_source_uint8_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-bits_source_uint8.dats
CLEANFILES += tests/test-bits_source_uint8
CLEANFILES += tests/test-bits_source_uint8_dats.c

check_PROGRAMS += tests/test-bits_source_uint16
tests_test_bits_source_uint16_SOURCES = tests/test-bits_source_uint16_dats.c
tests_test_bits_source_uint16_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-bits_source_uint16.dats
CLEANFILES += tests/test-bits_source_uint16
CLEANFILES += tests/test-bits_source_uint16_dats.c

check_PROGRAMS += tests/test-bits_source_uint32
tests_test_bits_source_uint32_SOURCES = tests/test-bits_source_uint32_dats.c
tests_test_bits_source_uint32_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-bits_source_uint32.dats
CLEANFILES += tests/test-bits_source_uint32
CLEANFILES += tests/test-bits_source_uint32_dats.c

check_PROGRAMS += tests/test-bits_source_uint64
tests_test_bits_source_uint64_SOURCES = tests/test-bits_source_uint64_dats.c
tests_test_bits_source_uint64_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-bits_source_uint64.dats
CLEANFILES += tests/test-bits_source_uint64
CLEANFILES += tests/test-bits_source_uint64_dats.c

check_PROGRAMS += tests/test-bits_source_uint64_uint64
tests_test_bits_source_uint64_uint64_SOURCES = tests/test-bits_source_uint64_uint64_dats.c
tests_test_bits_source_uint64_uint64_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-bits_source_uint64_uint64.dats
CLEANFILES += tests/test-bits_source_uint64_uint64
CLEANFILES += tests/test-bits_source_uint64_uint64_dats.c

check_PROGRAMS += tests/test-bits_source_1byte
tests_test_bits_source_1byte_SOURCES = tests/test-bits_source_1byte_dats.c
tests_test_bits_source_1byte_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-bits_source_1byte.dats
CLEANFILES += tests/test-bits_source_1byte
CLEANFILES += tests/test-bits_source_1byte_dats.c

check_PROGRAMS += tests/test-bits_source_8bytes
tests_test_bits_source_8bytes_SOURCES = tests/test-bits_source_8bytes_dats.c
tests_test_bits_source_8bytes_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-bits_source_8bytes.dats
CLEANFILES += tests/test-bits_source_8bytes
CLEANFILES += tests/test-bits_source_8bytes_dats.c

check_PROGRAMS += tests/test-bits_source_16bytes
tests_test_bits_source_16bytes_SOURCES = tests/test-bits_source_16bytes_dats.c
tests_test_bits_source_16bytes_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-bits_source_16bytes.dats
CLEANFILES += tests/test-bits_source_16bytes
CLEANFILES += tests/test-bits_source_16bytes_dats.c

check_PROGRAMS += tests/test-population_map
tests_test_population_map_SOURCES = tests/test-population_map_dats.c
tests_test_population_map_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-population_map.dats
CLEANFILES += tests/test-population_map
CLEANFILES += tests/test-population_map_dats.c

check_PROGRAMS += tests/test-a-uint8-map
tests_test_a_uint8_map_SOURCES = tests/test-a-uint8-map_dats.c
tests_test_a_uint8_map_CPPFLAGS = ${AM_CPPFLAGS} -DATS_MEMALLOC_LIBC
tests_test_a_uint8_map_LDADD = $(lib_LTLIBRARIES)
tests_test_a_uint8_map_LDADD += -L'$(PATSHOME)/ccomp/atslib/lib' -latslib
EXTRA_DIST += tests/test-a-uint8-map.dats
CLEANFILES += tests/test-a-uint8-map
CLEANFILES += tests/test-a-uint8-map_dats.c

check_PROGRAMS += tests/test-separate-chaining-1
tests_test_separate_chaining_1_SOURCES = tests/test-separate-chaining-1_dats.c
tests_test_separate_chaining_1_CPPFLAGS = ${AM_CPPFLAGS} -DATS_MEMALLOC_LIBC
tests_test_separate_chaining_1_LDADD = $(lib_LTLIBRARIES)
tests_test_separate_chaining_1_LDADD += -L'$(PATSHOME)/ccomp/atslib/lib' -latslib
EXTRA_DIST += tests/test-separate-chaining-1.dats
CLEANFILES += tests/test-separate-chaining-1
CLEANFILES += tests/test-separate-chaining-1_dats.c

check_PROGRAMS += tests/test-separate-chaining-2
tests_test_separate_chaining_2_SOURCES = tests/test-separate-chaining-2_dats.c
tests_test_separate_chaining_2_CPPFLAGS = ${AM_CPPFLAGS} -DATS_MEMALLOC_LIBC
tests_test_separate_chaining_2_LDADD = $(lib_LTLIBRARIES)
tests_test_separate_chaining_2_LDADD += -L'$(PATSHOME)/ccomp/atslib/lib' -latslib
EXTRA_DIST += tests/test-separate-chaining-2.dats
CLEANFILES += tests/test-separate-chaining-2
CLEANFILES += tests/test-separate-chaining-2_dats.c

.PHONY: tests-clean
tests-clean:
	-rm -f tests/*.structure

#--------------------------------------------------------------------------
#
# Computation of dependencies.
#

EXTRA_PROGRAMS += list-ats-dependencies
EXTRA_DIST += list-ats-dependencies.dats
CLEANFILES += list-ats-dependencies
CLEANFILES += list-ats-dependencies_depsprog.c

list_ats_dependencies_SOURCES =
list_ats_dependencies_SOURCES += list-ats-dependencies_depsprog.c
list_ats_dependencies_CPPFLAGS =
list_ats_dependencies_CPPFLAGS += $(AM_CPPFLAGS)
list_ats_dependencies_CPPFLAGS += -DATS_MEMALLOC_LIBC
list_ats_dependencies_DEPENDENCIES =
list_ats_dependencies_DEPENDENCIES += list-ats-dependencies.dats
list_ats_dependencies_LDADD =
list_ats_dependencies_LDADD += -L'$(PATSHOME)/ccomp/atslib/lib'
list_ats_dependencies_LDADD += -latslib

#--------------------------------------------------------------------------

#nodist_pkgconfig_DATA += ats2-hashmap.pc

#--------------------------------------------------------------------------
# local variables:
# coding: utf-8
# end:
