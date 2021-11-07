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
