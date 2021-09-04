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
@GNU@ include $(top_srcdir)/silent-rules.mk
@GNU@ -include ats-dependencies/*.mk

EXTRA_DIST =
MOSTLYCLEANFILES =
CLEANFILES =
DISTCLEANFILES =
BUILT_SOURCES =
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

clean-local: code-coverage-clean # tests-clean
distclean-local: code-coverage-dist-clean ats-includes-distclean

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

PATSOPT_DEPS =

#DATS_SIZEOF_UINTPTR_T := \
#	$(shell echo x $(DEFS) | \
#		$(EGREP) -e '[[:space:]]-DSIZEOF_UINTPTR_T=([[:digit:]]+)([[:space:]]|$$)?' | \
#			$(SED) -e 's|^.*[ 	]-DSIZEOF_UINTPTR_T=||' \
#			       -e 's|^\([0-9][0-9]*\).*|-DATS SIZEOF_UINTPTR=\1|')

AM_PATSOPTFLAGS =
#AM_PATSOPTFLAGS += $(DATS_SIZEOF_UINTPTR_T)
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

.PHONY: ats-includes-distclean
ats-includes-distclean:
	-rm -f -R ats-dependencies

if DEPENDENCY_TRACKING

%_sats.c: %.sats $(PATSOPT_DEPS) list-ats-dependencies
	@$(call write-dependencies-file,$(@),$(<))
	@$(MKDIR_P) $(@D)
	$(call v,PATSOPT)$(PATSOPT) -o $(@) $(TOTAL_PATSOPTFLAGS) -s $(<)

%_dats.c: %.dats $(PATSOPT_DEPS) list-ats-dependencies
	@$(call write-dependencies-file,$(@),$(<))
	@$(MKDIR_P) $(@D)
	$(call v,PATSOPT)$(PATSOPT) -o $(@) $(TOTAL_PATSOPTFLAGS) -d $(<)

%_tests.c: %.dats $(PATSOPT_DEPS) list-ats-dependencies
	@$(call write-dependencies-file,$(@),$(<))
	@$(MKDIR_P) $(@D)
	$(call v,PATSOPT)$(PATSOPT) -o $(@) $(TOTAL_PATSOPTFLAGS) \
			$(TESTS_PATSOPTFLAGS) -d $(<)

else !DEPENDENCY_TRACKING

%_sats.c: %.sats $(PATSOPT_DEPS)
	@$(MKDIR_P) $(@D)
	$(call v,PATSOPT)$(PATSOPT) -o $(@) $(TOTAL_PATSOPTFLAGS) -s $(<)

%_dats.c: %.dats $(PATSOPT_DEPS)
	@$(MKDIR_P) $(@D)
	$(call v,PATSOPT)$(PATSOPT) -o $(@) $(TOTAL_PATSOPTFLAGS) -d $(<)

%_tests.c: %.dats $(PATSOPT_DEPS)
	@$(MKDIR_P) $(@D)
	$(call v,PATSOPT)$(PATSOPT) -o $(@) $(TOTAL_PATSOPTFLAGS) \
			$(TESTS_PATSOPTFLAGS) -d $(<)

endif !DEPENDENCY_TRACKING

%_depsprog.c: %.dats $(PATSOPT_DEPS)
	@$(MKDIR_P) $(@D)
	$(call v,PATSOPT)$(PATSOPT) -o $(@) $(TOTAL_PATSOPTFLAGS) -d $(<)

#--------------------------------------------------------------------------
#
# The ATS2 library.
#

lib_LTLIBRARIES += libats2-hashmap.la

libats2_hashmap_la_SOURCES =
libats2_hashmap_la_DEPENDENCIES =
libats2_hashmap_la_LIBADD =

libats2_hashmap_la_DEPENDENCIES += hashmap/HATS/config.hats
libats2_hashmap_la_DEPENDENCIES += hashmap/HATS/config.hats.in
hashmap/HATS/config.hats: hashmap/HATS/config.hats.in

libats2_hashmap_la_SOURCES += hashmap/SATS/hashmap_sats.c
CLEANFILES += hashmap/SATS/hashmap_sats.c
EXTRA_DIST += hashmap/SATS/hashmap.sats
nobase_nodist_pkginclude_HEADERS += hashmap/SATS/hashmap.sats

libats2_hashmap_la_SOURCES += hashmap/SATS/count-one-bits_sats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/count-one-bits_dats.c
CLEANFILES += hashmap/SATS/count-one-bits_sats.c
CLEANFILES += hashmap/DATS/count-one-bits_dats.c
EXTRA_DIST += hashmap/SATS/count-one-bits.sats
EXTRA_DIST += hashmap/CATS/count-one-bits.cats
EXTRA_DIST += hashmap/DATS/count-one-bits.dats

libats2_hashmap_la_SOURCES += hashmap/SATS/bits-source_sats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-check-mask_dats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/bits-source-uint32_dats.c
libats2_hashmap_la_DEPENDENCIES += hashmap/HATS/bits-source-include.hats.in
CLEANFILES += hashmap/HATS/bits-source-include.hats
CLEANFILES += hashmap/SATS/bits-source_sats.c
CLEANFILES += hashmap/DATS/bits-source-check-mask_dats.c
CLEANFILES += hashmap/DATS/bits-source-uint32_dats.c
EXTRA_DIST += hashmap/SATS/bits-source.sats
EXTRA_DIST += hashmap/DATS/bits-source-check-mask.dats
EXTRA_DIST += hashmap/DATS/bits-source-uint32.dats
nobase_nodist_pkginclude_HEADERS += hashmap/SATS/bits-source.sats
nobase_nodist_pkginclude_HEADERS += hashmap/HATS/bits-source-include.hats

libats2_hashmap_la_SOURCES += hashmap/SATS/structure_sats.c
libats2_hashmap_la_SOURCES += hashmap/DATS/structure_dats.c
CLEANFILES += hashmap/SATS/structure_sats.c
CLEANFILES += hashmap/DATS/structure_dats.c
EXTRA_DIST += hashmap/SATS/structure.sats
EXTRA_DIST += hashmap/DATS/structure.dats

#--------------------------------------------------------------------------
#
# Tests.
#

AM_DEFAULT_SOURCE_EXT = _dats.c

TESTS += $(check_PROGRAMS)

check_PROGRAMS =

TESTS_CPPFLAGS =
TESTS_CPPFLAGS += $(AM_CPPFLAGS)
TESTS_CPPFLAGS += -DATS_MEMALLOC_LIBC

TESTS_LDADD =
TESTS_LDADD += $(lib_LTLIBRARIES)

check_PROGRAMS += tests/test-bits-source-uint32
CLEANFILES += tests/test-bits-source-uint32
CLEANFILES += tests/test-bits-source-uint32_dats.c
tests_test_bits_source_uint32_CPPFLAGS = $(TESTS_CPPFLAGS)
tests_test_bits_source_uint32_LDADD = $(TESTS_LDADD)

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
