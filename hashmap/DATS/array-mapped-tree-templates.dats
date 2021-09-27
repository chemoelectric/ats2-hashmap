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

staload UN = "prelude/SATS/unsafe.sats"

(********************************************************************)

prval _ = $UN.prop_assert {sizeof (uintptr) == SIZEOF_UINTPTR} ()
prval _ = prop_verify {bitsizeof (uintptr) == BITSIZEOF_UINTPTR} ()

prval _ = prop_verify {sizeof (link_vt) == sizeof (uintptr)} ()
prval _ = prop_verify {sizeof (link_vt) == SIZEOF_UINTPTR} ()

symintr <<
infixl ( * ) <<
overload << with g0uint_lsl_uintptr

symintr >>
infixl ( * ) >>
overload >> with g0uint_lsr_uintptr

symintr <*>
infixl ( * ) <*>
overload <*> with g0uint_land_uintptr

symintr <+>
infixl ( * ) <+>
overload <+> with g0uint_lor_uintptr

symintr <~>
prefix ( * ) <~>
overload <~> with g0uint_lnot_uintptr

extern castfn
g1int2uint_int_uintpr :
  {i : int | 0 <= i} int i -<> uintptr i

implement
g1int2uint<intknd,uintptrknd> = g1int2uint_int_uintptr

macdef zero = g1int2uint<intknd,uintptrknd> 0
macdef one = g1int2uint<intknd,uintptrknd> 1

fn {}
bit_is_set (bits               : uintptr,
            bit_selection_mask : uintptr) :<> bool =
  (bits <*> bit_selection_mask) <> zero

fn {}
set_bit (bits               : uintptr,
         bit_selection_mask : uintptr) :<> uintptr =
  (bits <+> bit_selection_mask)

#define NIL list_vt_nil ()
#define :: list_vt_cons

(********************************************************************)

implement {}
uintptr2node (i) =
  let
    val p = uintptr2uptr i
    val _ = $effmask_exn (assertloc (uptr_isnot_null p))
  in
    uptr2node p
  end

implement {}
node2uintptr (node) =
  uptr2uintptr (node2uptr node)

(********************************************************************)

fn {}
population_map_ptr {p : addr}
                   (p : uptr p) :<>
    uptr (population_map_addr p) =
  p

fn {}
leaf_map_ptr {p : addr}
             (p : uptr p) :<>
    uptr (leaf_map_addr p) =
  uptr_succ<uintptr> (p)

fn {}
chaining_map_ptr {p : addr}
                 (p : uptr p) :<>
    uptr (chaining_map_addr p) =
  uptr_add<uintptr> (p, 2)

fn {}
entries_ptr {p : addr}
            (p : uptr p) :<>
    uptr (entries_addr p) =
  uptr_add<uintptr> (p, 3)

(********************************************************************)

fn {}
get_popcount {population_map : int}
             (population_map : uintptr population_map) :<>
    [popcount : int | 0 <= popcount; popcount <= BITSIZEOF_UINTPTR]
    @(POPCOUNT (population_map, popcount) | size_t popcount) =
  let
    val [popcount : int] (pf_popcount | popcount) =
      popcount<uintptrknd> (population_map)

    prval _ = popcount_is_nonnegative pf_popcount
    prval _ = prop_verify {0 <= popcount} ()

    val _ = $effmask_exn assertloc (popcount <= BITSIZEOF_UINTPTR)
  in
    @(pf_popcount | g1i2u popcount)
  end

fn {}
get_popcount_low_bits {population_map : int}
                      {i              : int | i < BITSIZEOF_UINTPTR}
                      (population_map : uintptr population_map,
                       i              : uint i) :<>
    [popcount : int | 0 <= popcount; popcount <= i]
    @(POPCOUNT_LOW_BITS (population_map, i, popcount) | int popcount) =
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
extract_static_length_of_node (node) =
  $UN.castvwtp0 node

(********************************************************************)

fn {}
node_alloc {length : int}
           (length : size_t length) :<!wrt>
    [p : addr | null < p]
    @(@[uintptr?][length + 3] @ p, mfree_gc_v p | uptr p) =
  let
    val size = length + (g1u2u 3U)
    val @(view, mfree | pointer) = array_ptr_alloc<uintptr> (size)
  in
    @(view, mfree | ptr2uptr pointer)
  end

fn {}
new_slotted_node_alloc
        {length, index : int | index < length}
        (length : size_t length,
         index  : size_t index) :<!wrt>
    [p : addr | null < p]
    new_slotted_node_vt (length, index, p) =
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

fn {}
new_length1_node_alloc () :<!wrt>
    [p : addr | null < p]
    new_length1_node_vt p =
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

fn {}
new_length2_node_alloc () :<!wrt>
    [p : addr | null < p]
    new_length2_node_vt p =
  let
    val [p : addr] @(pf_view, pf_mfree | p) =
      node_alloc<> {2} (i2sz 2)
    prval @(pf_pop_map, pf_view) = array_v_uncons pf_view
    prval @(pf_leaf_map, pf_view) = array_v_uncons pf_view
    prval @(pf_chain_map, pf_entries) = array_v_uncons pf_view
    prval _ =
      $UN.castview2void_at {@[link_vt?][2]} {@[uintptr?][2]}
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

fn {}
expired_node_vt_free
        {length : int}
        {p      : addr}
        (node   : expired_node_vt (length, p)) :<!wrt>
    void =
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

fn {}
get_population_map
        {length : int}
        {p      : addr}
        (node   : !node_vt (length, p) >> _) :<!ref>
    uintptr =
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

fn {}
get_leaf_map
        {length : int}
        {p      : addr}
        (node   : !node_vt (length, p) >> _) :<!ref>
    uintptr =
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

(********************************************************************)

fn {}
get_chaining_map
        {length : int}
        {p      : addr}
        (node   : !node_vt (length, p) >> _) :<!ref>
    uintptr =
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

fn {tk : tkind}
get_entry_value_g1uint
        {length, index : int | index < length}
        {p      : addr}
        (node   : !node_vt (length, p) >> _,
         index  : g1uint (tk, index)) :<!ref>
    uintptr =
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

fn {tk : tkind}
get_entry_value_g1int
        {length, index : int | 0 <= index; index < length}
        {p      : addr}
        (node   : !node_vt (length, p) >> _,
         index  : g1int (tk, index)) :<!ref>
    uintptr =
  get_entry_value_g1uint (node, g1int2uint<tk,sizeknd> index)

overload get_entry_value with get_entry_value_g1uint
overload get_entry_value with get_entry_value_g1int
overload [] with get_entry_value

(********************************************************************)

fn {tk : tkind}
set_entry_value_g1uint
        {length, index : int | index < length}
        {p      : addr}
        (node   : !node_vt (length, p) >> _,
         index  : g1uint (tk, index),
         value  : uintptr) :<!refwrt> void =
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

fn {tk : tkind}
set_entry_value_g1int
        {length, index : int | 0 <= index; index < length}
        {p      : addr}
        (node   : !node_vt (length, p) >> _,
         index  : g1int (tk, index),
         value  : uintptr) :<!refwrt> void =
  set_entry_value_g1uint (node, g1int2uint<tk,sizeknd> index, value)

overload set_entry_value with set_entry_value_g1uint
overload set_entry_value with set_entry_value_g1int
overload [] with set_entry_value

(********************************************************************)

fn {}
expand_node {length, index : int | 0 <= index; index <= length}
            {p      : addr}
            (node   : node_vt (length, p),
             length : size_t length,
             index  : size_t index) :
    [q : addr | null < q]
    slotted_node_vt (length + 1, index, q) =
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

(* // We probably do not want this, because we wrote set_entry_value
   // instead, and it is "safe enough".
fn {}
node_vt_to_slotted_node_vt
        {length, index : int | index < length}
        {p     : addr}
        (node  : node_vt (length, p),
         index : size_t index) :<!ref>
    (* Returns the original node_vt recast as a slotted_node_vt. *)
    slotted_node_vt (length, index, p) =
  let
    val @{
          view_of_population_map = pf_pop_map,
          view_of_leaf_map = pf_leaf_map,
          view_of_chaining_map = pf_chain_map,
          view_of_entries = pf_entries,
          mfree = pf_mfree |
          pointer = p
        } = node

    prval _ = lemma_g1uint_param index

    prval @(pf_left, pf_right) =
      array_v_subdivide2 {link_vt} {entries_addr p}
                         {index, length - index}
                         pf_entries
    prval @(pf_entry, pf_right) = array_v_uncons pf_right

    prval _ =
      $UN.castview2void_at {link_vt?} {link_vt} pf_entry

    val slotted_node =
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
  in
    slotted_node
  end
*)

(*
fn {}
slotted_node_vt_to_node_vt
        {length, index : int | index < length}
        {p             : addr}
        (node          : slotted_node_vt (length, index, p),
         index         : size_t index,
         value         : uintptr,
         old_pop_map   : uintptr,
         old_leaf_map  : uintptr,
         old_chain_map : uintptr,
         is_leaf       : bool) :<!wrt>
    node_vt (length, p) =
  let
    val new_bit = (one << (sz2i index))
    val new_pop_map = old_pop_map <+> new_bit
    val new_leaf_map =
      if is_leaf then
        old_leaf_map <+> new_bit
      else
        old_leaf_map <*> (<~> new_bit)

    val @{
        view_of_population_map = pf_pop_map,
        view_of_leaf_map = pf_leaf_map,
        view_of_chaining_map = pf_chain_map,
        view_of_left_entries = pf_left,
        view_of_new_entry = pf_entry,
        view_of_right_entries = pf_right,
        mfree = pf_mfree |
        pointer = p
      } = node

    val () = ptr_set<uintptr> (pf_pop_map | p, new_pop_map)

    val p_leaf_map = ptr_succ<uintptr> (p)
    val leaf_map =
      ptr_set<uintptr> (pf_leaf_map | p_leaf_map, new_leaf_map)

    prval _ = lemma_g1uint_param index

    val p_entry = ptr_add<uintptr> (p, i2sz 2 + index)
    val () = ptr_set<uintptr> (pf_entry | p_entry, value)

    prval _ = $UN.castview2void_at {link_vt} {uintptr} pf_entry

    prval pf_entry_right = array_v_cons (pf_entry, pf_right)
    prval pf_entries = array_v_join2 (pf_left, pf_entry_right)
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
*)

(********************************************************************)

implement {vt}
leaf_free_vt_is_null (closure) =
  ptr_is_null ($UN.castvwtp1{Ptr} closure)

fn {vt : vtype}
apply_leaf_free (leaf_free : !leaf_free_vt (vt) >> _,
                 leaf      : vt) : void =
  if not (leaf_free_vt_is_null leaf_free) then
    (* The leaf is of a linear type, and must be freed.
       Free it now. *)
    leaf_free (leaf)
  else
    (* The leaf_free closure is actually a null pointer.
       Assume the leaf is of a nonlinear type that needs
       no freeing. (This way we avoid calling a closure.) *)
    {
      prval _ = $UN.castvwtp0{vt?!} leaf
    }

(********************************************************************)

vtypedef node_list_vt (n : int) = list_vt (node_vt, n)
vtypedef node_list_vt = [n : int] node_list_vt n

vtypedef more_nodes_vt (n : int) = list_vt (node_list_vt, n)
vtypedef more_nodes_vt = [n : int] more_nodes_vt n

fun {}
skip_unpopulated (population : uintptr,
                  leaves     : uintptr,
                  chains     : uintptr) :
    @(uintptr, uintptr, uintptr) =
  if bit_is_set<> (population, one) then
    @(population, leaves, chains)
  else
    skip_unpopulated<> (population >> 1, leaves >> 1, chains >> 1)

(* Rather than recursively deepen the stack, let us free nodes while
   also building up lists of more nodes to be freed. *)
fn {vt : vtype}
free_nodes (nodes      : node_list_vt,
            leaf_free  : !leaf_free_vt (vt) >> _,
            more_nodes : &more_nodes_vt? >> more_nodes_vt) :
    void =
  let
    typedef link_t = link_vt?!

    extern castfn
    link2uintptr : link_t -<> uintptr

    fun {vt : vtype}
    for_each_node
            {n          : int | 0 <= n} .<n>.
            (nodes      : node_list_vt n,
             leaf_free  : !leaf_free_vt (vt) >> _,
             more_nodes : more_nodes_vt) : more_nodes_vt =
      case+ nodes of
      | ~ NIL => more_nodes
      | ~ node :: tail =>
        let
          val [length : int] node = extract_static_length_of_node node

          val population_map = get_population_map<> (node)
          val leaf_map = get_leaf_map<> (node)
          val chaining_map = get_chaining_map<> (node)

          prval _ = lemma_node_vt_param {length} node

          val [popcount : int] @(_ | length) =
            get_popcount (g1ofg0 population_map)
          prval _ = $UN.prop_assert {popcount == length} ()

          fun {vt : vtype}
          for_each_bit
                  {p_entries  : addr}
                  {restlen    : int | 0 <= restlen; restlen <= length}
                  .<restlen>.
                  (pf_entries : !(@[link_vt][restlen] @ p_entries)
                                  >> @[link_t][restlen] @ p_entries |
                   leaf_free  : !leaf_free_vt (vt) >> _,
                   population : uintptr,
                   leaves     : uintptr,
                   chains     : uintptr,
                   p_entries  : uptr p_entries,
                   restlen    : size_t restlen,
                   new_nodes  : node_list_vt) : node_list_vt =
            if restlen = i2sz 0 then
              let
                prval _ = pf_entries :=
                  array_v_unnil_nil {link_vt, link_t} pf_entries
              in
                new_nodes
              end
            else
              let
                prval _ = lemma_list_vt_param new_nodes

                prval _ = lemma_array_v_param pf_entries
                prval _ = prop_verify {0 <= restlen} ()

                val @(population, leaves, chains) =
                  skip_unpopulated<> (population, leaves, chains)
                val is_leaf = bit_is_set<> (leaves, one)
                val is_chain = (is_leaf && bit_is_set<> (leaves, one))

                (* Separate the entries into the first entry and
                   and array of the remaining entries. *)
                prval @(pf_entry, pf_rest) = array_v_uncons pf_entries
                val p_rest = uptr_succ<link_vt> (p_entries)

                (* Render that first entry "expired". *)
                prval _ =
                  $UN.castview2void_at {link_t} {link_vt} {p_entries}
                                       pf_entry

                fn {}
                free_one_leaf
                        (pf_entry  : !(link_t @ p_entries) >> _ |
                         leaf_free : !leaf_free_vt (vt) >> _) :
                    void =
                  if not (leaf_free_vt_is_null leaf_free) then
                    (* The leaf is of a linear type, and must be
                       freed. Free it now. *)
                    let
                      val entry =
                        uptr_get<link_t> (pf_entry | p_entries)
                    in
                      leaf_free
                        ($UN.castvwtp0{vt}
                          (uptr2ptr
                            (uintptr2uptr (link2uintptr entry))))
                    end

                fn {}
                free_leaf_list
                        (pf_entry  : !(link_t @ p_entries) >> _ |
                         leaf_free : !leaf_free_vt (vt) >> _) :
                    void =
                  {
                    fun
                    loop {n : int | 0 <= n} .<n>.
                         (pf_entry  : !(link_t @ p_entries) >> _ |
                          leaf_free : !leaf_free_vt (vt) >> _,
                          lst       : list_vt (uintptr, n)) : void =
                      case+ lst of
                      | ~ NIL => ()
                      | ~ head :: tail =>
                        let
                          val leaf = $UN.castvwtp0{vt} head
                        in
                          apply_leaf_free (leaf_free, leaf);
                          loop (pf_entry | leaf_free, tail)
                        end
                    val entry = uptr_get<link_t> (pf_entry | p_entries)
                    val entry_p = uintptr2ptr (link2uintptr entry)
                    val lst = $UN.castvwtp0{List1_vt uintptr} entry_p
                    val () = loop (pf_entry | leaf_free, lst)
                  }

                fn {}
                free_one_entry
                        (pf_entry  : !(link_t @ p_entries) >> _ |
                         leaf_free : !leaf_free_vt (vt) >> _,
                         new_nodes  : node_list_vt) : node_list_vt =
                  if not is_leaf then
                    (* The expired entry is a subnode, and must be
                       freed. Add it to a list for freeing later. *)
                    let
                      val entry =
                        uptr_get<link_t> (pf_entry | p_entries)
                      val entry_p = uintptr2uptr (link2uintptr entry)
                      val _ = assertloc (uptr_isnot_null entry_p)
                      val next_node = uptr2node entry_p
                      prval _ = lemma_list_vt_param new_nodes
                    in
                      next_node :: new_nodes
                    end
                  else if is_chain then
                    (* The expired entry is a separate chain of
                       leaves: a linked list. *)
                    begin
                      if not (leaf_free_vt_is_null leaf_free) then
                        free_leaf_list<> (pf_entry | leaf_free);
                      new_nodes
                    end
                  else
                    begin
                      (* The expired entry is a leaf without
                         chaining. *)
                      free_one_leaf<> (pf_entry | leaf_free);
                      new_nodes
                    end

                (* Free the first entry, or list it to be freed
                   later. *)
                val new_nodes =
                  free_one_entry (pf_entry | leaf_free, new_nodes)

                (* For each of the remaining entries, either free
                   it now or list it to be freed later. *)
                val result =
                  for_each_bit<vt>
                    {p_entries + sizeof (link_vt)} {restlen - 1}
                    (pf_rest | leaf_free, population, leaves,
                               chains, p_rest, pred restlen,
                               new_nodes)

                (* Recombine the views. *)
                prval _ = pf_entries :=
                  array_v_cons (pf_entry, pf_rest)
              in
                result
              end

          val @{
                view_of_population_map = pf_pop_map,
                view_of_leaf_map = pf_leaf_map,
                view_of_chaining_map = pf_chain_map,
                view_of_entries = pf_entries,
                mfree = pf_mfree |
                pointer = p
              } = node
          val new_nodes =
            for_each_bit<vt>
              {..} {length}
              (pf_entries | leaf_free, population_map, leaf_map,
                            chaining_map, entries_ptr p, length, NIL)
          val node : expired_node_vt =
            @{
              view_of_population_map = pf_pop_map,
              view_of_leaf_map = pf_leaf_map,
              view_of_chaining_map = pf_chain_map,
              view_of_entries = pf_entries,
              mfree = pf_mfree |
              pointer = p
            }

          (* Having freed its leaves, and listed its subnodes
             for later handling, now free the node itself. *)
          val _ = expired_node_vt_free node

          prval _ = lemma_list_vt_param more_nodes
        in
          for_each_node<vt> (tail, leaf_free, new_nodes :: more_nodes)
        end

    prval _ = lemma_list_vt_param nodes
  in
    more_nodes := for_each_node<vt> (nodes, leaf_free, NIL)
  end

fun {vt : vtype}
free_more_nodes (leaf_free  : !leaf_free_vt (vt) >> _,
                 more_nodes : more_nodes_vt) : void =
  (* The more_nodes list may temporarily grow, but should
     eventually shrink to NIL. *)
  case+ more_nodes of
  | ~ NIL => ()
  | ~ nodes :: tail =>
    let
      var yet_more_nodes : more_nodes_vt
    in
      free_nodes<vt> (nodes, leaf_free, yet_more_nodes);
      free_more_nodes<vt>
        (leaf_free, list_vt_reverse_append (yet_more_nodes, tail))
    end

implement {vt}
node_vt_free (node, leaf_free) =
  free_more_nodes<vt> (leaf_free, ((node :: NIL) :: NIL))  

(********************************************************************)

implement {hash_vt}
start_new_tree (bits_source, hash_func, hash_storage, key_value) =
  let
    val () = hash_func (key_value, hash_storage)

    val [bits : int] (pf_bits | bits) = bits_source (hash_storage, 0U)
    prval _ = bits_source_bits_bounds pf_bits
    prval _ = prop_verify {BITS_SOURCE_EXHAUSTED <= bits} ()
    prval _ = prop_verify {bits_maxval (NUM_BITS, bits)} ()

    (* Throw away the hash that was computed. *)
    prval _ = $UN.castview2void_at{hash_vt?} (view@ hash_storage)

    (* FIXME: The following is really a precondition of
              start_new_tree that we have not yet managed
              to enforce through typechecking. *)
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
    prval _ = prop_verify {BITS_SOURCE_EXHAUSTED <= bits} ()
    prval _ = prop_verify {bits_maxval (NUM_BITS, bits)} ()
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
            val () =
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
    val () = hash_func (key, hash_storage)

    val _ =
      get_subtree_entry__loop<hash_vt>
        (node, bits_source, hash_storage, key_test, key, depth,
         is_stored, key_value)

    (* Throw away the hash that was computed. *)
    prval _ = $UN.castview2void_at{hash_vt?} (view@ hash_storage)
  }

(********************************************************************)









(*
implement {hash_vt}
start_new_tree (bits_source, hash_data, value) =
  let
    val [bits : int] (pf_bits | bits) = bits_source (hash_data, 0U)
    prval _ = bits_source_bits_bounds pf_bits
    prval _ = prop_verify {BITS_SOURCE_EXHAUSTED <= bits} ()
    prval _ = prop_verify {bits_maxval (NUM_BITS, bits)} ()

    (* FIXME: The following is really a precondition of
              start_new_tree that we have not yet managed
              to enforce through typechecking. *)
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
        (pf_entry | entries_ptr p, $UN.castvwtp0{link_vt} value)
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
*)

(*
(********************************************************************)

fun {}
replace_old_entry
        {length      : int | length <= bitsizeof (uintptr)}
        {index       : int | index < length}
        (node        : &node_vt (length) >> node_vt (new_length),
         index       : uint index,
         value       : uintptr,
         is_new_slot : &bool? >> bool is_new_slot) :
    #[new_length : int | new_length == length]
    #[is_new_slot : bool | is_new_slot == false]
    void =
  begin
    node[index] := value;
    is_new_slot := false
  end

fun {}
expand_node_to_make_space_for_new_leaf
        {length             : int | length < bitsizeof (uintptr)}
        {bits               : int | 0 <= bits;
                                    bits_maxval (NUM_BITS, bits)}
        (node               : &node_vt (length) >>
                                  node_vt (new_length),
         length             : size_t length,
         bits               : int bits,
         population_map     : uintptr,
         leaf_map           : uintptr,
         chaining_map       : uintptr,
         bit_selection_mask : uintptr,
         value              : uintptr,
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
        (pf_entry | p_entry, $UN.castvwtp0{link_vt} value)

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
        {bits      : int | 0 <= bits; bits_maxval (NUM_BITS, bits)}
        (bits      : int bits,
         old_value : uintptr) :
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
        (pf_entry | entries_ptr p, $UN.castvwtp0{link_vt} old_value)
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

fun {hash_vt, key_vt : vt@ype}
set_subtree_entry__loop
        {length      : int | length <= bitsizeof (uintptr)}
        {node_p      : addr | null < node_p}
        {bits        : int | 0 <= bits;
                             bits_maxval (NUM_BITS, bits)}
        (node        : &node_vt (length, node_p) >>
                          node_vt (new_length),
         bits        : int bits,
         bits_source : !bits_source_cloptr (hash_vt, NUM_BITS) >> _,
         hash_data   : &hash_vt >> _,
         key_test    : !key_test_vt (key_vt) >> _,
         key_data    : &key_vt >> _,
         depth       : uint,
         value       : uintptr,
         is_new_slot : &bool? >> bool is_new_slot) :
    #[new_length : int | (new_length == length ||
                              new_length == length + 1)]
    #[is_new_slot : bool]
    void =
  let
    prval _ = lemma_node_vt_param {length} node
    prval _ = prop_verify {0 < length} ()

    val population_map = get_population_map<> (node)
    val bit_selection_mask = (one << bits)
    val entry_is_stored =
      bit_is_set<> (population_map, bit_selection_mask)

    fun {hash_vt, key_vt : vt@ype}
    set_subtree_entry__loop2
            {length      : int | length <= bitsizeof (uintptr)}
            {node_p      : addr | null < node_p}
            {bits        : int | 0 <= bits;
                                 bits_maxval (NUM_BITS, bits)}
            {slot_p      : addr}
            (pf_slot     : !(node_vt (length, node_p) @ slot_p) >>
                              node_vt (new_length) @ slot_p |
             slot_p      : ptr slot_p,
             bits        : int bits,
             bits_source : !bits_source_cloptr (hash_vt, NUM_BITS) >> _,
             hash_data   : &hash_vt >> _,
             key_test    : !key_test_vt (key_vt) >> _,
             key_data    : &key_vt >> _,
             depth       : uint,
             value       : uintptr,
             is_new_slot : &bool? >> bool is_new_slot) :
        #[new_length : int | (new_length == length ||
                                  new_length == length + 1)]
        #[is_new_slot : bool]
        void =
      set_subtree_entry__loop<hash_vt,key_vt>
        {length} {node_p} {bits}
        (!slot_p, bits, bits_source, hash_data,
                      key_test, key_data, depth, value, is_new_slot)
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
            else if key_test (key_data, entry) then
              replace_old_entry<>
                (node, i2u index, value, is_new_slot)
            else
              let
                val [bits : int] (pf_bits | bits) =
                  bits_source (hash_data, depth)
                prval _ = bits_source_bits_bounds pf_bits
              in
                if bits = BITS_SOURCE_EXHAUSTED then
                  (* Separate chaining is required. *)
                  let
                  in
                    // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME
                    is_new_slot := true // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME
                    // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME
                  end
                else
                  (* Create a new node, which will contain only the
                     old entry, and then do a loop. *)
                  {
                    prval @(pf_left, pf_right) =
                      array_v_subdivide2 {link_vt}
                                         {entries_addr node_p}
                                         {index, length - index}
                                         (node.view_of_entries)
                    prval @(pf_entry, pf_right) =
                      array_v_uncons pf_right

                    stadef p_entry =
                      (entries_addr node_p) + index * sizeof (link_vt)
                    val up_entry : uptr p_entry =
                      uptr_add<link_vt>
                        (entries_ptr (node.pointer), index)
                    val p_entry : ptr p_entry =
                      uptr2ptr {p_entry} up_entry

                    val _ = assertloc (ptr_isnot_null p_entry)

                    prval _ =
                      $UN.castview2void_at
                        {uintptr} {link_vt} {p_entry}
                        pf_entry

                    val [new_length : int] new_node =
                      start_new_subtree<> (bits, entry)
                    prval _ = prop_verify {new_length == 1} ()
                    val _ =
                      ptr_set<uintptr>
                        (pf_entry | p_entry, node2uintptr new_node)

                    prval _ =
                      $UN.castview2void_at
                        {node_vt (new_length)} {uintptr} {p_entry}
                        pf_entry

                    val _ =
                      set_subtree_entry__loop2
                        (pf_entry | p_entry, bits, bits_source,
                         hash_data, key_test, key_data, succ depth,
                         value, is_new_slot)

                    prval _ =
                      $UN.castview2void_at
                        {link_vt} {node_vt} {p_entry}
                        pf_entry

                    prval pf_right = array_v_cons (pf_entry, pf_right)
                    prval _ = node.view_of_entries :=
                      array_v_join2 {link_vt} {entries_addr node_p}
                                    {index, length - index}
                                    (pf_left, pf_right)
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
           bit_selection_mask, value, is_new_slot)
      end
  end

implement {hash_vt, key_vt}
set_subtree_entry {length}
                  (node, bits_source, hash_data, key_test,
                   key_data, depth, value, is_new_slot) =
  {
    val [bits : int] (pf_bits | bits) = bits_source (hash_data, depth)
    prval _ = bits_source_bits_bounds pf_bits
    prval _ = prop_verify {BITS_SOURCE_EXHAUSTED <= bits} ()
    prval _ = prop_verify {bits_maxval (NUM_BITS, bits)} ()

    (* FIXME: This is really a precondition of the routine, and
              ideally should be enforced by typechecking. *)
    val _ = assertloc (bits <> BITS_SOURCE_EXHAUSTED)

    val _ =
      set_subtree_entry__loop
        {length} {..} {bits}
        (node, bits, bits_source, hash_data,
         key_test, key_data, depth, value, is_new_slot)
  }

(********************************************************************)

fn {key_vt : vt@ype}
get_leaf_value
        {length    : int | length <= bitsizeof (uintptr)}
        {bits      : int | bits_maxval (NUM_BITS, bits)}
        (node      : !node_vt (length) >> _,
         bits      : uint bits,
         key_test  : !key_test_vt (key_vt) >> _,
         key_data  : &key_vt >> _,
         is_last   : &bool? >>
                       [is_last : bool | is_stored || is_last]
                       bool is_last,
         is_stored : &bool? >> bool is_stored,
         value     : &uintptr? >>
                       [u : int | is_stored || u == 0]
                       uintptr u) :
    #[is_stored : bool] void =
  let
    prval _ = lemma_node_vt_param {length} node
    prval _ = prop_verify {0 < length} ()

    prval _ = lemma_g1uint_param bits
    prval _ = prop_verify {0 <= bits} ()

    val population_map = get_population_map<> (node)
    val bit_selection_mask = (one << (u2i bits))
    val entry_is_stored =
      bit_is_set<> (population_map, bit_selection_mask)
  in
    if entry_is_stored then
      let
        val leaf_map = get_leaf_map<> (node)
        val entry_is_leaf =
          bit_is_set<> (leaf_map, bit_selection_mask)

        val [index : int] @(_ | index) =
          get_popcount_low_bits (g1ofg0 population_map, bits)
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
                       (key_test : !key_test_vt (key_vt) >> _,
                        key_data : &key_vt >> _,
                        lst      : !list_vt (uintptr, n) >> _) :
                    @(bool, uintptr) =
                  case+ lst of
                  | NIL => @(false, zero)
                  | @ head :: tail =>
                    let
                      val key_matches = key_test (key_data, head)
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
                            search {n - 1} (key_test, key_data, tail)
                          prval _ = fold@ lst
                        in
                          result
                        end
                    end
                val lst =
                  $UN.castvwtp0{List_vt uintptr} (uintptr2ptr entry)
                prval _ = lemma_list_vt_param lst
                val @(is_found, pointer) =
                  search (key_test, key_data, lst)
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
                val key_matches = key_test (key_data, entry)
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

fun {hash_vt, key_vt : vt@ype}
get_subtree_entry__loop
        {length      : int | length <= bitsizeof (uintptr)}
        (node        : !node_vt (length) >> _,
         bits_source : !bits_source_cloptr (hash_vt, NUM_BITS) >> _,
         hash_data   : &hash_vt >> _,
         key_test    : !key_test_vt (key_vt) >> _,
         key_data    : &key_vt >> _,
         depth       : uint,
         is_stored   : &bool? >> bool is_stored,
         value       : &uintptr? >>
                          [u : int | is_stored || u == 0]
                          uintptr u) :
    #[is_stored : bool] void =
  let
    val [bits : int] (pf_bits | bits) = bits_source (hash_data, depth)
    prval _ = bits_source_bits_bounds pf_bits
    prval _ = prop_verify {BITS_SOURCE_EXHAUSTED <= bits} ()
    prval _ = prop_verify {bits_maxval (NUM_BITS, bits)} ()
  in
    if bits = BITS_SOURCE_EXHAUSTED then
      begin
        is_stored := false;
        value := zero
      end
    else
      let
        var is_last : bool
      in
        get_leaf_value<key_vt>
          {length} {bits}
          (node, i2u bits, key_test, key_data,
           is_last, is_stored, value);
        if not is_last then
          {
            val [length1 : int] [p1 : addr] next_node =
              uintptr2node value
            prval _ = lemma_node_vt_param {length1} {p1} (next_node)
            val () =
              get_subtree_entry__loop<hash_vt,key_vt>
                (next_node, bits_source, hash_data,
                 key_test, key_data, succ depth,
                 is_stored, value)
            prval _ = $UN.castvwtp0{uptr} next_node
          }
      end
  end

implement {hash_vt, key_vt}
get_subtree_entry {length} (node, bits_source, hash_data, key_test,
                            key_data, depth, is_stored, value) =
  get_subtree_entry__loop<hash_vt,key_vt>
    {length} (node, bits_source, hash_data, key_test, key_data,
              depth, is_stored, value)

(********************************************************************)
*)
