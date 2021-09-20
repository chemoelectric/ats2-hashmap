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

include $(top_srcdir)/aminclude_static.am
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
nobase_nodist_pkginclude_HEADERS =

pkgconfigdir = ${libdir}/pkgconfig
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

AM_CPPFLAGS += -DATS_MEMALLOC_LIBC
AM_CPPFLAGS += -I$(builddir)
AM_CPPFLAGS += -I$(srcdir)
AM_CPPFLAGS += -I$(builddir)/lib
AM_CPPFLAGS += -I$(srcdir)/lib
AM_CPPFLAGS += -I$(PATSHOME)
AM_CPPFLAGS += -I$(PATSHOME)/ccomp/runtime/

LDADD += $(CODE_COVERAGE_LIBS)

CODE_COVERAGE_IGNORE_PATTERN =
CODE_COVERAGE_IGNORE_PATTERN += /usr/include/*
CODE_COVERAGE_IGNORE_PATTERN += /usr/include/*/*
CODE_COVERAGE_IGNORE_PATTERN += $(PATSHOME)/ccomp/runtime/*
CODE_COVERAGE_IGNORE_PATTERN += $(PATSHOME)/prelude/CATS/*

clean-local: code-coverage-clean ats-includes-clean
distclean-local: code-coverage-dist-clean

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
# The ATS2 library.
#

lib_LTLIBRARIES += libats2-hashmap.la

libats2_hashmap_la_SOURCES =
libats2_hashmap_la_DEPENDENCIES =
libats2_hashmap_la_LIBADD =

hashmap/HATS/config.hats: hashmap/HATS/config.hats.in

libats2_hashmap_la_SOURCES += hashmap/SATS/atomic_sats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/atomic_dats.c
CLEANFILES += hashmap/SATS/atomic_sats.c
CLEANFILES += hashmap/DATS/atomic_dats.c
EXTRA_DIST += hashmap/SATS/atomic.sats
EXTRA_DIST += hashmap/DATS/atomic.dats
EXTRA_DIST += hashmap/CATS/atomic.cats

libats2_hashmap_la_SOURCES += hashmap/SATS/spinlock_sats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/spinlock_dats.c
CLEANFILES += hashmap/SATS/spinlock_sats.c
CLEANFILES += hashmap/DATS/spinlock_dats.c
EXTRA_DIST += hashmap/SATS/spinlock.sats
EXTRA_DIST += hashmap/DATS/spinlock.dats
EXTRA_DIST += hashmap/CATS/spinlock.cats

libats2_hashmap_la_SOURCES += hashmap/SATS/initialize-once_sats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/initialize-once_dats.c
CLEANFILES += hashmap/SATS/initialize-once_sats.c
CLEANFILES += hashmap/DATS/initialize-once_dats.c
EXTRA_DIST += hashmap/SATS/initialize-once.sats
EXTRA_DIST += hashmap/DATS/initialize-once.dats

libats2_hashmap_la_SOURCES += hashmap/SATS/array_prf_sats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/array_prf_dats.c
CLEANFILES += hashmap/SATS/array_prf_sats.c
CLEANFILES += hashmap/DATS/array_prf_dats.c
EXTRA_DIST += hashmap/SATS/array_prf.sats
EXTRA_DIST += hashmap/DATS/array_prf.dats

libats2_hashmap_la_SOURCES += hashmap/SATS/memory_sats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/memory_dats.c
CLEANFILES += hashmap/SATS/memory_sats.c
CLEANFILES += hashmap/DATS/memory_dats.c
EXTRA_DIST += hashmap/SATS/memory.sats
EXTRA_DIST += hashmap/DATS/memory.dats
EXTRA_DIST += hashmap/CATS/memory.cats

libats2_hashmap_la_SOURCES += hashmap/SATS/count-one-bits_sats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/count-one-bits_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/count-one-bits-microsoft-c_dats.c
CLEANFILES += hashmap/SATS/count-one-bits_sats.c
CLEANFILES += hashmap/DATS/count-one-bits_dats.c
CLEANFILES += hashmap/DATS/count-one-bits-microsoft-c_dats.c
EXTRA_DIST += hashmap/SATS/count-one-bits.sats
EXTRA_DIST += hashmap/CATS/count-one-bits.cats
EXTRA_DIST += hashmap/DATS/count-one-bits.dats
EXTRA_DIST += hashmap/DATS/count-one-bits-microsoft-c.dats

libats2_hashmap_la_SOURCES += hashmap/SATS/bits-source_sats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint8_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint16_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint32_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint64_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint128_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint64-uint64_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uintptr_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-size_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-usint_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-ulint_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-ullint_dats.c
CLEANFILES += hashmap/HATS/bits-source-include.hats
CLEANFILES += hashmap/SATS/bits-source_sats.c
CLEANFILES += hashmap/DATS/bits-source-uint8_dats.c
CLEANFILES += hashmap/DATS/bits-source-uint16_dats.c
CLEANFILES += hashmap/DATS/bits-source-uint32_dats.c
CLEANFILES += hashmap/DATS/bits-source-uint64_dats.c
CLEANFILES += hashmap/DATS/bits-source-uint128_dats.c
CLEANFILES += hashmap/DATS/bits-source-uint64-uint64_dats.c
CLEANFILES += hashmap/DATS/bits-source-uintptr_dats.c
CLEANFILES += hashmap/DATS/bits-source-size_dats.c
CLEANFILES += hashmap/DATS/bits-source-usint_dats.c
CLEANFILES += hashmap/DATS/bits-source-uint_dats.c
CLEANFILES += hashmap/DATS/bits-source-ulint_dats.c
CLEANFILES += hashmap/DATS/bits-source-ullint_dats.c
CLEANFILES += hashmap/DATS/bits-source-uint8.dats
CLEANFILES += hashmap/DATS/bits-source-uint16.dats
CLEANFILES += hashmap/DATS/bits-source-uint32.dats
CLEANFILES += hashmap/DATS/bits-source-uint64.dats
CLEANFILES += hashmap/DATS/bits-source-uint128.dats
CLEANFILES += hashmap/DATS/bits-source-uintptr.dats
CLEANFILES += hashmap/DATS/bits-source-size.dats
CLEANFILES += hashmap/DATS/bits-source-usint.dats
CLEANFILES += hashmap/DATS/bits-source-uint.dats
CLEANFILES += hashmap/DATS/bits-source-ulint.dats
CLEANFILES += hashmap/DATS/bits-source-ullint.dats
CLEANFILES += hashmap/DATS/bits-source-UINTTYPE.dats.m4
CLEANFILES += hashmap/DATS/bits-source-uint8.dats.m4
CLEANFILES += hashmap/DATS/bits-source-uint16.dats.m4
CLEANFILES += hashmap/DATS/bits-source-uint32.dats.m4
CLEANFILES += hashmap/DATS/bits-source-uint64.dats.m4
CLEANFILES += hashmap/DATS/bits-source-uint128.dats.m4
CLEANFILES += hashmap/DATS/bits-source-uintptr.dats.m4
CLEANFILES += hashmap/DATS/bits-source-size.dats.m4
CLEANFILES += hashmap/DATS/bits-source-usint.dats.m4
CLEANFILES += hashmap/DATS/bits-source-uint.dats.m4
CLEANFILES += hashmap/DATS/bits-source-ulint.dats.m4
CLEANFILES += hashmap/DATS/bits-source-ullint.dats.m4
EXTRA_DIST += hashmap/SATS/bits-source.sats
EXTRA_DIST += hashmap/DATS/bits-source-uint64-uint64.dats
nobase_nodist_pkginclude_HEADERS += hashmap/SATS/bits-source.sats
nobase_nodist_pkginclude_HEADERS += hashmap/HATS/bits-source-include.hats

hashmap/DATS/bits-source-uint8.dats: hashmap/DATS/bits-source-uint8.dats.m4
hashmap/DATS/bits-source-uint8.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4

hashmap/DATS/bits-source-uint16.dats: hashmap/DATS/bits-source-uint16.dats.m4
hashmap/DATS/bits-source-uint16.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4

hashmap/DATS/bits-source-uint32.dats: hashmap/DATS/bits-source-uint32.dats.m4
hashmap/DATS/bits-source-uint32.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4

hashmap/DATS/bits-source-uint64.dats: hashmap/DATS/bits-source-uint64.dats.m4
hashmap/DATS/bits-source-uint64.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4

hashmap/DATS/bits-source-uint128.dats: hashmap/DATS/bits-source-uint128.dats.m4
hashmap/DATS/bits-source-uint128.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4

hashmap/DATS/bits-source-uintptr.dats: hashmap/DATS/bits-source-uintptr.dats.m4
hashmap/DATS/bits-source-uintptr.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4

hashmap/DATS/bits-source-size.dats: hashmap/DATS/bits-source-size.dats.m4
hashmap/DATS/bits-source-size.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4

hashmap/DATS/bits-source-usint.dats: hashmap/DATS/bits-source-usint.dats.m4
hashmap/DATS/bits-source-usint.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4

hashmap/DATS/bits-source-uint.dats: hashmap/DATS/bits-source-uint.dats.m4
hashmap/DATS/bits-source-uint.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4

hashmap/DATS/bits-source-ulint.dats: hashmap/DATS/bits-source-ulint.dats.m4
hashmap/DATS/bits-source-ulint.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4

hashmap/DATS/bits-source-ullint.dats: hashmap/DATS/bits-source-ullint.dats.m4
hashmap/DATS/bits-source-ullint.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4

libats2_hashmap_la_SOURCES += hashmap/SATS/array-mapped-tree_sats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/array-mapped-tree-free_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/array-mapped-tree-create_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/array-mapped-tree-get-entry_dats.c
libats2_hashmap_la_SOURCES += hashmap/SATS/array-mapped-tree-templates_sats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/array-mapped-tree-templates_dats.c
CLEANFILES += hashmap/SATS/array-mapped-tree_sats.c
CLEANFILES += hashmap/DATS/array-mapped-tree-free_dats.c
CLEANFILES += hashmap/DATS/array-mapped-tree-create_dats.c
CLEANFILES += hashmap/DATS/array-mapped-tree-get-entry_dats.c
CLEANFILES += hashmap/SATS/array-mapped-tree-templates_sats.c
CLEANFILES += hashmap/DATS/array-mapped-tree-templates_dats.c
EXTRA_DIST += hashmap/SATS/array-mapped-tree.sats
EXTRA_DIST += hashmap/DATS/array-mapped-tree-free.dats
EXTRA_DIST += hashmap/DATS/array-mapped-tree-create.dats
EXTRA_DIST += hashmap/DATS/array-mapped-tree-get-entry.dats
EXTRA_DIST += hashmap/SATS/array-mapped-tree-templates.sats
EXTRA_DIST += hashmap/DATS/array-mapped-tree-templates.dats

libats2_hashmap_la_SOURCES += hashmap/SATS/uintptr-set_sats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/uintptr-set_dats.c
CLEANFILES += hashmap/SATS/uintptr-set_sats.c
CLEANFILES += hashmap/DATS/uintptr-set_dats.c
EXTRA_DIST += hashmap/SATS/uintptr-set.sats
EXTRA_DIST += hashmap/DATS/uintptr-set.dats
nobase_nodist_pkginclude_HEADERS += hashmap/SATS/uintptr-set.sats

libats2_hashmap_la_SOURCES += hashmap/SATS/hashmap_sats.c
CLEANFILES += hashmap/SATS/hashmap_sats.c
EXTRA_DIST += hashmap/SATS/hashmap.sats
nobase_nodist_pkginclude_HEADERS += hashmap/SATS/hashmap.sats

#--------------------------------------------------------------------------
#
# Tests.
#

TESTS += $(check_PROGRAMS)

check_PROGRAMS =

check_PROGRAMS += tests/test-bits-source-uint16
tests_test_bits_source_uint16_SOURCES = tests/test-bits-source-uint16_dats.c
tests_test_bits_source_uint16_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-bits-source-uint16.dats
CLEANFILES += tests/test-bits-source-uint16
CLEANFILES += tests/test-bits-source-uint16_dats.c

check_PROGRAMS += tests/test-bits-source-uint32
tests_test_bits_source_uint32_SOURCES = tests/test-bits-source-uint32_dats.c
tests_test_bits_source_uint32_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-bits-source-uint32.dats
CLEANFILES += tests/test-bits-source-uint32
CLEANFILES += tests/test-bits-source-uint32_dats.c

check_PROGRAMS += tests/test-bits-source-uint64
tests_test_bits_source_uint64_SOURCES = tests/test-bits-source-uint64_dats.c
tests_test_bits_source_uint64_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-bits-source-uint64.dats
CLEANFILES += tests/test-bits-source-uint64
CLEANFILES += tests/test-bits-source-uint64_dats.c

check_PROGRAMS += tests/test-bits-source-uint64-uint64
tests_test_bits_source_uint64_uint64_SOURCES = tests/test-bits-source-uint64-uint64_dats.c
tests_test_bits_source_uint64_uint64_LDADD = $(lib_LTLIBRARIES)
CLEANFILES += tests/test-bits-source-uint64-uint64.dats
CLEANFILES += tests/test-bits-source-uint64-uint64
CLEANFILES += tests/test-bits-source-uint64-uint64_dats.c

if UINTPTR_IS_UINT64
check_PROGRAMS += tests/test-bits-source-uintptr
tests_test_bits_source_uintptr_SOURCES = tests/test-bits-source-uintptr_dats.c
tests_test_bits_source_uintptr_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-bits-source-uintptr.dats
CLEANFILES += tests/test-bits-source-uintptr
CLEANFILES += tests/test-bits-source-uintptr_dats.c
endif UINTPTR_IS_UINT64

check_PROGRAMS += tests/test-count-one-bits
tests_test_count_one_bits_SOURCES = tests/test-count-one-bits_dats.c
tests_test_count_one_bits_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-count-one-bits.dats
CLEANFILES += tests/test-count-one-bits
CLEANFILES += tests/test-count-one-bits_dats.c

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
#nodist_pkgconfig_DATA += hashmap.pc

#--------------------------------------------------------------------------
# local variables:
# coding: utf-8
# end:
