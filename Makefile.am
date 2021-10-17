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

#AM_CPPFLAGS += -DATS_MEMALLOC_LIBC  # <- FIXME: Try to do this only when building tests.
AM_CPPFLAGS += -I$(builddir)
AM_CPPFLAGS += -I$(srcdir)
AM_CPPFLAGS += -I$(builddir)/lib
AM_CPPFLAGS += -I$(srcdir)/lib
AM_CPPFLAGS += -I$(PATSHOME)
AM_CPPFLAGS += -I$(PATSHOME)/ccomp/runtime/

AM_CFLAGS += $(ATS2_POPCOUNT_CFLAGS)

clean-local: ats-includes-clean

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

#hashmap/HATS/config.hats: hashmap/HATS/config.hats.in

# FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME: REMOVE THESE : FIXME FIXME FIXME FIXME FIXME FIXME
#libats2_hashmap_la_SOURCES += hashmap/SATS/atomic_sats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/atomic_dats.c
#CLEANFILES += hashmap/SATS/atomic_sats.c
#CLEANFILES += hashmap/DATS/atomic_dats.c
#
#libats2_hashmap_la_SOURCES += hashmap/SATS/spinlock_sats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/spinlock_dats.c
#CLEANFILES += hashmap/SATS/spinlock_sats.c
#CLEANFILES += hashmap/DATS/spinlock_dats.c
#
#libats2_hashmap_la_SOURCES += hashmap/SATS/initialize_once_sats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/initialize_once_dats.c
#CLEANFILES += hashmap/SATS/initialize_once_sats.c
#CLEANFILES += hashmap/DATS/initialize_once_dats.c
# FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME: REMOVE THESE : FIXME FIXME FIXME FIXME FIXME FIXME

#libats2_hashmap_la_SOURCES += hashmap/SATS/array-proofs_sats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/array-proofs_dats.c
#CLEANFILES += hashmap/SATS/array-proofs_sats.c
#CLEANFILES += hashmap/DATS/array-proofs_dats.c
#EXTRA_DIST += hashmap/SATS/array-proofs.sats
#EXTRA_DIST += hashmap/DATS/array-proofs.dats
#
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

#nobase_nodist_pkginclude_HEADERS += hashmap/CATS/const.cats # FIXME: PROBABLY NOT NEEDED : FIXME FIXME FIXME

libats2_hashmap_la_SOURCES += hashmap/SATS/bits_source-parameters_sats.c
libats2_hashmap_la_SOURCES += hashmap/SATS/bits_source_sats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_uint8_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_uint16_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_uint32_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_uint64_dats.c
CLEANFILES += hashmap/SATS/bits_source-parameters_sats.c
CLEANFILES += hashmap/SATS/bits_source_sats.c
CLEANFILES += hashmap/DATS/bits_source_uint8_dats.c
CLEANFILES += hashmap/DATS/bits_source_uint8.dats
CLEANFILES += hashmap/DATS/bits_source_uint16_dats.c
CLEANFILES += hashmap/DATS/bits_source_uint16.dats
CLEANFILES += hashmap/DATS/bits_source_uint32_dats.c
CLEANFILES += hashmap/DATS/bits_source_uint32.dats
CLEANFILES += hashmap/DATS/bits_source_uint64_dats.c
CLEANFILES += hashmap/DATS/bits_source_uint64.dats
nobase_nodist_pkginclude_HEADERS += hashmap/SATS/bits_source-parameters.sats
nobase_dist_pkginclude_HEADERS += hashmap/SATS/bits_source.sats
hashmap/DATS/bits_source_uint8.dats: hashmap/DATS/bits_source_UINTnn.dats.m4
hashmap/DATS/bits_source_uint16.dats: hashmap/DATS/bits_source_UINTnn.dats.m4
hashmap/DATS/bits_source_uint32.dats: hashmap/DATS/bits_source_UINTnn.dats.m4
hashmap/DATS/bits_source_uint64.dats: hashmap/DATS/bits_source_UINTnn.dats.m4

#libats2_hashmap_la_SOURCES += hashmap/SATS/bits-source_sats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint8_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint16_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint32_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint64_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint128_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uintptr_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-size_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-usint_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-ulint_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-ullint_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint64-uint64_dats.c
#
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint8-one-time_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint16-one-time_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint32-one-time_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint64-one-time_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint128-one-time_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uintptr-one-time_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-size-one-time_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-usint-one-time_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint-one-time_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-ulint-one-time_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-ullint-one-time_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint64-uint64-one-time_dats.c
#
#CLEANFILES += hashmap/HATS/bits-source-include.hats
#CLEANFILES += hashmap/SATS/bits-source_sats.c
#CLEANFILES += hashmap/DATS/bits-source-uint8_dats.c
#CLEANFILES += hashmap/DATS/bits-source-uint16_dats.c
#CLEANFILES += hashmap/DATS/bits-source-uint32_dats.c
#CLEANFILES += hashmap/DATS/bits-source-uint64_dats.c
#CLEANFILES += hashmap/DATS/bits-source-uint128_dats.c
#CLEANFILES += hashmap/DATS/bits-source-uintptr_dats.c
#CLEANFILES += hashmap/DATS/bits-source-size_dats.c
#CLEANFILES += hashmap/DATS/bits-source-usint_dats.c
#CLEANFILES += hashmap/DATS/bits-source-uint_dats.c
#CLEANFILES += hashmap/DATS/bits-source-ulint_dats.c
#CLEANFILES += hashmap/DATS/bits-source-ullint_dats.c
#CLEANFILES += hashmap/DATS/bits-source-uint64-uint64_dats.c
#
#CLEANFILES += hashmap/DATS/bits-source-uint8-one-time_dats.c
#CLEANFILES += hashmap/DATS/bits-source-uint16-one-time_dats.c
#CLEANFILES += hashmap/DATS/bits-source-uint32-one-time_dats.c
#CLEANFILES += hashmap/DATS/bits-source-uint64-one-time_dats.c
#CLEANFILES += hashmap/DATS/bits-source-uint128-one-time_dats.c
#CLEANFILES += hashmap/DATS/bits-source-uintptr-one-time_dats.c
#CLEANFILES += hashmap/DATS/bits-source-size-one-time_dats.c
#CLEANFILES += hashmap/DATS/bits-source-usint-one-time_dats.c
#CLEANFILES += hashmap/DATS/bits-source-uint-one-time_dats.c
#CLEANFILES += hashmap/DATS/bits-source-ulint-one-time_dats.c
#CLEANFILES += hashmap/DATS/bits-source-ullint-one-time_dats.c
#CLEANFILES += hashmap/DATS/bits-source-uint64-uint64-one-time_dats.c
#
#CLEANFILES += hashmap/DATS/bits-source-uint8.dats
#CLEANFILES += hashmap/DATS/bits-source-uint16.dats
#CLEANFILES += hashmap/DATS/bits-source-uint32.dats
#CLEANFILES += hashmap/DATS/bits-source-uint64.dats
#CLEANFILES += hashmap/DATS/bits-source-uint128.dats
#CLEANFILES += hashmap/DATS/bits-source-uintptr.dats
#CLEANFILES += hashmap/DATS/bits-source-size.dats
#CLEANFILES += hashmap/DATS/bits-source-usint.dats
#CLEANFILES += hashmap/DATS/bits-source-uint.dats
#CLEANFILES += hashmap/DATS/bits-source-ulint.dats
#CLEANFILES += hashmap/DATS/bits-source-ullint.dats
#
#CLEANFILES += hashmap/DATS/bits-source-uint8-one-time.dats
#CLEANFILES += hashmap/DATS/bits-source-uint16-one-time.dats
#CLEANFILES += hashmap/DATS/bits-source-uint32-one-time.dats
#CLEANFILES += hashmap/DATS/bits-source-uint64-one-time.dats
#CLEANFILES += hashmap/DATS/bits-source-uint128-one-time.dats
#CLEANFILES += hashmap/DATS/bits-source-uintptr-one-time.dats
#CLEANFILES += hashmap/DATS/bits-source-size-one-time.dats
#CLEANFILES += hashmap/DATS/bits-source-usint-one-time.dats
#CLEANFILES += hashmap/DATS/bits-source-uint-one-time.dats
#CLEANFILES += hashmap/DATS/bits-source-ulint-one-time.dats
#CLEANFILES += hashmap/DATS/bits-source-ullint-one-time.dats
#CLEANFILES += hashmap/DATS/bits-source-uint64-uint64-one-time.dats
#
#CLEANFILES += hashmap/DATS/bits-source-UINTTYPE.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-uint8.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-uint16.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-uint32.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-uint64.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-uint128.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-uintptr.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-size.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-usint.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-uint.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-ulint.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-ullint.dats.m4
#
#CLEANFILES += hashmap/DATS/bits-source-uint8-one-time.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-uint16-one-time.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-uint32-one-time.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-uint64-one-time.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-uint128-one-time.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-uintptr-one-time.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-size-one-time.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-usint-one-time.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-uint-one-time.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-ulint-one-time.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-ullint-one-time.dats.m4
#CLEANFILES += hashmap/DATS/bits-source-uint64-uint64-one-time.dats.m4
#
#EXTRA_DIST += hashmap/SATS/bits-source.sats
#EXTRA_DIST += hashmap/CATS/bits-source.cats
#EXTRA_DIST += hashmap/DATS/bits-source-uint64-uint64.dats
#
#nobase_nodist_pkginclude_HEADERS += hashmap/SATS/bits-source.sats
#nobase_nodist_pkginclude_HEADERS += hashmap/HATS/bits-source-include.hats
#
#hashmap/DATS/bits-source-uint8.dats: hashmap/DATS/bits-source-uint8.dats.m4
#hashmap/DATS/bits-source-uint8.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4
#
#hashmap/DATS/bits-source-uint16.dats: hashmap/DATS/bits-source-uint16.dats.m4
#hashmap/DATS/bits-source-uint16.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4
#
#hashmap/DATS/bits-source-uint32.dats: hashmap/DATS/bits-source-uint32.dats.m4
#hashmap/DATS/bits-source-uint32.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4
#
#hashmap/DATS/bits-source-uint64.dats: hashmap/DATS/bits-source-uint64.dats.m4
#hashmap/DATS/bits-source-uint64.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4
#
#hashmap/DATS/bits-source-uint128.dats: hashmap/DATS/bits-source-uint128.dats.m4
#hashmap/DATS/bits-source-uint128.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4
#
#hashmap/DATS/bits-source-uintptr.dats: hashmap/DATS/bits-source-uintptr.dats.m4
#hashmap/DATS/bits-source-uintptr.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4
#
#hashmap/DATS/bits-source-size.dats: hashmap/DATS/bits-source-size.dats.m4
#hashmap/DATS/bits-source-size.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4
#
#hashmap/DATS/bits-source-usint.dats: hashmap/DATS/bits-source-usint.dats.m4
#hashmap/DATS/bits-source-usint.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4
#
#hashmap/DATS/bits-source-uint.dats: hashmap/DATS/bits-source-uint.dats.m4
#hashmap/DATS/bits-source-uint.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4
#
#hashmap/DATS/bits-source-ulint.dats: hashmap/DATS/bits-source-ulint.dats.m4
#hashmap/DATS/bits-source-ulint.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4
#
#hashmap/DATS/bits-source-ullint.dats: hashmap/DATS/bits-source-ullint.dats.m4
#hashmap/DATS/bits-source-ullint.dats: hashmap/DATS/bits-source-UINTTYPE.dats.m4
#
#hashmap/DATS/bits-source-uint8-one-time.dats: hashmap/DATS/bits-source-uint8-one-time.dats.m4
#hashmap/DATS/bits-source-uint8-one-time.dats: hashmap/DATS/bits-source-TYPE-one-time.dats.m4
#
#hashmap/DATS/bits-source-uint16-one-time.dats: hashmap/DATS/bits-source-uint16-one-time.dats.m4
#hashmap/DATS/bits-source-uint16-one-time.dats: hashmap/DATS/bits-source-TYPE-one-time.dats.m4
#
#hashmap/DATS/bits-source-uint32-one-time.dats: hashmap/DATS/bits-source-uint32-one-time.dats.m4
#hashmap/DATS/bits-source-uint32-one-time.dats: hashmap/DATS/bits-source-TYPE-one-time.dats.m4
#
#hashmap/DATS/bits-source-uint64-one-time.dats: hashmap/DATS/bits-source-uint64-one-time.dats.m4
#hashmap/DATS/bits-source-uint64-one-time.dats: hashmap/DATS/bits-source-TYPE-one-time.dats.m4
#
#hashmap/DATS/bits-source-uint128-one-time.dats: hashmap/DATS/bits-source-uint128-one-time.dats.m4
#hashmap/DATS/bits-source-uint128-one-time.dats: hashmap/DATS/bits-source-TYPE-one-time.dats.m4
#
#hashmap/DATS/bits-source-uintptr-one-time.dats: hashmap/DATS/bits-source-uintptr-one-time.dats.m4
#hashmap/DATS/bits-source-uintptr-one-time.dats: hashmap/DATS/bits-source-TYPE-one-time.dats.m4
#
#hashmap/DATS/bits-source-size-one-time.dats: hashmap/DATS/bits-source-size-one-time.dats.m4
#hashmap/DATS/bits-source-size-one-time.dats: hashmap/DATS/bits-source-TYPE-one-time.dats.m4
#
#hashmap/DATS/bits-source-usint-one-time.dats: hashmap/DATS/bits-source-usint-one-time.dats.m4
#hashmap/DATS/bits-source-usint-one-time.dats: hashmap/DATS/bits-source-TYPE-one-time.dats.m4
#
#hashmap/DATS/bits-source-uint-one-time.dats: hashmap/DATS/bits-source-uint-one-time.dats.m4
#hashmap/DATS/bits-source-uint-one-time.dats: hashmap/DATS/bits-source-TYPE-one-time.dats.m4
#
#hashmap/DATS/bits-source-ulint-one-time.dats: hashmap/DATS/bits-source-ulint-one-time.dats.m4
#hashmap/DATS/bits-source-ulint-one-time.dats: hashmap/DATS/bits-source-TYPE-one-time.dats.m4
#
#hashmap/DATS/bits-source-ullint-one-time.dats: hashmap/DATS/bits-source-ullint-one-time.dats.m4
#hashmap/DATS/bits-source-ullint-one-time.dats: hashmap/DATS/bits-source-TYPE-one-time.dats.m4
#
#hashmap/DATS/bits-source-uint64-uint64-one-time.dats: hashmap/DATS/bits-source-uint64-uint64-one-time.dats.m4
#hashmap/DATS/bits-source-uint64-uint64-one-time.dats: hashmap/DATS/bits-source-TYPE-one-time.dats.m4
#
#libats2_hashmap_la_SOURCES += hashmap/SATS/array-mapped-tree_sats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/array-mapped-tree-free_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/array-mapped-tree-create_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/array-mapped-tree-set-entry_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/array-mapped-tree-get-entry_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/array-mapped-tree-to-list-vt_dats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/array-mapped-tree-print-structure_dats.c
#libats2_hashmap_la_SOURCES += hashmap/SATS/array-mapped-tree-templates_sats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/array-mapped-tree-templates_dats.c
#libats2_hashmap_la_SOURCES += hashmap/SATS/array-mapped-tree-print-subtree-structure_sats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/array-mapped-tree-print-subtree-structure_dats.c
#libats2_hashmap_la_SOURCES += hashmap/SATS/array-mapped-tree-node-vt-free_sats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/array-mapped-tree-node-vt-free_dats.c
#libats2_hashmap_la_SOURCES += hashmap/SATS/array-mapped-tree-subtree-to-list-vt_sats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/array-mapped-tree-subtree-to-list-vt_dats.c
#
#CLEANFILES += hashmap/SATS/array-mapped-tree_sats.c
#CLEANFILES += hashmap/DATS/array-mapped-tree-free_dats.c
#CLEANFILES += hashmap/DATS/array-mapped-tree-create_dats.c
#CLEANFILES += hashmap/DATS/array-mapped-tree-set-entry_dats.c
#CLEANFILES += hashmap/DATS/array-mapped-tree-get-entry_dats.c
#CLEANFILES += hashmap/DATS/array-mapped-tree-to-list-vt_dats.c
#CLEANFILES += hashmap/DATS/array-mapped-tree-print-structure_dats.c
#CLEANFILES += hashmap/SATS/array-mapped-tree-templates_sats.c
#CLEANFILES += hashmap/DATS/array-mapped-tree-templates_dats.c
#CLEANFILES += hashmap/SATS/array-mapped-tree-print-subtree-structure_sats.c
#CLEANFILES += hashmap/DATS/array-mapped-tree-print-subtree-structure_dats.c
#CLEANFILES += hashmap/SATS/array-mapped-tree-node-vt-free_sats.c
#CLEANFILES += hashmap/DATS/array-mapped-tree-node-vt-free_dats.c
#CLEANFILES += hashmap/SATS/array-mapped-tree-subtree-to-list-vt_sats.c
#CLEANFILES += hashmap/DATS/array-mapped-tree-subtree-to-list-vt_dats.c
#
#EXTRA_DIST += hashmap/HATS/array-mapped-tree-helpers.hats
#EXTRA_DIST += hashmap/CATS/node-alloc-count.cats
#EXTRA_DIST += hashmap/SATS/array-mapped-tree.sats
#EXTRA_DIST += hashmap/DATS/array-mapped-tree-free.dats
#EXTRA_DIST += hashmap/DATS/array-mapped-tree-create.dats
#EXTRA_DIST += hashmap/DATS/array-mapped-tree-set-entry.dats
#EXTRA_DIST += hashmap/DATS/array-mapped-tree-get-entry.dats
#EXTRA_DIST += hashmap/DATS/array-mapped-tree-to-list-vt.dats
#EXTRA_DIST += hashmap/DATS/array-mapped-tree-print-structure.dats
#EXTRA_DIST += hashmap/SATS/array-mapped-tree-templates.sats
#EXTRA_DIST += hashmap/DATS/array-mapped-tree-templates.dats
#EXTRA_DIST += hashmap/SATS/array-mapped-tree-print-subtree-structure.sats
#EXTRA_DIST += hashmap/DATS/array-mapped-tree-print-subtree-structure.dats
#EXTRA_DIST += hashmap/SATS/array-mapped-tree-node-vt-free.sats
#EXTRA_DIST += hashmap/DATS/array-mapped-tree-node-vt-free.dats
#EXTRA_DIST += hashmap/SATS/array-mapped-tree-subtree-to-list-vt.sats
#EXTRA_DIST += hashmap/DATS/array-mapped-tree-subtree-to-list-vt.dats
#
#libats2_hashmap_la_SOURCES += hashmap/SATS/uintptr-set_sats.c
#libats2_hashmap_la_SOURCES += hashmap/DATS/uintptr-set_dats.c
#CLEANFILES += hashmap/SATS/uintptr-set_sats.c
#CLEANFILES += hashmap/DATS/uintptr-set_dats.c
#EXTRA_DIST += hashmap/SATS/uintptr-set.sats
#EXTRA_DIST += hashmap/DATS/uintptr-set.dats
#EXTRA_DIST += hashmap/CATS/uintptr-set-implementation.cats
#nobase_nodist_pkginclude_HEADERS += hashmap/SATS/uintptr-set.sats
#nobase_nodist_pkginclude_HEADERS += hashmap/DATS/uintptr-set.dats
#nobase_nodist_pkginclude_HEADERS += hashmap/CATS/uintptr-set-implementation.cats

libats2_hashmap_la_SOURCES += hashmap/SATS/hashmap_sats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/hashmap_dats.c
CLEANFILES += hashmap/SATS/hashmap_sats.c
CLEANFILES += hashmap/DATS/hashmap_dats.c
nobase_dist_pkginclude_HEADERS += hashmap/SATS/hashmap.sats
nobase_dist_pkginclude_HEADERS += hashmap/DATS/hashmap.dats

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

#check_PROGRAMS += tests/test-bits-source-uint16
#tests_test_bits_source_uint16_SOURCES = tests/test-bits-source-uint16_dats.c
#tests_test_bits_source_uint16_LDADD = $(lib_LTLIBRARIES)
#EXTRA_DIST += tests/test-bits-source-uint16.dats
#CLEANFILES += tests/test-bits-source-uint16
#CLEANFILES += tests/test-bits-source-uint16_dats.c
#
#check_PROGRAMS += tests/test-bits-source-uint32
#tests_test_bits_source_uint32_SOURCES = tests/test-bits-source-uint32_dats.c
#tests_test_bits_source_uint32_LDADD = $(lib_LTLIBRARIES)
#EXTRA_DIST += tests/test-bits-source-uint32.dats
#CLEANFILES += tests/test-bits-source-uint32
#CLEANFILES += tests/test-bits-source-uint32_dats.c
#
#check_PROGRAMS += tests/test-bits-source-uint64
#tests_test_bits_source_uint64_SOURCES = tests/test-bits-source-uint64_dats.c
#tests_test_bits_source_uint64_LDADD = $(lib_LTLIBRARIES)
#EXTRA_DIST += tests/test-bits-source-uint64.dats
#CLEANFILES += tests/test-bits-source-uint64
#CLEANFILES += tests/test-bits-source-uint64_dats.c
#
#check_PROGRAMS += tests/test-bits-source-uint64-uint64
#tests_test_bits_source_uint64_uint64_SOURCES = tests/test-bits-source-uint64-uint64_dats.c
#tests_test_bits_source_uint64_uint64_LDADD = $(lib_LTLIBRARIES)
#CLEANFILES += tests/test-bits-source-uint64-uint64.dats
#CLEANFILES += tests/test-bits-source-uint64-uint64
#CLEANFILES += tests/test-bits-source-uint64-uint64_dats.c
#
#if UINTPTR_IS_UINT64
#check_PROGRAMS += tests/test-bits-source-uintptr
#tests_test_bits_source_uintptr_SOURCES = tests/test-bits-source-uintptr_dats.c
#tests_test_bits_source_uintptr_LDADD = $(lib_LTLIBRARIES)
#EXTRA_DIST += tests/test-bits-source-uintptr.dats
#CLEANFILES += tests/test-bits-source-uintptr
#CLEANFILES += tests/test-bits-source-uintptr_dats.c
#endif UINTPTR_IS_UINT64
#
#check_PROGRAMS += tests/test-bswap
#tests_test_bswap_SOURCES = tests/test-bswap_dats.c
#tests_test_bswap_LDADD = $(lib_LTLIBRARIES)
#EXTRA_DIST += tests/test-bswap.dats
#CLEANFILES += tests/test-bswap
#CLEANFILES += tests/test-bswap_dats.c
#
#check_PROGRAMS += tests/test-bswap-on-little-endian
#tests_test_bswap_on_little_endian_SOURCES = tests/test-bswap-on-little-endian_dats.c
#tests_test_bswap_on_little_endian_LDADD = $(lib_LTLIBRARIES)
#EXTRA_DIST += tests/test-bswap-on-little-endian.dats
#CLEANFILES += tests/test-bswap-on-little-endian
#CLEANFILES += tests/test-bswap-on-little-endian_dats.c
#
#check_PROGRAMS += tests/test-bswap-on-big-endian
#tests_test_bswap_on_big_endian_SOURCES = tests/test-bswap-on-big-endian_dats.c
#tests_test_bswap_on_big_endian_LDADD = $(lib_LTLIBRARIES)
#EXTRA_DIST += tests/test-bswap-on-big-endian.dats
#CLEANFILES += tests/test-bswap-on-big-endian
#CLEANFILES += tests/test-bswap-on-big-endian_dats.c
#
#check_PROGRAMS += tests/test-uintptr-set
#tests_test_uintptr_set_SOURCES = tests/test-uintptr-set_dats.c
#tests_test_uintptr_set_LDADD = $(lib_LTLIBRARIES)
#EXTRA_DIST += tests/test-uintptr-set.dats
#CLEANFILES += tests/test-uintptr-set
#CLEANFILES += tests/test-uintptr-set_dats.c
#
#.PHONY: structure-test-clean
#structure-test-clean:
#	-rm -f tests/*.structure

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
