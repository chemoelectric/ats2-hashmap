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

#include "hashmap/HATS/config.hats"
#include "hashmap/HATS/bits-source-include.hats"

staload "hashmap/SATS/array-mapped-tree.sats"
staload "hashmap/SATS/array-mapped-tree-templates.sats"

staload "hashmap/SATS/array_prf.sats"

staload "hashmap/SATS/memory.sats"
staload _ = "hashmap/DATS/memory.dats"

staload "hashmap/SATS/count-one-bits.sats"
staload _ = "hashmap/DATS/count-one-bits.dats"

staload "hashmap/SATS/bits-source.sats"

staload "hashmap/SATS/uptr.sats"
staload _ = "hashmap/DATS/uptr.dats"

#include "hashmap/HATS/array-mapped-tree-helpers.hats"

staload UN = "prelude/SATS/unsafe.sats"

prval _ = $UN.prop_assert {sizeof (uintptr) == SIZEOF_UINTPTR} ()
prval _ = prop_verify {bitsizeof (uintptr) == BITSIZEOF_UINTPTR} ()

prval _ = prop_verify {sizeof (link_vt) == sizeof (uintptr)} ()
prval _ = prop_verify {sizeof (link_vt) == SIZEOF_UINTPTR} ()

(********************************************************************)

implement {}
uintptr2node (i) =
  uptr2node (uintptr2uptr i)

implement {}
node2uintptr (node) =
  uptr2uintptr (node2uptr node)

(********************************************************************)

implement {}
population_map_ptr (p) = p

implement {}
leaf_map_ptr (p) = uptr_succ<uintptr> (p)

implement {}
chaining_map_ptr (p) = uptr_add<uintptr> (p, 2)

implement {}
entries_ptr (p) = uptr_add<uintptr> (p, 3)

(********************************************************************)

implement {}
get_popcount (population_map) =
  let
    val [popcount : int] (pf_popcount | popcount) =
      popcount<uintptrknd> (population_map)

    prval _ = popcount_is_nonnegative pf_popcount
    prval _ = prop_verify {0 <= popcount} ()

    val _ = $effmask_exn assertloc (popcount <= BITSIZEOF_UINTPTR)
  in
    @(pf_popcount | g1i2u popcount)
  end

implement {}
get_popcount_low_bits {population_map} {i} (population_map, i) =
  let
    val [popcount : int] (pf_popcount | popcount) =
      popcount_low_bits<uintptrknd> (population_map, i)

    prval _ = popcount_low_bits_is_nonnegative pf_popcount
    prval _ = prop_verify {0 <= popcount} ()

    prval _ = popcount_low_bits_bound pf_popcount
    prval _ = prop_verify {popcount <= i} ()
  in
    @(pf_popcount | popcount)
  end

(********************************************************************)

implement {}
extract_static_length_of_node {length} (node) =
  $UN.castvwtp1 node

(********************************************************************)

implement {}
node_alloc (length) =
  let
    val size = length + (g1u2u 3U)
    val @(view, mfree | pointer) = array_ptr_alloc<uintptr> (size)
  in
    @(view, mfree | ptr2uptr pointer)
  end

implement {}
new_slotted_node_alloc {length, index} (length, index) =
  let
    val [p : addr] @(pf_view, pf_mfree | p) =
      node_alloc<> {length} (length)

    prval _ = lemma_g1uint_param length
    prval _ = prop_verify {0 <= length} ()

    prval @(pf_pop_map, pf_view) =
      array_v_uncons {uintptr?} {population_map_addr p} pf_view
    prval @(pf_leaf_map, pf_view) =
      array_v_uncons {uintptr?} {leaf_map_addr p} pf_view
    prval @(pf_chain_map, pf_entries) =
      array_v_uncons {uintptr?} {chaining_map_addr p} pf_view
    prval _ =
      $UN.castview2void_at {@[link_vt?][length]}
                           {@[uintptr?][length]}
                           {entries_addr p}
                           pf_entries

    prval _ = lemma_g1uint_param index
    prval _ = prop_verify {0 <= index} ()

    prval @(pf_left, pf_right) =
      array_v_subdivide2 {link_vt?} {entries_addr p}
                         {index, length - index}
                         pf_entries
    prval @(pf_entry, pf_right) = array_v_uncons pf_right
  in
    @{
      view_of_population_map = pf_pop_map,
      view_of_leaf_map = pf_leaf_map,
      view_of_chaining_map = pf_chain_map,
      view_of_left_entries = pf_left,
      view_of_new_entry = pf_entry,
      view_of_right_entries = pf_right,
      mfree = pf_mfree |
      pointer = p
    }
  end

implement {}
new_length1_node_alloc () =
  let
    val [p : addr] @(pf_view, pf_mfree | p) =
      node_alloc<> {1} (i2sz 1)
    prval @(pf_pop_map, pf_view) = array_v_uncons pf_view
    prval @(pf_leaf_map, pf_view) = array_v_uncons pf_view
    prval @(pf_chain_map, pf_entries) = array_v_uncons pf_view
    prval _ =
      $UN.castview2void_at {@[link_vt?][1]} {@[uintptr?][1]}
                           {entries_addr p}
                           pf_entries
  in
    @{
      view_of_population_map = pf_pop_map,
      view_of_leaf_map = pf_leaf_map,
      view_of_chaining_map = pf_chain_map,
      view_of_entries = pf_entries,
      mfree = pf_mfree |
      pointer = p
    }
  end

(********************************************************************)

implement {}
expired_node_vt_free {length} {p} (node) =
  let
    val @{
          view_of_population_map = pf_pop_map,
          view_of_leaf_map = pf_leaf_map,
          view_of_chaining_map = pf_chain_map,
          view_of_entries = pf_entries,
          mfree = pf_mfree |
          pointer = p
        } = node

    prval _ =
      $UN.castview2void_at
        {@[uintptr][length]} {@[link_vt?!][length]} {entries_addr p}
        pf_entries
    prval pf = array_v_cons (pf_chain_map, pf_entries)
    prval pf = array_v_cons (pf_leaf_map, pf)
    prval pf = array_v_cons (pf_pop_map, pf)
  in
    array_ptr_free {uintptr} {p} {length + 3}
                   (pf, pf_mfree | uptr2ptr p)
  end

(********************************************************************)

implement {}
get_population_map (node) =
  let
    val @{
          view_of_population_map = pf_pop_map,
          view_of_leaf_map = pf_leaf_map,
          view_of_chaining_map = pf_chain_map,
          view_of_entries = pf_entries,
          mfree = pf_mfree |
          pointer = p
        } = node

    val pop_map =
      uptr_get<uintptr> (pf_pop_map | population_map_ptr p)

    prval _ = node :=
      @{
        view_of_population_map = pf_pop_map,
        view_of_leaf_map = pf_leaf_map,
        view_of_chaining_map = pf_chain_map,
        view_of_entries = pf_entries,
        mfree = pf_mfree |
        pointer = p
      }
  in
    pop_map
  end

(********************************************************************)

implement {}
get_leaf_map (node) =
  let
    val @{
          view_of_population_map = pf_pop_map,
          view_of_leaf_map = pf_leaf_map,
          view_of_chaining_map = pf_chain_map,
          view_of_entries = pf_entries,
          mfree = pf_mfree |
          pointer = p
        } = node

    val leaf_map = uptr_get<uintptr> (pf_leaf_map | leaf_map_ptr p)

    prval _ = node :=
      @{
        view_of_population_map = pf_pop_map,
        view_of_leaf_map = pf_leaf_map,
        view_of_chaining_map = pf_chain_map,
        view_of_entries = pf_entries,
        mfree = pf_mfree |
        pointer = p
      }
  in
    leaf_map
  end

implement {}
set_leaf_map (node, value) =
  {
    val @{
          view_of_population_map = pf_pop_map,
          view_of_leaf_map = pf_leaf_map,
          view_of_chaining_map = pf_chain_map,
          view_of_entries = pf_entries,
          mfree = pf_mfree |
          pointer = p
        } = node

    val _ = uptr_set<uintptr> (pf_leaf_map | leaf_map_ptr p,
                                             value)

    prval _ = node :=
      @{
        view_of_population_map = pf_pop_map,
        view_of_leaf_map = pf_leaf_map,
        view_of_chaining_map = pf_chain_map,
        view_of_entries = pf_entries,
        mfree = pf_mfree |
        pointer = p
      }
  }

(********************************************************************)

implement {}
get_chaining_map (node) =
  let
    val @{
          view_of_population_map = pf_pop_map,
          view_of_leaf_map = pf_leaf_map,
          view_of_chaining_map = pf_chain_map,
          view_of_entries = pf_entries,
          mfree = pf_mfree |
          pointer = p
        } = node

    val chaining_map =
      uptr_get<uintptr> (pf_chain_map | chaining_map_ptr p)

    prval _ = node :=
      @{
        view_of_population_map = pf_pop_map,
        view_of_leaf_map = pf_leaf_map,
        view_of_chaining_map = pf_chain_map,
        view_of_entries = pf_entries,
        mfree = pf_mfree |
        pointer = p
      }
  in
    chaining_map
  end

(********************************************************************)

implement {tk}
get_entry_value_g1uint {length, index} {p} (node, index) =
  let
    val @{
          view_of_population_map = pf_pop_map,
          view_of_leaf_map = pf_leaf_map,
          view_of_chaining_map = pf_chain_map,
          view_of_entries = pf_entries,
          mfree = pf_mfree |
          pointer = p
        } = node

    stadef p_entries = entries_addr p
    val p_entries : ptr p_entries = uptr2ptr (entries_ptr p)
    macdef entries = !p_entries

    (* Temporarily make the entries uintptr instead of link_vt,
       so one can copy their data without consuming their views. *)
    prval _ =
      $UN.castview2void_at
        {@[uintptr][length]} {@[link_vt][length]} {p_entries}
        pf_entries

    prval _ = lemma_g1uint_param index
    val entry_value = entries[index]

    prval _ =
      $UN.castview2void_at
        {@[link_vt][length]} {@[uintptr][length]} {p_entries}
        pf_entries

    prval _ = node :=
      @{
        view_of_population_map = pf_pop_map,
        view_of_leaf_map = pf_leaf_map,
        view_of_chaining_map = pf_chain_map,
        view_of_entries = pf_entries,
        mfree = pf_mfree |
        pointer = p
      }
  in
    entry_value
  end

implement {tk}
get_entry_value_g1int (node, index) =
  get_entry_value_g1uint (node, g1int2uint<tk,sizeknd> index)

(********************************************************************)

implement {tk}
set_entry_value_g1uint {length, index} {p} (node, index, value) =
  {
    val @{
          view_of_population_map = pf_pop_map,
          view_of_leaf_map = pf_leaf_map,
          view_of_chaining_map = pf_chain_map,
          view_of_entries = pf_entries,
          mfree = pf_mfree |
          pointer = p
        } = node

    stadef p_entries = entries_addr p
    val p_entries : ptr p_entries = uptr2ptr (entries_ptr p)
    macdef entries = !p_entries

    (* Temporarily make the entries uintptr instead of link_vt.
       It seems convenient to do so. *)
    prval _ =
      $UN.castview2void_at
        {@[uintptr][length]} {@[link_vt][length]} {p_entries}
        pf_entries

    prval _ = lemma_g1uint_param index
    val _ = entries[index] := value

    prval _ =
      $UN.castview2void_at
        {@[link_vt][length]} {@[uintptr][length]} {p_entries}
        pf_entries

    prval _ = node :=
      @{
        view_of_population_map = pf_pop_map,
        view_of_leaf_map = pf_leaf_map,
        view_of_chaining_map = pf_chain_map,
        view_of_entries = pf_entries,
        mfree = pf_mfree |
        pointer = p
      }
  }

implement {tk}
set_entry_value_g1int (node, index, value) =
  set_entry_value_g1uint (node, g1int2uint<tk,sizeknd> index, value)

(********************************************************************)

implement {}
expand_node {length, index} {p} (node, length, index) =
  let
    val @{
          view_of_population_map = pf_pop_map,
          view_of_leaf_map = pf_leaf_map,
          view_of_chaining_map = pf_chain_map,
          view_of_entries = pf_entries,
          mfree = pf_mfree |
          pointer = p
        } = node

    stadef p0 = entries_addr p

    prval @(pf_left, pf_right) =
      array_v_subdivide2 {link_vt} {p0} {index, length - index}
                         pf_entries

    stadef new_length = length + 1
    prval _ =
      prop_verify {length - index == new_length - 1 - index} ()

    val new_length : size_t new_length = succ length

    val [q : addr]
        @{
          view_of_population_map = qf_pop_map,
          view_of_leaf_map = qf_leaf_map,
          view_of_chaining_map = qf_chain_map,
          view_of_left_entries = qf_left,
          view_of_new_entry = qf_entry,
          view_of_right_entries = qf_right,
          mfree = qf_mfree |
          pointer = q
        } = new_slotted_node_alloc<> {new_length, index}
                                     (new_length, index)
    prval _ = prop_verify {null < q} ()

    stadef q0 = entries_addr q

    val p0 : uptr p0 = entries_ptr p
    val q0 : uptr q0 = entries_ptr q

    val _ =
      array_move<link_vt>
        {index} {q0} {p0}
        (qf_left, pf_left | uptr2ptr q0, uptr2ptr p0, index)

    stadef p1 = entries_addr (p) + index * sizeof (link_vt)
    stadef q1 = entries_addr (q) + index * sizeof (link_vt)
                    + sizeof (link_vt?)

    val p1 : uptr p1 = uptr_add<link_vt> (p0, index)
    val q1 : uptr q1 =
      uptr_succ<link_vt?> (uptr_add<link_vt> (q0, index))

    val _ =
      array_move<link_vt>
        {length - index} {q1} {p1}
        (qf_right, pf_right | uptr2ptr q1, uptr2ptr p1,
                              length - index)

    prval pf_entries = 
      array_v_join2 {link_vt?!} {p0} {index, length - index}
                    (pf_left, pf_right)
    val _ =
      expired_node_vt_free
        @{
          view_of_population_map = pf_pop_map,
          view_of_leaf_map = pf_leaf_map,
          view_of_chaining_map = pf_chain_map,
          view_of_entries = pf_entries,
          mfree = pf_mfree |
          pointer = p
        }
  in
    @{
      view_of_population_map = qf_pop_map,
      view_of_leaf_map = qf_leaf_map,
      view_of_chaining_map = qf_chain_map,
      view_of_left_entries = qf_left,
      view_of_new_entry = qf_entry,
      view_of_right_entries = qf_right,
      mfree = qf_mfree |
      pointer = q
    }
  end

(********************************************************************)

implement {hash_vt}
start_new_tree (bits_source, hash_func, hash_storage, key_value) =
  let
    val _ = hash_func (key_value, hash_storage)

    val [bits : int] (pf_bits | bits) = bits_source (hash_storage, 0U)
    prval _ = bits_source_bits_bounds pf_bits
    prval _ = prop_verify {valid_bits (NUM_BITS, bits)} ()

    (* Throw away the hash that was computed. *)
    prval _ = $UN.castview2void_at{hash_vt?} (view@ hash_storage)

    (* This is a precondition of the routine. *)
    prval _ = $effmask_exn assertloc (0 <= bits)

    val population_map = (one << bits)
    val leaf_map = population_map
    val chaining_map = zero

    val @{
          view_of_population_map = pf_pop_map,
          view_of_leaf_map = pf_leaf_map,
          view_of_chaining_map = pf_chain_map,
          view_of_entries = pf_entries,
          mfree = pf_mfree |
          pointer = p
        } = new_length1_node_alloc ()

    val _ = uptr_set<uintptr> (pf_pop_map | population_map_ptr p,
                                            population_map)
    val _ = uptr_set<uintptr> (pf_leaf_map | leaf_map_ptr p,
                                             leaf_map)
    val _ = uptr_set<uintptr> (pf_chain_map | chaining_map_ptr p,
                                              chaining_map)

    prval @(pf_entry, pf_rest) = array_v_uncons pf_entries
    val _ =
      uptr_set<link_vt>
        (pf_entry | entries_ptr p, uintptr2link key_value)
    prval pf_rest = array_v_unnil_nil pf_rest
    prval pf_entries = array_v_cons (pf_entry, pf_rest)
  in
    @{
      view_of_population_map = pf_pop_map,
      view_of_leaf_map = pf_leaf_map,
      view_of_chaining_map = pf_chain_map,
      view_of_entries = pf_entries,
      mfree = pf_mfree |
      pointer = p
    }
  end

(********************************************************************)

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

fun {hash_vt : vt@ype}
get_subtree_entry__loop
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

implement {hash_vt}
get_subtree_entry (node, bits_source, hash_func, hash_storage,
                   key_test, key, depth, is_stored, key_value) =
  {
    val _ = hash_func (key, hash_storage)

    val _ =
      get_subtree_entry__loop<hash_vt>
        (node, bits_source, hash_storage, key_test, key, depth,
         is_stored, key_value)

    (* Throw away the hash that was computed. *)
    prval _ = $UN.castview2void_at{hash_vt?} (view@ hash_storage)
  }

(********************************************************************)

fun {}
replace_old_entry
        {length      : int | length <= bitsizeof (uintptr)}
        {index       : int | index < length}
        {key_value   : int}
        (node        : &node_vt (length) >> node_vt (new_length),
         index       : uint index,
         key_value   : uintptr key_value,
         is_new_slot : &bool? >> bool is_new_slot) :
    #[new_length : int | new_length == length]
    #[is_new_slot : bool | is_new_slot == false]
    void =
  begin
    node[index] := key_value;
    is_new_slot := false
  end

fun {}
expand_node_to_make_space_for_new_leaf
        {length    : int | length < bitsizeof (uintptr)}
        {bits      : int | valid_unexhausted_bits (NUM_BITS, bits)}
        {key_value : int}
        (node               : &node_vt (length) >>
                                  node_vt (new_length),
         length             : size_t length,
         bits               : int bits,
         population_map     : uintptr,
         leaf_map           : uintptr,
         chaining_map       : uintptr,
         bit_selection_mask : uintptr,
         key_value          : uintptr key_value,
         is_new_slot        : &bool? >> bool is_new_slot) :
    #[new_length : int | new_length == length + 1]
    #[is_new_slot : bool | is_new_slot == true]
    void =
  let
    val new_population_map = set_bit<> (population_map,
                                        bit_selection_mask)
    val new_leaf_map = set_bit<> (leaf_map, bit_selection_mask)
    val new_chaining_map = chaining_map

    val [new_index : int] @(_ | new_index) =
      get_popcount_low_bits (g1ofg0 new_population_map, i2u bits)
    val new_index = g1i2u new_index
    val _ = assertloc (new_index <= length)

    val @{
          view_of_population_map = pf_pop_map,
          view_of_leaf_map = pf_leaf_map,
          view_of_chaining_map = pf_chain_map,
          view_of_left_entries = pf_left,
          view_of_new_entry = pf_entry,
          view_of_right_entries = pf_right,
          mfree = pf_mfree |
          pointer = p
        } = expand_node<> {length, new_index}
                          (node, length, new_index)
    val _ =
      uptr_set<uintptr> (pf_pop_map | population_map_ptr p,
                                      new_population_map)
    val _ =
      uptr_set<uintptr> (pf_leaf_map | leaf_map_ptr p,
                                       new_leaf_map)
    val _ =
      uptr_set<uintptr> (pf_chain_map | chaining_map_ptr p,
                                        new_chaining_map)

    val p_entry =
      uptr_add<link_vt> (entries_ptr (p), new_index)
    val _ =
      uptr_set<link_vt>
        (pf_entry | p_entry, uintptr2link key_value)

    prval pf_right = array_v_cons (pf_entry, pf_right)
    prval pf_entries = array_v_join2 (pf_left, pf_right)
  in
    node :=
      @{
        view_of_population_map = pf_pop_map,
        view_of_leaf_map = pf_leaf_map,
        view_of_chaining_map = pf_chain_map,
        view_of_entries = pf_entries,
        mfree = pf_mfree |
        pointer = p
      };
    is_new_slot := true
  end

fn {}
start_new_subtree
        {bits : int | valid_unexhausted_bits (NUM_BITS, bits)}
        {old_key_value : int}
        (bits          : int bits,
         old_key_value : uintptr old_key_value) :
    [length : int | length == 1]
    node_vt (length) =
  let
    val population_map = (one << bits)
    val leaf_map = population_map
    val chaining_map = zero

    val @{
          view_of_population_map = pf_pop_map,
          view_of_leaf_map = pf_leaf_map,
          view_of_chaining_map = pf_chain_map,
          view_of_entries = pf_entries,
          mfree = pf_mfree |
          pointer = p
        } = new_length1_node_alloc ()

    val _ = uptr_set<uintptr> (pf_pop_map | population_map_ptr p,
                                            population_map)
    val _ = uptr_set<uintptr> (pf_leaf_map | leaf_map_ptr p,
                                             leaf_map)
    val _ = uptr_set<uintptr> (pf_chain_map | chaining_map_ptr p,
                                              chaining_map)

    prval @(pf_entry, pf_rest) = array_v_uncons pf_entries
    val _ =
      uptr_set<link_vt>
        (pf_entry | entries_ptr p, uintptr2link old_key_value)
    prval pf_rest = array_v_unnil_nil pf_rest
    prval pf_entries = array_v_cons (pf_entry, pf_rest)
  in
    @{
      view_of_population_map = pf_pop_map,
      view_of_leaf_map = pf_leaf_map,
      view_of_chaining_map = pf_chain_map,
      view_of_entries = pf_entries,
      mfree = pf_mfree |
      pointer = p
    }
  end

fun {hash_vt : vt@ype}
set_subtree_entry__loop
        {length : int | length <= bitsizeof (uintptr)}
        {node_p : addr}
        {p_slot : addr}
        {bits   : int | valid_unexhausted_bits (NUM_BITS, bits)}
        {hash2_is_set  : bool}
        {key_value     : int}
        {depth         : int}
        (pf_slot       : !(node_vt (length, node_p) @ p_slot) >>
                              node_vt (new_length) @ p_slot |
         p_slot        : ptr p_slot,
         bits          : int bits,
         bits_source   : !bits_source_cloptr (hash_vt, NUM_BITS) >> _,
         hash_func     : !hash_function_vt (hash_vt),
         hash_storage1 : &hash_vt >> _,
         hash_storage2 : &hash_vt >> _,
         hash2_is_set  : bool hash2_is_set,
         key_test      : !key_test_vt >> _,
         key_value     : uintptr key_value,
         depth         : uint depth,
         is_new_slot   : &bool? >> bool is_new_slot) :
    #[new_length : int | (new_length == length ||
                          new_length == length + 1)]
    #[is_new_slot : bool]
    void =
  let
    macdef node = (!p_slot)

    prval _ = lemma_node_vt_param {length} (node)
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
              in
                // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME
                is_new_slot := false // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME
                // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME
              end
            else if key_test (key_value, entry) then
              replace_old_entry<>
                (node, i2u index, key_value, is_new_slot)
            else
              let
                (* The next set of bits for the new entry. *)
                val [bits1 : int] (pf_bits1 | bits1) =
                  bits_source (hash_storage1, succ depth)
                prval _ = bits_source_bits_bounds pf_bits1

                (* The next set of bits for the old entry. *)
                val _ =
                  if not hash2_is_set then
                    {
                      prval _ =
                        $UN.castview2void_at{hash_vt?}
                          (view@ hash_storage2)
                      val _ = hash_func (entry, hash_storage2)
                    }
                val [bits2 : int] (pf_bits2 | bits2) =
                  bits_source (hash_storage2, succ depth)
                prval _ = bits_source_bits_bounds pf_bits2
              in
                if bits1 = BITS_SOURCE_EXHAUSTED |||
                   bits2 = BITS_SOURCE_EXHAUSTED then
                  (* Separate chaining is required. *)
                  let
                  in
                    // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME
                    is_new_slot := true // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME
                    // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME
                  end
                else
                  (* Create a new node, which will contain only the
                     old entry; store the pointer to it in the old
                     location; and then do a loop. *)
                  {
                    val [new_node_length : int] new_node =
                      start_new_subtree<> (bits2, g1ofg0 entry)

                    val _ = node[index] := node2uintptr new_node

                    val new_leaf_map =
                      clear_bit (leaf_map, bit_selection_mask)
                    val _ = set_leaf_map (node, new_leaf_map)

                    (* Unsafely create a view of a slot in the
                       node. (The node is not really "linear" as
                       as long as this view exists, but the
                       technique seems simple and untedious.) *)
                    extern praxi
                    create_slot_view :
                      () -<prf> node_vt (new_node_length)
                                  @ ((entries_addr node_p) +
                                        index * sizeof (link_vt))
                    prval pf_node_slot = create_slot_view ()

                    val node_tmp = node
                    val p_node_slot =
                      uptr_add<link_vt>
                        (entries_ptr (node_tmp.pointer), index)
                    val _ = ptr_set (pf_slot | p_slot, node_tmp)
                                        
                    val _ =
                      set_subtree_entry__loop
                        (pf_node_slot | uptr2ptr p_node_slot,
                         bits1, bits_source, hash_func,
                         hash_storage1, hash_storage2, true,
                         key_test, key_value, succ depth,
                         is_new_slot)

                    (* Consume the temporary, unsafe view. *)
                    prval _ = $UN.castview2void{void} pf_node_slot
                  }
              end
          end
        else
          (* One must work on a deeper node. *)
          let
          in
            // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME
            is_new_slot := false // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME
            // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME
          end
      end
    else
      let
        val [popcount : int] @(_ | length) =
          get_popcount (g1ofg0 population_map)
        prval _ = $UN.prop_assert {popcount == length} ()

        (* If the node were full, then entry_is_stored would
           have been true. *)
        val _ = assertloc (length < i2sz BITSIZEOF_UINTPTR)

        val leaf_map = get_leaf_map<> (node)
        val chaining_map = get_chaining_map<> (node)
      in
        expand_node_to_make_space_for_new_leaf<>
          (node, length, bits,
           population_map, leaf_map, chaining_map,
           bit_selection_mask, key_value, is_new_slot)
      end
  end

implement {hash_vt}
set_subtree_entry (node, bits_source, hash_func,
                   hash_storage1, hash_storage2,
                   key_test, key_value, depth, is_new_slot) =
  {
    val _ = hash_func (key_value, hash_storage1)

    (* For mere typechecking reasons, hash_storage2 needs to
       be treated as "initialized". *)
    prval _ = $UN.castview2void_at{hash_vt} (view@ hash_storage2)

    val [bits : int] (pf_bits | bits) =
      bits_source (hash_storage1, depth)
    prval _ = bits_source_bits_bounds pf_bits
    prval _ = prop_verify {valid_bits (NUM_BITS, bits)} ()

    (* This is a precondition of the routine: the bits source
       must return at least one bit. *)
    val _ = assertloc (bits <> BITS_SOURCE_EXHAUSTED)

    val _ =
      set_subtree_entry__loop<hash_vt>
        (view@ node | addr@ node, bits, bits_source, hash_func,
                      hash_storage1, hash_storage2, false,
                      key_test, key_value, depth, is_new_slot)

    (* Throw away the hashes. *)
    prval _ = $UN.castview2void_at{hash_vt?} (view@ hash_storage1)
    prval _ = $UN.castview2void_at{hash_vt?} (view@ hash_storage2)
  }

(********************************************************************)
