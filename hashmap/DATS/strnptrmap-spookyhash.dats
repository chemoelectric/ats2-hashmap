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

(********************************************************************)
(*                                                                  *)
(* String maps by means of hashmap and ats2-spookyhash              *)
(*                                                                  *)
(********************************************************************)

#define ATS_PACKNAME "ats2-hashmap"
#define ATS_EXTERN_PREFIX "ats2_hashmap_"

#define ATS_DYNLOADFLAG 0

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

staload UN = "prelude/SATS/unsafe.sats"

staload "hashmap/SATS/strnptrmap.sats"

staload "hashmap/SATS/bits_source.sats"
staload "hashmap/SATS/bits_source-parameters.sats"
staload "hashmap/SATS/hashmap.sats"
staload "spookyhash/SATS/spookyhash.sats"

local

  typedef hash_t = @(uint64, uint64)
  vtypedef key_vt = Strnptr1

  (* seed1 and seeds may be any numbers that please the programmer,
     although changing them may change what are the correct results
     of regression tests. *)
  macdef seed1 = $UN.cast{uint64} 0xDEADBEEFBACEBA11ULL
  macdef seed2 = $UN.cast{uint64} 0xBACEBA11DEADBEEFULL

  implement
  hashmap$hash_function<hash_t><key_vt> (key, hash) =
    {
      val [n : int] s = g1ofg0 ($UN.strnptr2string key)
      val n = strlen s
      val p = string2ptr s
      val (pf_bytes, consume_pf | p) = $UN.ptr_vtake {@[byte][n]} p
      val _ = hash := spookyhash_hash128 (!p, n, seed1, seed2)
      prval () = consume_pf pf_bytes
    }

  implement
  hashmap$hash_vt_free<hash_t> (hash) =
    ()

  implement
  hashmap$bits_source<hash_t> (hash, depth) =
    bits_source_uint64_uint64 (hash, depth)

  implement
  hashmap$key_vt_free<key_vt> (key) =
    free key

  implement
  hashmap$key_vt_copy<key_vt> (key) =
    string1_copy ($UN.strnptr2string key)

  implement
  hashmap$key_vt_eq<key_vt> (key_arg, key_stored) =
    ($UN.strnptr2string key_arg) = ($UN.strnptr2string key_stored)

in

  primplement
  lemma_strnptrmap_vt_param (map) =
    lemma_hashmap_vt_param (map)

  implement {}
  strnptrmap () =
    hashmap<> ()

  implement {}
  strnptrmap_size (map) =
    hashmap_size<> (map)

  implement {}
  strnptrmap_is_empty (map) =
    hashmap_is_empty<> (map)

  implement {}
  strnptrmap_isnot_empty (map) =
    hashmap_isnot_empty<> (map)

  implement {value_vt}
  strnptrmap_set_string (map, key, value) =
    let
      val key = g1ofg0 key
      prval _ = lemma_string_param key
      val s = string1_copy key
    in
      strnptrmap_set_strnptr<value_vt> (map, s, value)
    end

  implement {value_vt}
  strnptrmap_set_strptr (map, key, value) =
    let
      val s = strptr2strnptr key
      prval _ = lemma_strnptr_param s
    in
      strnptrmap_set_strnptr<value_vt> (map, s, value)
    end

  implement {value_vt}
  strnptrmap_set_strnptr (map, key, value) =
    hashmap_set<hash_t><key_vt, value_vt> (map, key, value)

  implement {value_vt}
  strnptrmap_del_string (map, key) =
    (* WARNING: The following implementation really does assume that
       the "key" argument to strnptrmap_del_strnptr is read-only.
       (You could implement this template without that assumption,
       by using string1_copy. *)
    let
      val s = $UN.castvwtp0{Strnptr1} key
      val result = strnptrmap_del_strnptr<value_vt> (map, s)
      prval _ = $UN.castvwtp0{void} s
    in
      result
    end

  implement {value_vt}
  strnptrmap_del_strptr (map, key) =
    let
      val s = $UN.castvwtp1{Strnptr1} key
      prval _ = lemma_strnptr_param s
      val result = strnptrmap_del_strnptr<value_vt> (map, s)
      val _ = $UN.castvwtp0{void} s
    in
      result
    end

  implement {value_vt}
  strnptrmap_del_strnptr (map, key) =
    hashmap_del<hash_t><key_vt, value_vt> (map, key)

  implement {value_vt}
  strnptrmap_get_opt_string (map, key) =
    (* WARNING: The following implementation really does assume that
       the "key" argument to strnptrmap_del_strnptr is read-only.
       (You could implement this template without that assumption,
       by using string1_copy. *)
    let
      val s = $UN.castvwtp0{Strnptr1} key
      val result = strnptrmap_get_opt_strnptr<value_vt> (map, s)
      prval _ = $UN.castvwtp0{void} s
    in
      result
    end

  implement {value_vt}
  strnptrmap_get_opt_strptr (map, key) =
    let
      val s = $UN.castvwtp1{Strnptr1} key
      prval _ = lemma_strnptr_param s
      val result = strnptrmap_get_opt_strnptr<value_vt> (map, s)
      val _ = $UN.castvwtp0{void} s
    in
      result
    end

  implement {value_vt}
  strnptrmap_get_opt_strnptr (map, key) =
    hashmap_get_opt<hash_t><key_vt, value_vt> (map, key)

  implement {value_vt}
  strnptrmap_has_key_string (map, key) =
    (* WARNING: The following implementation really does assume that
       the "key" argument to strnptrmap_del_strnptr is read-only.
       (You could implement this template without that assumption,
       by using string1_copy. *)
    let
      val s = $UN.castvwtp0{Strnptr1} key
      val result = strnptrmap_has_key_strnptr<value_vt> (map, s)
      prval _ = $UN.castvwtp0{void} s
    in
      result
    end

  implement {value_vt}
  strnptrmap_has_key_strptr (map, key) =
    let
      val s = $UN.castvwtp1{Strnptr1} key
      prval _ = lemma_strnptr_param s
      val result = strnptrmap_has_key_strnptr<value_vt> (map, s)
      val _ = $UN.castvwtp0{void} s
    in
      result
    end

  implement {value_vt}
  strnptrmap_has_key_strnptr (map, key) =
    hashmap_has_key<hash_t><key_vt, value_vt> (map, key)

  implement {value_vt}
  strnptrmap_pairs (map) =
    hashmap_pairs<key_vt, value_vt> (map)

  implement {value_vt}
  strnptrmap_keys (map) =
    hashmap_keys<key_vt, value_vt> (map)

  implement {value_vt}
  strnptrmap_values (map) =
    hashmap_values<key_vt, value_vt> (map)

  implement {value_vt}
  strnptrmap_free (map) =
    hashmap_free<key_vt, value_vt> (map)

end
