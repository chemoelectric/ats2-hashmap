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

staload "hashmap/SATS/array-mapped-tree.sats"

staload "hashmap/SATS/count-one-bits.sats"
staload _ = "hashmap/DATS/count-one-bits.dats"

staload "hashmap/SATS/bits-source.sats"

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

#define NUM_BITS SIZEOF_BITINDEXOF_UINTPTR

stadef bitsizeof (t : vt@ype) = 8 * sizeof (t)

prval _ = $UNSAFE.prop_assert {sizeof (uintptr) == SIZEOF_UINTPTR} ()
prval _ = prop_verify {bitsizeof (uintptr) == BITSIZEOF_UINTPTR} ()

symintr <<
infixl ( * ) <<
overload << with g0uint_lsl_uintptr

symintr &
infixl ( * ) &
overload & with g0uint_land_uintptr

extern castfn
g1int2uint_int_uintpr :
  {i : int | 0 <= i} int i -<> uintptr i

implement
g1int2uint<intknd,uintptrknd> = g1int2uint_int_uintptr

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
  {length : int}
  {p : addr}
  (!node_v (length, p) >> _) -<prf>
    [0 < length] void

extern praxi
lemma_node_v_bound :
  {length : int}
  {p : addr}
  (!node_v (length, p) >> _) -<prf>
    [length <= bitsizeof (uintptr)] void

extern praxi
lemma_node_vt_param :
  {length : int}
  {p : addr}
  (!node_vt (length, p) >> _) -<prf>
    [0 < length] void

extern prfn
lemma_node_vt_bound :
  {length : int}
  {p : addr}
  (!node_vt (length, p) >> _) -<prf>
    [length <= bitsizeof (uintptr)] void

datavtype tree_vt (size : int) =
| {size == 0}
  tree_vt_nil of ()
| {0 < size}
  tree_vt_node of @(size_t size, node_vt)

assume array_mapped_tree_vt (entry_count : int) =
  tree_vt (entry_count : int)

(********************************************************************)

primplement
lemma_node_vt_param {length} {p} (node) =
  {
    prval (pf | p) = node
    prval _ = lemma_node_v_param {length} {p} pf
    prval _ = node := (pf | p)
  }

primplement
lemma_node_vt_bound {length} {p} (node) =
  {
    prval (pf | p) = node
    prval _ = lemma_node_v_bound {length} {p} pf
    prval _ = node := (pf | p)
  }

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
array_mapped_tree_is_nonempty (tree) =
  case+ tree of
  | tree_vt_nil () => false
  | tree_vt_node _ => true

implement
array_mapped_tree_size (tree) =
  case+ tree of
  | tree_vt_nil () => i2sz 0
  | tree_vt_node @(size, _) => size

(********************************************************************)

typedef node_entry_t =
  @{
    is_leaf = bool,
    is_stored = bool,
    value = uintptr
  }

typedef subtree_entry_t =
  @{
    is_stored = bool,
    value = uintptr
  }

fn {}
get_node_entry {length : int | length <= bitsizeof (uintptr)}
               {i      : int | i < bitsizeof (uintptr)}
               (node   : !node_vt (length) >> _,
                i      : uint i) :
    node_entry_t =
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

          prval _ = $UNSAFE.prop_assert {index < length} ()

          val entry = node_array[index + 2]
        in
          @{
            is_leaf = is_leaf,
            is_stored = true,
            value = entry
          }
        end
      else
        @{
          is_leaf = true,
          is_stored = false,
          value = zero
        }

    prval _ = node := @(pf_node | p_node)
  in
    result
  end

fun
get_subtree_entry
          {vt : vt@ype}
          {length        : int | length <= bitsizeof (uintptr)}
          {node_p        : addr}
          {bits_source_p : addr}
          {index_data_p  : addr}
          (node_p        : ptr node_p,
           bits_source_p : ptr bits_source_p,
           index_data_p  : ptr index_data_p,
           depth         : uint) :
    subtree_entry_t =
  let
    macdef zero = g1int2uint<intknd,uintptrknd> 0

    (* Cast bits_source_p to the closure it really is. *)
    val bits_source =
      $UNSAFE.castvwtp0{bits_source_cloptr (vt, NUM_BITS)}
        bits_source_p

    (* Cast index_data_p to a pointer to an object of type vt,
       by creating a view. *)
    val (pf_index_data | index_data) =
      $UNSAFE.castvwtp0{(vt @ index_data_p | ptr index_data_p)}
        index_data_p

    val [bits : int] (pf_bits | bits) =
      bits_source (!index_data, depth)
    prval _ = bits_source_bits_bounds pf_bits

    (* The view no longer is needed. *)
    prval _ = $UNSAFE.castview2void{void} pf_index_data

    (* The closure no longer is needed. *)
    prval _ = $UNSAFE.castvwtp0{void} bits_source
  in
    if bits = BITS_SOURCE_EXHAUSTED then
      @{
        is_stored = false,
        value = zero
      }
    else
      let
        (* Cast node_p to the node_vt it really is. *)
        val node = $UNSAFE.castvwtp0{node_vt (length, node_p)} node_p

        val bits = g1int2uint<intknd,uintknd> bits
        val @{
              is_leaf = is_leaf,
              is_stored = is_stored,
              value = value
            } = get_node_entry {length} {bits} (node, bits)

        (* The node_vt no longer is needed. *)
        prval _ = $UNSAFE.castvwtp0{void} node
      in
        if not is_stored then
          @{
            is_stored = false,
            value = value
          }
        else if is_leaf then
          @{
            is_stored = true,
            value = value
          }
        else
          let
            val [length1 : int] [p1 : addr] next_node =
              $UNSAFE.castvwtp0{node_vt} value
            prval _ = lemma_node_vt_param {length1} {p1} (next_node)
            prval _ = lemma_node_vt_bound {length1} {p1} (next_node)
            val result =
              get_subtree_entry {vt} {length1} {p1}
                                {bits_source_p} {index_data_p}
                                ($UNSAFE.castvwtp0{ptr p1} next_node,
                                 bits_source_p, index_data_p,
                                 succ depth)
          in
            result
          end
      end
  end

(********************************************************************)
