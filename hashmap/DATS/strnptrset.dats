(*

Copyright © 2021 Barry Schwartz

This program is free software: you can redistribute it and/or
modify it under the terms of the GNU General Public License, as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received copies of the GNU General Public License
along with this program. If not, see
<https://www.gnu.org/licenses/>.

*)

#define ATS_PACKNAME "ats2-hashmap"
#define ATS_EXTERN_PREFIX "ats2_hashmap_"

#define ATS_DYNLOADFLAG 0

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

staload "hashmap/SATS/strnptrset.sats"
#include "hashmap/HATS/strnptr2uintptrmap.hats"

assume strnptrset_vt (size) =
  strnptr2uintptrmap_vt (size)

primplement
lemma_strnptrset_vt_param (set) =
  lemma_strnptr2uintptrmap_vt_param (set)

implement {}
strnptrset () =
  strnptr2uintptrmap ()

implement {}
strnptrset_size (set) =
  strnptr2uintptrmap_size (set)

implement {}
strnptrset_is_empty (set) =
  strnptr2uintptrmap_is_empty (set)

implement {}
strnptrset_isnot_empty (set) =
  strnptr2uintptrmap_isnot_empty (set)

implement {}
strnptrset_add_string (set, element) =
  strnptr2uintptrmap_set_string (set, element, $UNSAFE.cast 0,
                                 $UNSAFE.cast the_null_ptr,
                                 the_null_ptr)

implement {}
strnptrset_add_strptr (set, element) =
  strnptr2uintptrmap_set_strptr (set, element, $UNSAFE.cast 0,
                                 $UNSAFE.cast the_null_ptr,
                                 the_null_ptr)

implement {}
strnptrset_add_strnptr (set, element) =
  strnptr2uintptrmap_set_strnptr (set, element, $UNSAFE.cast 0,
                                  $UNSAFE.cast the_null_ptr,
                                  the_null_ptr)

implement {}
strnptrset_del_string (set, element) =
  strnptr2uintptrmap_del_string (set, element)

implement {}
strnptrset_del_strptr (set, element) =
  strnptr2uintptrmap_del_strptr (set, element)

implement {}
strnptrset_del_strnptr (set, element) =
  strnptr2uintptrmap_del_strnptr (set, element)

implement {}
strnptrset_contains_string (set, element) =
  strnptr2uintptrmap_has_key_string (set, element)

implement {}
strnptrset_contains_strptr (set, element) =
  strnptr2uintptrmap_has_key_strptr (set, element)

implement {}
strnptrset_contains_strnptr (set, element) =
  strnptr2uintptrmap_has_key_strnptr (set, element)

implement {}
strnptrset_elements (set) =
  strnptr2uintptrmap_keys (set)

implement {}
strnptrset_elements_free (elements) =
  strnptr2uintptrmap_keys_free (elements)

implement {}
strnptrset_free (set) =
  strnptr2uintptrmap_free (set)
