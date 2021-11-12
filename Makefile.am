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

AM_CPPFLAGS += -I$(builddir)
AM_CPPFLAGS += -I$(srcdir)
AM_CPPFLAGS += -I$(builddir)/lib
AM_CPPFLAGS += -I$(srcdir)/lib
AM_CPPFLAGS += -I$(PATSHOME)
AM_CPPFLAGS += -I$(PATSHOME)/ccomp/runtime/

# Leave out runtime support in tests. We will supply it.
AM_CPPFLAGS += -D_ATS_CCOMP_RUNTIME_NONE_

AM_CFLAGS += $(ATS2_POPCOUNT_CFLAGS)
if WITH_ATS2_SPOOKYHASH
AM_CFLAGS += $(ATS2_SPOOKYHASH_CFLAGS)
endif WITH_ATS2_SPOOKYHASH
if WITH_ATS2_MURMURHASH3
AM_CFLAGS += $(ATS2_MURMURHASH3_CFLAGS)
endif WITH_ATS2_MURMURHASH3
if WITH_ATS2_SIPHASH
AM_CFLAGS += $(ATS2_SIPHASH_CFLAGS)
endif WITH_ATS2_SIPHASH

clean-local: ats-includes-clean
clean-local: bits_source_bytes_clean
clean-local: libs-clean
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

@GNU@ define make-extern-inline =
@GNU@	$(call v,M4)$(M4) $(TOTAL_M4FLAGS) -DEXTERN_INLINE='$(1)'
@GNU@ endef

#--------------------------------------------------------------------------

PATSOPT_DEPS =
PATSCC_DEPS =

AM_PATSOPTFLAGS =
AM_PATSOPTFLAGS += -IATS $(builddir)
AM_PATSOPTFLAGS += -IATS $(srcdir)
AM_PATSOPTFLAGS += $(ATS2_POPCOUNT_PATSOPTFLAGS)
if WITH_ATS2_SPOOKYHASH
AM_PATSOPTFLAGS += $(ATS2_SPOOKYHASH_PATSOPTFLAGS)
endif WITH_ATS2_SPOOKYHASH
if WITH_ATS2_MURMURHASH3
AM_PATSOPTFLAGS += $(ATS2_MURMURHASH3_PATSOPTFLAGS)
endif WITH_ATS2_MURMURHASH3
if WITH_ATS2_SIPHASH
AM_PATSOPTFLAGS += $(ATS2_SIPHASH_PATSOPTFLAGS)
endif WITH_ATS2_SIPHASH

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

nodist_libats2_hashmap_la_SOURCES =
libats2_hashmap_la_DEPENDENCIES =
libats2_hashmap_la_LIBADD =

libats2_hashmap_la_LIBADD += $(ATS2_POPCOUNT_LIBS)
if WITH_ATS2_SPOOKYHASH
libats2_hashmap_la_LIBADD += $(ATS2_SPOOKYHASH_LIBS)
endif WITH_ATS2_SPOOKYHASH
if WITH_ATS2_MURMURHASH3
libats2_hashmap_la_LIBADD += $(ATS2_MURMURHASH3_LIBS)
endif WITH_ATS2_MURMURHASH3
if WITH_ATS2_SIPHASH
libats2_hashmap_la_LIBADD += $(ATS2_SIPHASH_LIBS)
endif WITH_ATS2_SIPHASH

nodist_libats2_hashmap_la_SOURCES += hashmap/SATS/array-proofs_sats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/array-proofs_dats.c
nobase_nodist_pkginclude_HEADERS += hashmap/SATS/array-proofs.sats
nobase_nodist_pkginclude_HEADERS += hashmap/DATS/array-proofs.dats

nodist_libats2_hashmap_la_SOURCES += hashmap/SATS/memory_sats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/memory_dats.c
nobase_nodist_pkginclude_HEADERS += hashmap/SATS/memory.sats
nobase_nodist_pkginclude_HEADERS += hashmap/DATS/memory.dats
nobase_nodist_pkginclude_HEADERS += hashmap/CATS/memory.cats

nodist_libats2_hashmap_la_SOURCES += hashmap/SATS/bits_source-parameters_sats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/SATS/bits_source_sats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_uint8_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_uint16_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_uint32_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_uint64_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_uint64_uint64_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_nbytes_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_1byte_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_2bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_3bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_4bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_5bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_6bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_7bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_8bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_9bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_10bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_11bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_12bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_13bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_14bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_15bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_16bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_17bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_18bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_19bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_20bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_21bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_22bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_23bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_24bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_25bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_26bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_27bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_28bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_29bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_30bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_31bytes_implementation_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/bits_source_32bytes_implementation_dats.c
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
CLEANFILES += hashmap/DATS/bits_source_uint8.dats
CLEANFILES += hashmap/DATS/bits_source_uint16.dats
CLEANFILES += hashmap/DATS/bits_source_uint32.dats
CLEANFILES += hashmap/DATS/bits_source_uint64.dats
CLEANFILES += hashmap/DATS/bits_source_uint64_uint64.dats

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
	-rm -f hashmap/DATS/bits_source_1byte_implementation.dats
	-rm -f hashmap/DATS/bits_source_*bytes_implementation.dats

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

nodist_libats2_hashmap_la_SOURCES += hashmap/SATS/population_map_sats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/population_map_dats.c
nobase_dist_pkginclude_HEADERS += hashmap/SATS/population_map.sats
nobase_dist_pkginclude_HEADERS += hashmap/DATS/population_map.dats

nodist_libats2_hashmap_la_SOURCES += hashmap/SATS/hashmap_sats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/hashmap_dats.c
nobase_dist_pkginclude_HEADERS += hashmap/SATS/hashmap.sats
nobase_dist_pkginclude_HEADERS += hashmap/DATS/hashmap.dats
nobase_dist_pkginclude_HEADERS += hashmap/HATS/hashmap.hats

nodist_libats2_hashmap_la_SOURCES += hashmap/SATS/strnptrmap_sats.c
nobase_dist_pkginclude_HEADERS += hashmap/SATS/strnptrmap.sats

EXTRA_DIST += hashmap/DATS/INCLUDE/strnptrmap-implementations.dats
if WITH_STRNPTRMAP
nobase_nodist_pkginclude_HEADERS += hashmap/DATS/INCLUDE/strnptrmap-implementations.dats
endif WITH_STRNPTRMAP

if WITH_SPOOKYHASH
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/strnptrmap-spookyhash_dats.c
nobase_nodist_pkginclude_HEADERS += hashmap/DATS/strnptrmap-spookyhash.dats
nobase_nodist_pkginclude_HEADERS += hashmap/HATS/strnptrmap-spookyhash.hats
endif WITH_SPOOKYHASH
EXTRA_DIST += hashmap/DATS/strnptrmap-spookyhash.dats
EXTRA_DIST += hashmap/HATS/strnptrmap-spookyhash.hats

if WITH_MURMURHASH3_32
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/strnptrmap-murmurhash3_32_dats.c
nobase_nodist_pkginclude_HEADERS += hashmap/DATS/strnptrmap-murmurhash3_32.dats
nobase_nodist_pkginclude_HEADERS += hashmap/HATS/strnptrmap-murmurhash3_32.hats
endif WITH_MURMURHASH3_32
EXTRA_DIST += hashmap/DATS/strnptrmap-murmurhash3_32.dats
EXTRA_DIST += hashmap/HATS/strnptrmap-murmurhash3_32.hats

if WITH_HALFSIPHASH_32
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/strnptrmap-halfsiphash_32_dats.c
nobase_nodist_pkginclude_HEADERS += hashmap/DATS/strnptrmap-halfsiphash_32.dats
nobase_nodist_pkginclude_HEADERS += hashmap/HATS/strnptrmap-halfsiphash_32.hats
endif WITH_HALFSIPHASH_32
EXTRA_DIST += hashmap/DATS/strnptrmap-halfsiphash_32.dats
EXTRA_DIST += hashmap/HATS/strnptrmap-halfsiphash_32.hats

if WITH_HALFSIPHASH_64
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/strnptrmap-halfsiphash_64_dats.c
nobase_nodist_pkginclude_HEADERS += hashmap/DATS/strnptrmap-halfsiphash_64.dats
nobase_nodist_pkginclude_HEADERS += hashmap/HATS/strnptrmap-halfsiphash_64.hats
endif WITH_HALFSIPHASH_64
EXTRA_DIST += hashmap/DATS/strnptrmap-halfsiphash_64.dats
EXTRA_DIST += hashmap/HATS/strnptrmap-halfsiphash_64.hats

if WITH_SIPHASH_64
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/strnptrmap-siphash_64_dats.c
nobase_nodist_pkginclude_HEADERS += hashmap/DATS/strnptrmap-siphash_64.dats
nobase_nodist_pkginclude_HEADERS += hashmap/HATS/strnptrmap-siphash_64.hats
endif WITH_SIPHASH_64
EXTRA_DIST += hashmap/DATS/strnptrmap-siphash_64.dats
EXTRA_DIST += hashmap/HATS/strnptrmap-siphash_64.hats

if WITH_SIPHASH_128
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/strnptrmap-siphash_128_dats.c
nobase_nodist_pkginclude_HEADERS += hashmap/DATS/strnptrmap-siphash_128.dats
nobase_nodist_pkginclude_HEADERS += hashmap/HATS/strnptrmap-siphash_128.hats
endif WITH_SIPHASH_128
EXTRA_DIST += hashmap/DATS/strnptrmap-siphash_128.dats
EXTRA_DIST += hashmap/HATS/strnptrmap-siphash_128.hats

if WITH_DEFAULT_HASH_SPOOKYHASH
hashmap/HATS/strnptrmap-dats.hats: GNUmakefile
	@$(MKDIR_P) $(@D)
	$(call v,GEN)echo 'staload _ = "hashmap/DATS/strnptrmap-spookyhash.dats"' > $(@)
endif WITH_DEFAULT_HASH_SPOOKYHASH
if WITH_DEFAULT_HASH_MURMURHASH3_32
hashmap/HATS/strnptrmap-dats.hats: GNUmakefile
	@$(MKDIR_P) $(@D)
	$(call v,GEN)echo 'staload _ = "hashmap/DATS/strnptrmap-murmurhash3_32.dats"' > $(@)
endif WITH_DEFAULT_HASH_MURMURHASH3_32
if WITH_DEFAULT_HASH_HALFSIPHASH_32
hashmap/HATS/strnptrmap-dats.hats: GNUmakefile
	@$(MKDIR_P) $(@D)
	$(call v,GEN)echo 'staload _ = "hashmap/DATS/strnptrmap-halfsiphash_32.dats"' > $(@)
endif WITH_DEFAULT_HASH_HALFSIPHASH_32
if WITH_DEFAULT_HASH_HALFSIPHASH_64
hashmap/HATS/strnptrmap-dats.hats: GNUmakefile
	@$(MKDIR_P) $(@D)
	$(call v,GEN)echo 'staload _ = "hashmap/DATS/strnptrmap-halfsiphash_64.dats"' > $(@)
endif WITH_DEFAULT_HASH_HALFSIPHASH_64
if WITH_DEFAULT_HASH_SIPHASH_64
hashmap/HATS/strnptrmap-dats.hats: GNUmakefile
	@$(MKDIR_P) $(@D)
	$(call v,GEN)echo 'staload _ = "hashmap/DATS/strnptrmap-siphash_64.dats"' > $(@)
endif WITH_DEFAULT_HASH_SIPHASH_64
if WITH_DEFAULT_HASH_SIPHASH_128
hashmap/HATS/strnptrmap-dats.hats: GNUmakefile
	@$(MKDIR_P) $(@D)
	$(call v,GEN)echo 'staload _ = "hashmap/DATS/strnptrmap-siphash_128.dats"' > $(@)
endif WITH_DEFAULT_HASH_SIPHASH_128
if WITH_DEFAULT_HASH
nobase_nodist_pkginclude_HEADERS += hashmap/HATS/strnptrmap.hats
nobase_nodist_pkginclude_HEADERS += hashmap/HATS/strnptrmap-dats.hats
endif WITH_DEFAULT_HASH
EXTRA_DIST += hashmap/HATS/strnptrmap.hats
CLEANFILES += hashmap/HATS/strnptrmap-dats.hats

nodist_libats2_hashmap_la_SOURCES += hashmap/SATS/strnptr2uintptrmap_sats.c
nobase_dist_pkginclude_HEADERS += hashmap/SATS/strnptr2uintptrmap.sats
if WITH_DEFAULT_HASH
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/strnptr2uintptrmap_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/strnptr2uintptrmap_size_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/strnptr2uintptrmap_set_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/strnptr2uintptrmap_del_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/strnptr2uintptrmap_get_opt_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/strnptr2uintptrmap_has_key_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/strnptr2uintptrmap_pairs_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/strnptr2uintptrmap_keys_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/strnptr2uintptrmap_values_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/strnptr2uintptrmap_free_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/string2uintptrmap_get_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/string2uintptrmap_has_key_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/string2uintptrmap_EXTERN_INLINE_string2uintptrmap_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/string2uintptrmap_EXTERN_INLINE_is_empty_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/string2uintptrmap_EXTERN_INLINE_isnot_empty_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/string2uintptrmap_EXTERN_INLINE_size_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/string2uintptrmap_EXTERN_INLINE_set_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/string2uintptrmap_EXTERN_INLINE_del_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/string2uintptrmap_EXTERN_INLINE_pairs_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/string2uintptrmap_EXTERN_INLINE_pairs_free_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/string2uintptrmap_EXTERN_INLINE_keys_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/string2uintptrmap_EXTERN_INLINE_keys_free_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/string2uintptrmap_EXTERN_INLINE_values_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/string2uintptrmap_EXTERN_INLINE_values_free_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/string2uintptrmap_EXTERN_INLINE_free_dats.c
nobase_nodist_pkginclude_HEADERS += hashmap/DATS/strnptr2uintptrmap.dats
nobase_nodist_pkginclude_HEADERS += hashmap/HATS/strnptr2uintptrmap.hats
nobase_nodist_pkginclude_HEADERS += hashmap/string2uintptrmap.h
endif WITH_DEFAULT_HASH
EXTRA_DIST += hashmap/DATS/strnptr2uintptrmap.dats
EXTRA_DIST += hashmap/HATS/strnptr2uintptrmap.hats
EXTRA_DIST += hashmap/DATS/strnptr2uintptrmap_size.dats
EXTRA_DIST += hashmap/DATS/strnptr2uintptrmap_set.dats
EXTRA_DIST += hashmap/DATS/strnptr2uintptrmap_del.dats
EXTRA_DIST += hashmap/DATS/strnptr2uintptrmap_get_opt.dats
EXTRA_DIST += hashmap/DATS/strnptr2uintptrmap_has_key.dats
EXTRA_DIST += hashmap/DATS/strnptr2uintptrmap_pairs.dats
EXTRA_DIST += hashmap/DATS/strnptr2uintptrmap_keys.dats
EXTRA_DIST += hashmap/DATS/strnptr2uintptrmap_values.dats
EXTRA_DIST += hashmap/DATS/strnptr2uintptrmap_free.dats
EXTRA_DIST += hashmap/DATS/string2uintptrmap_get.dats
EXTRA_DIST += hashmap/DATS/string2uintptrmap_has_key.dats
EXTRA_DIST += hashmap/DATS/string2uintptrmap_extern_inline.dats.m4
EXTRA_DIST += hashmap/string2uintptrmap.h
include string2uintptrmap_extern_inline.am

nodist_libats2_hashmap_la_SOURCES += hashmap/SATS/strnptrset_sats.c
nobase_dist_pkginclude_HEADERS += hashmap/SATS/strnptrset.sats
if WITH_DEFAULT_HASH
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/strnptrset_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/stringset_EXTERN_INLINE_stringset_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/stringset_EXTERN_INLINE_is_empty_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/stringset_EXTERN_INLINE_isnot_empty_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/stringset_EXTERN_INLINE_size_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/stringset_EXTERN_INLINE_add_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/stringset_EXTERN_INLINE_del_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/stringset_EXTERN_INLINE_contains_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/stringset_EXTERN_INLINE_elements_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/stringset_EXTERN_INLINE_elements_free_dats.c
nodist_libats2_hashmap_la_SOURCES += hashmap/DATS/stringset_EXTERN_INLINE_free_dats.c
nobase_nodist_pkginclude_HEADERS += hashmap/DATS/strnptrset.dats
nobase_nodist_pkginclude_HEADERS += hashmap/HATS/strnptrset.hats
nobase_nodist_pkginclude_HEADERS += hashmap/stringset.h
endif WITH_DEFAULT_HASH
EXTRA_DIST += hashmap/DATS/strnptrset.dats
EXTRA_DIST += hashmap/HATS/strnptrset.hats
EXTRA_DIST += hashmap/DATS/stringset_extern_inline.dats.m4
EXTRA_DIST += hashmap/stringset.h
include stringset_extern_inline.am

.PHONY: libs-clean
libs-clean:
	-rm -f hashmap/SATS/*_sats.c
	-rm -f hashmap/SATS/*_sats.$(OBJEXT)
	-rm -f hashmap/DATS/*_dats.c
	-rm -f hashmap/DATS/*_dats.$(OBJEXT)
	-rm -f hashmap/DATS/string2uintptrmap_EXTERN_INLINE_*.dats
	-rm -f hashmap/DATS/stringset_EXTERN_INLINE_*.dats

#--------------------------------------------------------------------------
#
# Tests.
#

TESTS += $(check_PROGRAMS)

EXTRA_DIST += tests/INCLUDE/runtime-support.dats
EXTRA_DIST += tests/INCLUDE/test-strnptr2strnptr-map.dats

check_PROGRAMS =

check_PROGRAMS += tests/test-bits_source_uint8
nodist_tests_test_bits_source_uint8_SOURCES = tests/test-bits_source_uint8_dats.c
tests_test_bits_source_uint8_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-bits_source_uint8.dats
CLEANFILES += tests/test-bits_source_uint8

check_PROGRAMS += tests/test-bits_source_uint16
nodist_tests_test_bits_source_uint16_SOURCES = tests/test-bits_source_uint16_dats.c
tests_test_bits_source_uint16_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-bits_source_uint16.dats
CLEANFILES += tests/test-bits_source_uint16

check_PROGRAMS += tests/test-bits_source_uint32
nodist_tests_test_bits_source_uint32_SOURCES = tests/test-bits_source_uint32_dats.c
tests_test_bits_source_uint32_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-bits_source_uint32.dats
CLEANFILES += tests/test-bits_source_uint32

check_PROGRAMS += tests/test-bits_source_uint64
nodist_tests_test_bits_source_uint64_SOURCES = tests/test-bits_source_uint64_dats.c
tests_test_bits_source_uint64_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-bits_source_uint64.dats
CLEANFILES += tests/test-bits_source_uint64

check_PROGRAMS += tests/test-bits_source_uint64_uint64
nodist_tests_test_bits_source_uint64_uint64_SOURCES = tests/test-bits_source_uint64_uint64_dats.c
tests_test_bits_source_uint64_uint64_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-bits_source_uint64_uint64.dats
CLEANFILES += tests/test-bits_source_uint64_uint64

check_PROGRAMS += tests/test-bits_source_1byte
nodist_tests_test_bits_source_1byte_SOURCES = tests/test-bits_source_1byte_dats.c
tests_test_bits_source_1byte_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-bits_source_1byte.dats
CLEANFILES += tests/test-bits_source_1byte

check_PROGRAMS += tests/test-bits_source_8bytes
nodist_tests_test_bits_source_8bytes_SOURCES = tests/test-bits_source_8bytes_dats.c
tests_test_bits_source_8bytes_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-bits_source_8bytes.dats
CLEANFILES += tests/test-bits_source_8bytes

check_PROGRAMS += tests/test-bits_source_16bytes
nodist_tests_test_bits_source_16bytes_SOURCES = tests/test-bits_source_16bytes_dats.c
tests_test_bits_source_16bytes_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-bits_source_16bytes.dats
CLEANFILES += tests/test-bits_source_16bytes

check_PROGRAMS += tests/test-population_map
nodist_tests_test_population_map_SOURCES = tests/test-population_map_dats.c
tests_test_population_map_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-population_map.dats
CLEANFILES += tests/test-population_map

check_PROGRAMS += tests/test-a-uint8-map
nodist_tests_test_a_uint8_map_SOURCES = tests/test-a-uint8-map_dats.c
tests_test_a_uint8_map_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-a-uint8-map.dats
CLEANFILES += tests/test-a-uint8-map

check_PROGRAMS += tests/test-separate-chaining-1
nodist_tests_test_separate_chaining_1_SOURCES = tests/test-separate-chaining-1_dats.c
tests_test_separate_chaining_1_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-separate-chaining-1.dats
CLEANFILES += tests/test-separate-chaining-1

check_PROGRAMS += tests/test-separate-chaining-2
nodist_tests_test_separate_chaining_2_SOURCES = tests/test-separate-chaining-2_dats.c
tests_test_separate_chaining_2_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-separate-chaining-2.dats
CLEANFILES += tests/test-separate-chaining-2

check_PROGRAMS += tests/test-separate-chaining-3
nodist_tests_test_separate_chaining_3_SOURCES = tests/test-separate-chaining-3_dats.c
tests_test_separate_chaining_3_LDADD = $(lib_LTLIBRARIES)
EXTRA_DIST += tests/test-separate-chaining-3.dats
CLEANFILES += tests/test-separate-chaining-3

if WITH_SPOOKYHASH
# This SpookyHash test includes ‘compare_structure’ tests.
check_PROGRAMS += tests/test-strnptr2strnptr-spookyhash-map
nodist_tests_test_strnptr2strnptr_spookyhash_map_SOURCES = tests/test-strnptr2strnptr-spookyhash-map_dats.c
tests_test_strnptr2strnptr_spookyhash_map_LDADD = $(lib_LTLIBRARIES)
endif WITH_SPOOKYHASH
EXTRA_DIST += tests/test-strnptr2strnptr-spookyhash-map.dats
CLEANFILES += tests/test-strnptr2strnptr-spookyhash-map

@GNU@ define print-test-strnptr2strnptr-map-dats =
@GNU@   printf "%s\n%s\n%s\n" \
@GNU@     '#define SUBDIR "tests/$(1)/"' \
@GNU@     '#include "hashmap/HATS/strnptrmap-$(1).hats"' \
@GNU@     '#include "tests/INCLUDE/test-strnptr2strnptr-map.dats"'
@GNU@ endef

if WITH_SPOOKYHASH
check_PROGRAMS += tests/test-strnptr2strnptr-map-spookyhash
nodist_tests_test_strnptr2strnptr_map_spookyhash_SOURCES = tests/test-strnptr2strnptr-map-spookyhash_dats.c
tests_test_strnptr2strnptr_map_spookyhash_LDADD = $(lib_LTLIBRARIES)
tests/test-strnptr2strnptr-map-spookyhash.dats: GNUmakefile
	$(call v,GEN)$(call print-test-strnptr2strnptr-map-dats,spookyhash) > $(@)
endif WITH_SPOOKYHASH
CLEANFILES += tests/test-strnptr2strnptr-map-spookyhash.dats
CLEANFILES += tests/test-strnptr2strnptr-map-spookyhash

if WITH_MURMURHASH3_32
check_PROGRAMS += tests/test-strnptr2strnptr-map-murmurhash3_32
nodist_tests_test_strnptr2strnptr_map_murmurhash3_32_SOURCES = tests/test-strnptr2strnptr-map-murmurhash3_32_dats.c
tests_test_strnptr2strnptr_map_murmurhash3_32_LDADD = $(lib_LTLIBRARIES)
tests/test-strnptr2strnptr-map-murmurhash3_32.dats: GNUmakefile
	$(call v,GEN)$(call print-test-strnptr2strnptr-map-dats,murmurhash3_32) > $(@)
endif WITH_MURMURHASH3_32
CLEANFILES += tests/test-strnptr2strnptr-map-murmurhash3_32.dats
CLEANFILES += tests/test-strnptr2strnptr-map-murmurhash3_32

if WITH_HALFSIPHASH_32
check_PROGRAMS += tests/test-strnptr2strnptr-map-halfsiphash_32
nodist_tests_test_strnptr2strnptr_map_halfsiphash_32_SOURCES = tests/test-strnptr2strnptr-map-halfsiphash_32_dats.c
tests_test_strnptr2strnptr_map_halfsiphash_32_LDADD = $(lib_LTLIBRARIES)
tests/test-strnptr2strnptr-map-halfsiphash_32.dats: GNUmakefile
	$(call v,GEN)$(call print-test-strnptr2strnptr-map-dats,halfsiphash_32) > $(@)
endif WITH_HALFSIPHASH_32
CLEANFILES += tests/test-strnptr2strnptr-map-halfsiphash_32.dats
CLEANFILES += tests/test-strnptr2strnptr-map-halfsiphash_32

if WITH_HALFSIPHASH_64
check_PROGRAMS += tests/test-strnptr2strnptr-map-halfsiphash_64
nodist_tests_test_strnptr2strnptr_map_halfsiphash_64_SOURCES = tests/test-strnptr2strnptr-map-halfsiphash_64_dats.c
tests_test_strnptr2strnptr_map_halfsiphash_64_LDADD = $(lib_LTLIBRARIES)
tests/test-strnptr2strnptr-map-halfsiphash_64.dats: GNUmakefile
	$(call v,GEN)$(call print-test-strnptr2strnptr-map-dats,halfsiphash_64) > $(@)
endif WITH_HALFSIPHASH_64
CLEANFILES += tests/test-strnptr2strnptr-map-halfsiphash_64.dats
CLEANFILES += tests/test-strnptr2strnptr-map-halfsiphash_64

if WITH_SIPHASH_64
check_PROGRAMS += tests/test-strnptr2strnptr-map-siphash_64
nodist_tests_test_strnptr2strnptr_map_siphash_64_SOURCES = tests/test-strnptr2strnptr-map-siphash_64_dats.c
tests_test_strnptr2strnptr_map_siphash_64_LDADD = $(lib_LTLIBRARIES)
tests/test-strnptr2strnptr-map-siphash_64.dats: GNUmakefile
	$(call v,GEN)$(call print-test-strnptr2strnptr-map-dats,siphash_64) > $(@)
endif WITH_SIPHASH_64
CLEANFILES += tests/test-strnptr2strnptr-map-siphash_64.dats
CLEANFILES += tests/test-strnptr2strnptr-map-siphash_64

if WITH_SIPHASH_128
check_PROGRAMS += tests/test-strnptr2strnptr-map-siphash_128
nodist_tests_test_strnptr2strnptr_map_siphash_128_SOURCES = tests/test-strnptr2strnptr-map-siphash_128_dats.c
tests_test_strnptr2strnptr_map_siphash_128_LDADD = $(lib_LTLIBRARIES)
tests/test-strnptr2strnptr-map-siphash_128.dats: GNUmakefile
	$(call v,GEN)$(call print-test-strnptr2strnptr-map-dats,siphash_128) > $(@)
endif WITH_SIPHASH_128
CLEANFILES += tests/test-strnptr2strnptr-map-siphash_128.dats
CLEANFILES += tests/test-strnptr2strnptr-map-siphash_128

if WITH_DEFAULT_HASH
check_PROGRAMS += tests/test-strnptr2strnptr-map-default_hash
nodist_tests_test_strnptr2strnptr_map_default_hash_SOURCES = tests/test-strnptr2strnptr-map-default_hash_dats.c
tests_test_strnptr2strnptr_map_default_hash_LDADD = $(lib_LTLIBRARIES)
tests/test-strnptr2strnptr-map-default_hash.dats: GNUmakefile
	$(call v,GEN)printf "%s\n%s\n%s\n" \
		'#define SUBDIR "tests/default_hash/"' \
	 	'#include "hashmap/HATS/strnptrmap.hats"' \
		'#include "tests/INCLUDE/test-strnptr2strnptr-map.dats"' \
		> $(@)
endif WITH_DEFAULT_HASH
CLEANFILES += tests/test-strnptr2strnptr-map-default_hash.dats
CLEANFILES += tests/test-strnptr2strnptr-map-default_hash

if WITH_DEFAULT_HASH
check_PROGRAMS += tests/test-strnptr2uintptrmap
nodist_tests_test_strnptr2uintptrmap_SOURCES = tests/test-strnptr2uintptrmap_dats.c
tests_test_strnptr2uintptrmap_LDADD = $(lib_LTLIBRARIES)
endif WITH_DEFAULT_HASH
CLEANFILES += tests/test-strnptr2uintptrmap
EXTRA_DIST += tests/test-strnptr2uintptrmap.dats

if WITH_DEFAULT_HASH
check_PROGRAMS += tests/test-strnptrset
nodist_tests_test_strnptrset_SOURCES = tests/test-strnptrset_dats.c
tests_test_strnptrset_LDADD = $(lib_LTLIBRARIES)
endif WITH_DEFAULT_HASH
CLEANFILES += tests/test-strnptrset
EXTRA_DIST += tests/test-strnptrset.dats

if WITH_DEFAULT_HASH
check_PROGRAMS += tests/test-string2uintptrmap-C
nodist_tests_test_string2uintptrmap_C_SOURCES = tests/test-string2uintptrmap-C.c
tests_test_string2uintptrmap_C_LDADD = $(lib_LTLIBRARIES)
endif WITH_DEFAULT_HASH
CLEANFILES += tests/test-string2uintptrmap-C
EXTRA_DIST += tests/test-string2uintptrmap-C.c

if WITH_DEFAULT_HASH
check_PROGRAMS += tests/test-stringset-C
nodist_tests_test_stringset_C_SOURCES = tests/test-stringset-C.c
tests_test_stringset_C_LDADD = $(lib_LTLIBRARIES)
endif WITH_DEFAULT_HASH
CLEANFILES += tests/test-stringset-C
EXTRA_DIST += tests/test-stringset-C.c

.PHONY: tests-clean
tests-clean:
	-rm -f tests/*.structure
	-rm -f tests/*/*.contents
	-rm -f tests/*_sats.c
	-rm -f tests/*_dats.c

#--------------------------------------------------------------------------
#
# Computation of dependencies.
#

EXTRA_PROGRAMS += list-ats-dependencies
EXTRA_DIST += list-ats-dependencies.dats
CLEANFILES += list-ats-dependencies
CLEANFILES += list-ats-dependencies_depsprog.c

nodist_list_ats_dependencies_SOURCES =
nodist_list_ats_dependencies_SOURCES += list-ats-dependencies_depsprog.c
list_ats_dependencies_CPPFLAGS =
list_ats_dependencies_CPPFLAGS += $(AM_CPPFLAGS)
list_ats_dependencies_CPPFLAGS += -U_ATS_CCOMP_RUNTIME_NONE_
list_ats_dependencies_CPPFLAGS += -DATS_MEMALLOC_LIBC
list_ats_dependencies_DEPENDENCIES =
list_ats_dependencies_DEPENDENCIES += list-ats-dependencies.dats
list_ats_dependencies_LDADD =
list_ats_dependencies_LDADD += -L'$(PATSHOME)/ccomp/atslib/lib'
list_ats_dependencies_LDADD += -latslib

#--------------------------------------------------------------------------

nodist_pkgconfig_DATA += ats2-hashmap.pc

CLEANFILES += ats2-hashmap.pc

ats2-hashmap.pc: configure GNUmakefile
	$(call v,GEN)printf '' > $(@)
	@echo '' >> $(@)
	@echo 'prefix=@prefix@' >> $(@)
	@echo 'exec_prefix=@exec_prefix@' >> $(@)
	@echo 'libdir=@libdir@' >> $(@)
	@echo 'includedir=@includedir@' >> $(@)
	@echo 'package=@PACKAGE@' >> $(@)
	@echo 'version=@VERSION@' >> $(@)
	@echo 'pkgincludedir="$${includedir}/$${package}"' >> $(@)
	@echo '' >> $(@)
	@echo '# It is recommended you override this with' >> $(@)
	@echo '# --define-variable=PATSHOME="$${PATSHOME}"' >> $(@)
	@echo 'PATSHOME="@PKGCONFIG_PATSHOME@"' >> $(@)
	@echo '' >> $(@)
	@echo 'CPPFLAGS="-I$${pkgincludedir} -I$${PATSHOME} -I$${PATSHOME}/ccomp/runtime"' >> $(@)
	@echo '' >> $(@)
	@echo '# Options for patsopt.' >> $(@)
	@echo 'PATSOPTFLAGS="-IATS $${pkgincludedir}"' >> $(@)
	@echo '' >> $(@)
	@echo '# Options for patscc.' >> $(@)
	@echo 'PATSCCFLAGS="-IIATS $${pkgincludedir}"' >> $(@)
	@echo '' >> $(@)
	@echo 'Name: @PACKAGE@' >> $(@)
	@echo 'Description: Hash Maps (Ideal Hash Trees) for ATS2/Postiats and C' >> $(@)
	@echo 'Version: @VERSION@' >> $(@)
	@echo 'Requires.private: @REQUIRES_PRIVATE_PKGS@' >> $(@)
	@echo 'Libs: -L$${libdir} -lats2-hashmap' >> $(@)
	@echo 'Cflags: $${CPPFLAGS}' >> $(@)

#--------------------------------------------------------------------------
#
# To create an .indent.pro in the builddir.

.PHONY: indent-pro
indent-pro: $(builddir)/.indent.pro

$(builddir)/.indent.pro: GNUmakefile
	printf "%s\n" "-l70" > $(@)

#--------------------------------------------------------------------------
# local variables:
# coding: utf-8
# end:
