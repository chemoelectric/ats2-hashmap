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

staload "hashmap/SATS/strnptr2uintptrmap.sats"
#include "hashmap/HATS/strnptrmap.hats"

implement
strnptr2uintptrmap_set_strnptr (map, key, value) =
  let
    implement
    hashmap$value_vt_free<uintptr> (value) =
      ()
  in
    strnptrmap_set<uintptr> (map, key, value)
  end

implement
strnptr2uintptrmap_set_strptr (map, key, value) =
  let
    val s = strptr2strnptr key
    prval _ = lemma_strnptr_param s
  in
    strnptr2uintptrmap_set_strnptr (map, s, value)
  end

implement
strnptr2uintptrmap_set_string (map, key, value) =
  let
    val key = g1ofg0 key
    prval _ = lemma_string_param key
    val s = string1_copy key
  in
    strnptr2uintptrmap_set_strnptr (map, s, value)
  end
