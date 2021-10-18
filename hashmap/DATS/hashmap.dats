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
(* Hash maps implemented as array mapped trees.                     *)
(*                                                                  *)
(* References:                                                      *)
(*   [1] Phil Bagwell, "Fast and space efficient trie searches",    *)
(*       2000.                                                      *)
(*   [2] Phil Bagwell, "Ideal hash trees", 2001.                    *)
(*                                                                  *)
(*                                                                  *)
(********************************************************************)

#define ATS_PACKNAME "ats2-hashmap"
#define ATS_EXTERN_PREFIX "ats2_hashmap_"

#define ATS_DYNLOADFLAG 0

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

//#include "hashmap/HATS/bits-source-include.hats"

staload UN = "prelude/SATS/unsafe.sats"

staload "hashmap/SATS/hashmap.sats"
staload "hashmap/SATS/bits_source-parameters.sats"
staload "hashmap/SATS/bits_source.sats"
staload "hashmap/SATS/population_map.sats"
staload "popcount/SATS/popcount.sats"

staload _ = "hashmap/DATS/population_map.dats"
staload _ = "popcount/DATS/popcount.dats"

#define NIL list_vt_nil ()
#define :: list_vt_cons

#define CHAR_BIT 8              (* The size of a byte, in bits. *)

prval _ =
  $UN.prop_assert
    {BITS_SOURCE_MAXVAL == CHAR_BIT * sizeof (population_map_t) - 1}
    ()

(********************************************************************)

vtypedef
key_value_vt (key_vt   : vtype+,
              value_vt : vtype+) =
  @(key_vt, value_vt)

vtypedef
key_value_list_vt (key_vt   : vtype+,
                   value_vt : vtype+,
                   length   : int) =
  list_vt (key_value_vt (key_vt, value_vt), length)
vtypedef
key_value_list_vt (key_vt   : vtype+,
                   value_vt : vtype+) =
  [length : int]
  list_vt (key_value_vt (key_vt, value_vt), length)

datavtype
node_vt (key_vt   : vtype+,
         value_vt : vtype+) =
| node_vt_key_value (key_vt, value_vt) of
    key_value_vt (key_vt, value_vt)
| node_vt_array (key_vt, value_vt) of
    node_array_vt (key_vt, value_vt)
| node_vt_list (key_vt, value_vt) of
    key_value_list_vt (key_vt, value_vt)
where
node_array_vt (key_vt            : vtype+,
               value_vt          : vtype+,
               population_map    : int,
               length            : int,
               p_array           : addr) =
  @{
    population_map_view = POPCOUNT (population_map, length),
    array_view = @[node_vt (key_vt, value_vt)][length] @ p_array,
    mfree_view = mfree_gc_v p_array |
    population_map = population_map_t population_map,
    p_array = ptr p_array
  }
and
node_array_vt (key_vt            : vtype+,
               value_vt          : vtype+) =
  [population_map : int]
  [length         : int]
  [p              : addr]
  node_array_vt (key_vt, value_vt, population_map, length, p)

datavtype
map_vt (key_vt            : vtype+,
        value_vt          : vtype+,
        size              : int) =
| map_vt_nil (key_vt, value_vt, 0) of ()
| {1 <= size}
  map_vt_root (key_vt, value_vt, size) of
    @{
      size = size_t size,
      tree = node_array_vt (key_vt, value_vt)
    }

assume
hashmap_vt (key_vt, value_vt, size) =
  map_vt (key_vt, value_vt, size)

(********************************************************************)

primplement
lemma_hashmap_vt_param (map) =
  case+ map of
  | map_vt_nil () => ()
  | map_vt_root _ => ()

(********************************************************************)

implement {}
hashmap () =
  map_vt_nil ()

(********************************************************************)

implement {}
hashmap_size (map) =
  case+ map of
  | map_vt_nil () => i2sz 0
  | map_vt_root @{size = size, tree = _} => size

implement {}
hashmap_is_empty (map) =
  case+ map of
  | map_vt_nil () => true
  | map_vt_root _ => false

implement {}
hashmap_isnot_empty (map) =
  case+ map of
  | map_vt_nil () => false
  | map_vt_root _ => true

(********************************************************************)

fn {key_vt, value_vt : vtype}
make_new_array
        {population_map : int}
        (pf_popcount    : POPCOUNT (population_map, 1) |
         population_map : population_map_t population_map,
         key            : key_vt,
         value          : value_vt) :
    [p : addr | null < p]
    (@[node_vt (key_vt, value_vt)][1] @ p, mfree_gc_v p | ptr p) =
  let
    vtypedef t = node_vt (key_vt, value_vt)

    (* The only leaf node that will be in the array. *)
    val new_leaf = node_vt_key_value @(key, value)

    (* Allocate the array. *)
    val [p_array : addr] @(pf_array, pf_mfree | p_array) =
      array_ptr_alloc<t> (i2sz 1)

    (* Put the leaf in it. *)
    prval @(pf_entry, pf_nil_array) = array_v_uncons pf_array
    val _ = ptr_set<t> {p_array} (pf_entry | p_array, new_leaf)
    prval pf_nil_array = array_v_unnil_nil {t?, t} pf_nil_array
    prval pf_array = array_v_cons (pf_entry, pf_nil_array)
  in
    @(pf_array, pf_mfree | p_array)
  end

(********************************************************************)

implement {hash_vt} {key_vt, value_vt}
hashmap_include {size} (map, key, value) =
  case+ map of
  | ~ map_vt_nil () =>
    let
      var hash : hash_vt

      val () = hashmap$hash_function<hash_vt><key_vt> (key, hash)
      val bits = hashmap$bits_source<hash_vt> (hash, 0U)
      val () = hashmap$hash_vt_free<hash_vt> (hash)

      val [population_map : int] population_map =
        bits_to_population_map (bits)
      prval _ =
        $UN.prop_assert {popcount_relation (population_map, 1)} ()
      prval pf_popcount =
        popcount_relation_to_proof {population_map} {1} ()

      val @(pf_array, pf_mfree | p_array) =
        make_new_array<key_vt, value_vt>
          (pf_popcount | population_map, key, value)

      val tree =
        @{
          population_map_view = pf_popcount,
          array_view = pf_array,
          mfree_view = pf_mfree |
          population_map = population_map,
          p_array = p_array
        }
    in
      map_vt_root @{size = i2sz 1, tree = tree}
    end
  | ~ map_vt_root @{size = size, tree = tree} =>
    let
val _ = $UN.castvwtp0{void} key
val _ = $UN.castvwtp0{void} value
    in
      map_vt_root @{size = size, tree = tree} // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME
    end

(********************************************************************)

(*
fn {}
get_leaf_value
        {length    : int | length <= bitsizeof (uintptr)}
        {key       : int}
        {bits      : int | valid_unexhausted_bits (NUM_BITS, bits)}
        (node      : !node_vt (length) >> _,
         bits      : int bits,
         key_test  : !key_test_vt >> _,
         key       : uintptr key,
         is_stored : &bool? >> bool is_stored,
         is_last   : &bool? >> bool is_last,
         value     : &uintptr? >> uintptr key_value) :
    #[is_stored : bool]
    #[is_last : bool | is_stored || is_last]
    #[key_value : int | is_stored || key_value == 0]
    void =
  let
    prval _ = lemma_node_vt_param {length} node
    prval _ = prop_verify {0 < length} ()

    val population_map = get_population_map<> (node)
    val bit_selection_mask = (one << bits)
    val entry_is_stored =
      bit_is_set<> (population_map, bit_selection_mask)
  in
    if entry_is_stored then
      let
        val leaf_map = get_leaf_map<> (node)
        val entry_is_leaf =
          bit_is_set<> (leaf_map, bit_selection_mask)

        val [index : int] @(_ | index) =
          get_popcount_low_bits (g1ofg0 population_map, i2u bits)
        prval _ = $UN.prop_assert {index < length} ()

        val entry = node[index]
      in
        if entry_is_leaf then
          let
            val chaining_map = get_chaining_map<> (node)
            val entry_is_chain =
              bit_is_set<> (chaining_map, bit_selection_mask)
          in
            if entry_is_chain then
              let
                fun
                search {n : int | 0 <= n} .<n>.
                       (key_test : !key_test_vt >> _,
                        key      : uintptr key,
                        lst      : !list_vt (uintptr, n) >> _) :
                    @(bool, uintptr) =
                  case+ lst of
                  | NIL => @(false, zero)
                  | @ head :: tail =>
                    let
                      val key_matches = key_test (key, head)
                    in
                      if key_matches then
                        let
                          val value = head
                          prval _ = fold@ lst
                        in
                          @(true, value)
                        end
                      else
                        let
                          val result =
                            search {n - 1} (key_test, key, tail)
                          prval _ = fold@ lst
                        in
                          result
                        end
                    end
                val lst =
                  $UN.castvwtp0{List_vt uintptr} (uintptr2ptr entry)
                prval _ = lemma_list_vt_param lst
                val @(is_found, pointer) = search (key_test, key, lst)
                prval _ = $UN.castvwtp0{Ptr} lst
              in
                if is_found then
                  (* Success. *)
                  begin
                    is_last := true;
                    is_stored := true;
                    value := g1ofg0 pointer
                  end
                else
                  (* No match for the key is found. *)
                  begin
                    is_last := true;
                    is_stored := false;
                    value := zero
                  end
              end
            else
              let
                val key_matches = key_test (key, entry)
              in
                if key_matches then
                  (* Success. *)
                  begin
                    is_last := true;
                    is_stored := true;
                    value := g1ofg0 entry
                  end
                else
                  (* The entry does not match the key. *)
                  begin
                    is_last := true;
                    is_stored := false;
                    value := zero
                  end
              end
          end
        else
          (* The entry is a link to a subnode. *)
          begin
            is_last := false;
            is_stored := true;
            value := g1ofg0 entry
          end
      end
    else
      (* There is no such entry. *)
      begin
        is_last := true;
        is_stored := false;
        value := zero
      end
  end
  *)

fun {hash_vt : vt@ype}
    {key_vt, value_vt : vtype}
find_entry {bits    : int | bits_source_valid_value bits}
           {population_map : int}
           {length  : int}
           {p_array : addr}
           {depth   : int}
           (hash    : &hash_vt >> _,
            bits    : int bits,
            tree    : !node_array_vt (key_vt, value_vt,
                                      population_map,
                                      length, p_array) >> _,
            key     : !key_vt >> _,
            depth   : uint depth) : Option_vt (value_vt) =
  let
    vtypedef t = node_vt (key_vt, value_vt)
    val [bits : int] bits = hashmap$bits_source<hash_vt> (hash, 0U)
  in
    if bits = BITS_SOURCE_EXHAUSTED then
      None_vt ()
    else
      let
        prval _ = prop_verify {bits_source_valid_bits bits} ()
        val mask = bits_to_population_map bits
        val population_map = (tree.population_map)
        val array_has_an_entry = isneqz (population_map land mask)
      in
        if array_has_an_entry then
          let
            val [array_index : int] @(pf_array_index | array_index) =
              popcount_low_bits_with_proof<population_map_kind>
                (population_map, i2u bits)
            prval _ = popcount_low_bits_is_nonnegative pf_array_index
            prval _ = $UN.prop_assert {array_index < length} ()
            val p_entry : P2tr (node_vt (key_vt, value_vt)) =
              array_getref_at<t> (!(tree.p_array), i2sz array_index)
            // FIXME // FIXME FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME
          in
            None_vt () // FIXME // FIXME FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME
          end
        else
          None_vt ()
      end
  end
(*
{length       : int | length <= bitsizeof (uintptr)}
        {key          : int}
        {depth        : int}
        (node         : !node_vt (length) >> _,
         bits_source  : !bits_source_cloptr (hash_vt, NUM_BITS) >> _,
         hash_storage : &hash_vt >> _,
         key_test     : !key_test_vt >> _,
         key          : uintptr key,
         depth        : uint depth,
         is_stored    : &bool? >> bool is_stored,
         key_value    : &uintptr? >> uintptr key_value) :
    #[is_stored : bool]
    #[key_value : int | is_stored || key_value == 0]
    void =
  let
    val [bits : int] (pf_bits | bits) =
      bits_source (hash_storage, depth)
    prval _ = bits_source_bits_bounds pf_bits
    prval _ = prop_verify {valid_bits (NUM_BITS, bits)} ()
  in
    if bits = BITS_SOURCE_EXHAUSTED then
      begin
        is_stored := false;
        key_value := zero
      end
    else
      let
        var is_last : bool
      in
        get_leaf_value<>
          {length} {key} {bits} (node, bits, key_test, key,
                                 is_stored, is_last, key_value);
        if not is_last then
          {
            val [length1 : int] [p1 : addr] next_node =
              uintptr2node key_value
            prval _ = lemma_node_vt_param {length1} {p1} (next_node)
            val _ =
              get_subtree_entry__loop<hash_vt>
                (next_node, bits_source, hash_storage, key_test, key,
                 succ depth, is_stored, key_value)
            prval _ = $UN.castvwtp0{uptr} next_node
          }
      end
  end
*)

implement {hash_vt} {key_vt, value_vt}
hashmap_find (map, key) =
  case+ map of
  | map_vt_nil () => None_vt ()
  | map_vt_root root =>
    let
      var hash : hash_vt

      val () = hashmap$hash_function<hash_vt><key_vt> (key, hash)
      val bits = hashmap$bits_source<hash_vt> (hash, 0U)

      val result =
        find_entry<hash_vt><key_vt, value_vt>
          (hash, bits, root.tree, key, 0U)

      val () = hashmap$hash_vt_free<hash_vt> (hash)
    in
      result
    end

(********************************************************************)
