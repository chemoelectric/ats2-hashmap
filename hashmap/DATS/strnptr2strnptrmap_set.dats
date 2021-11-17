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

staload "hashmap/SATS/strnptr2strnptrmap.sats"
#include "hashmap/HATS/strnptrmap.hats"

vtypedef value_vt = Strnptr1

implement
strnptr2strnptrmap_set_strnptr_strnptr (map, key, value) =
  let
    implement
    hashmap$value_vt_free<value_vt> (v) =
      strnptr_free v
  in
    strnptrmap_set<value_vt> (map, key, value)
  end

implement
strnptr2strnptrmap_set_strnptr_strptr (map, key, value) =
  let
    val v = strptr2strnptr value
    prval _ = lemma_strnptr_param v
  in
    strnptr2strnptrmap_set_strnptr_strnptr (map, key, v)
  end

implement
strnptr2strnptrmap_set_strnptr_string (map, key, value) =
  let
    val value = g1ofg0 value
    prval _ = lemma_string_param value
    val v = string1_copy value
  in
    strnptr2strnptrmap_set_strnptr_strnptr (map, key, v)
  end

implement
strnptr2strnptrmap_set_strptr_strnptr (map, key, value) =
  let
    val k = strptr2strnptr key
    prval _ = lemma_strnptr_param k
  in
    strnptr2strnptrmap_set_strnptr_strnptr (map, k, value)
  end

implement
strnptr2strnptrmap_set_strptr_strptr (map, key, value) =
  let
    val k = strptr2strnptr key
    prval _ = lemma_strnptr_param k

    val v = strptr2strnptr value
    prval _ = lemma_strnptr_param v
  in
    strnptr2strnptrmap_set_strnptr_strnptr (map, k, v)
  end

implement
strnptr2strnptrmap_set_strptr_string (map, key, value) =
  let
    val k = strptr2strnptr key
    prval _ = lemma_strnptr_param k

    val value = g1ofg0 value
    prval _ = lemma_string_param value
    val v = string1_copy value
  in
    strnptr2strnptrmap_set_strnptr_strnptr (map, k, v)
  end

implement
strnptr2strnptrmap_set_string_strnptr (map, key, value) =
  let
    val key = g1ofg0 key
    prval _ = lemma_string_param key
    val k = string1_copy key
  in
    strnptr2strnptrmap_set_strnptr_strnptr (map, k, value)
  end

implement
strnptr2strnptrmap_set_string_strptr (map, key, value) =
  let
    val key = g1ofg0 key
    prval _ = lemma_string_param key
    val k = string1_copy key

    val v = strptr2strnptr value
    prval _ = lemma_strnptr_param v
  in
    strnptr2strnptrmap_set_strnptr_strnptr (map, k, v)
  end

implement
strnptr2strnptrmap_set_string_string (map, key, value) =
  let
    val key = g1ofg0 key
    prval _ = lemma_string_param key
    val k = string1_copy key

    val value = g1ofg0 value
    prval _ = lemma_string_param value
    val v = string1_copy value
  in
    strnptr2strnptrmap_set_strnptr_strnptr (map, k, v)
  end
