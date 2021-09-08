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

#define ATS_DYNLOADFLAG 0

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

#include "hashmap/HATS/config.hats"

staload "hashmap/SATS/array-mapped-tree.sats"

staload "hashmap/SATS/count-one-bits.sats"
staload _ = "hashmap/DATS/count-one-bits.dats"

(********************************************************************)

(*

References:
  [1] Phil Bagwell, "Fast and space efficient trie searches", 2000.
  [2] Phil Bagwell, "Ideal hash trees", 2001.


The implementation below structures the nodes differently from how
Bagwell [2] does.

Of the following reasons for doing this, the first is by far the more
important:

  * Bagwell's toggling of the LSB of a pointer is incompatible with
    Boehm GC. The collector might (and surely often would) collect
    nodes that were pointed to by pointers that had their LSB set.

  * Furthermore, Bagwell's scheme would not work if, for any reason,
    an object might be placed at an odd address. (This is not
    typical of how things are done, but it COULD be done, for
    instance, on AMD64.)

  * The structures implemented here have obvious uses as integer maps,
    integer sets, hash sets, etc.

In the implementation below, an internal node is laid out as follows:

    population_map (uintptr)   -- used to compute indices into the
                                  array of *this* node.
    node_kind_map  (uintptr)   -- if a bit is set, the corresponding
                                  array entry is or points to a
                                  leaf node.
    entry 0        (uintptr)
    entry 1        (uintptr)
    entry 2        (uintptr)
       .
       .
       .
    entry N        (uintptr)   -- where N < sizeof (uintptr)

*)

(********************************************************************)

stadef bitsizeof (t : vt@ype) = 8 * sizeof (t)

prval _ = $UNSAFE.prop_assert {sizeof (uintptr) == SIZEOF_UINTPTR} ()
prval _ = prop_verify {bitsizeof (uintptr) == BITSIZEOF_UINTPTR} ()

symintr <<
infixl ( * ) <<
overload << with g0uint_lsl_uintptr

symintr &
infixl ( * ) &
overload & with g0uint_land_uintptr

(********************************************************************)

viewdef node_v (length : int, p : addr) =
  @[uintptr][length + 2] @ p

vtypedef node_vt (length : int, p : addr) =
  @(node_v (length, p) | ptr p)
vtypedef node_vt (length : int) =
  [p : addr] node_vt (length, p)
vtypedef node_vt =
  [length : int] node_vt (length)

extern praxi
lemma_node_v_param :
  {length : int} {p : addr}
  (!node_v (length, p) >> _) -<prf> [0 <= length] void

datavtype tree_vt (size : int) =
| {size == 0}
  tree_vt_nil of ()
| {0 < size}
  tree_vt_node of @(size_t size, node_vt)

assume array_mapped_tree_vt (entry_count : int) =
  tree_vt (entry_count : int)

(********************************************************************)

primplement
lemma_array_mapped_tree_vt_param (tree) =
  case+ tree of
  | tree_vt_nil () => ()
  | tree_vt_node _ => ()

implement
array_mapped_tree_is_empty (tree) =
  case+ tree of
  | tree_vt_nil () => true
  | tree_vt_node _ => false

implement
array_mapped_tree_size (tree) =
  case+ tree of
  | tree_vt_nil () => i2sz 0
  | tree_vt_node @(size, _) => size

(********************************************************************)

typedef subtree_entry_t =
  @{
    entry_is_stored = bool,
    entry_value = uintptr
  }

fn {}
get_node_entry {length : int | length <= bitsizeof (uintptr)}
               {i      : int | i < length}
               (node   : &node_vt (length) >> _,
                i      : uint i) :<!ref>
    @(bool,      (* Is the entry a leaf? *)
      subtree_entry_t) =
  let
    macdef zero = g1int2uint<intknd,uintptrknd> 0
    macdef one = g1int2uint<intknd,uintptrknd> 1

    val @(pf_node | p_node) = node
    prval _ = lemma_node_v_param {length} pf_node
    macdef node_array = !p_node

    val population_map = node_array[0]
    val bit_selection_mask = (one << (u2i i))
    val is_stored = ((population_map & bit_selection_mask) <> zero)

    val result =
      if is_stored then
        let
          val node_kind_map = node_array[1]
          val is_leaf = ((node_kind_map & bit_selection_mask) <> zero)

          val [index : int] (pf_index | index) =
            popcount_low_bits<uintptrknd> (g1ofg0 population_map, i)
          prval _ = popcount_low_bits_is_nonnegative pf_index
          prval _ = popcount_low_bits_bound pf_index
          prval _ = prop_verify {0 <= index} ()
          prval _ = prop_verify {index <= i} ()
          prval _ = prop_verify {index < length} ()

          val entry = node_array[index + 2]
        in
          @(is_leaf, @{ entry_is_stored = true, entry_value = entry })
        end
      else
        @(true, @{ entry_is_stored = false, entry_value = zero })

    prval _ = $effmask_wrt (node := @(pf_node | p_node))
  in
    result
  end

(*
fn {}
get_subtree_entry {length : int | length <= bitsizeof (uintptr)}
                  {i      : int | i < length}
                  (node   : &node_vt (length) >> _,
                   i      : uint i) :<!ref>
    subtree_entry_t =
  let
*)

(********************************************************************)
