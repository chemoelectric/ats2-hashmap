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

#include "hashmap/HATS/config.hats"
#include "hashmap/HATS/bits-source-include.hats"

staload "hashmap/SATS/array-mapped-tree.sats"
staload "hashmap/SATS/bits-source.sats"
staload "hashmap/SATS/uptr.sats"
staload "hashmap/SATS/popcount.sats"

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
    leaf_map  (uintptr)        -- if a bit is set, the corresponding
                                  array entry is or points to a
                                  leaf node.
    chaining_map   (uintptr)   -- if a bit is set, and the
                                  corresponding leaf_map bit is
                                  set, the array entry is a linked
                                  list of leaves (separate chaining).
    entry 0        (uintptr)
    entry 1        (uintptr)
    entry 2        (uintptr)
       .
       .
       .
    entry N        (uintptr)   -- where N < sizeof (uintptr)

A leaf entry is either a uintptr proper, or else it is a uintptr
serving as a pointer to a key-value pair:

    key            (key type)
    alignment      (>=0 bytes padding)
    value          (value type)

It is assumed that there is no padding before the key.

POSSIBLE TO DO:

  * Support for separate chaining even if the hash's bits have not
    been exhausted. No doubt clever use of such chainging can improve
    efficiency.

*)

(********************************************************************)

#define NUM_BITS SIZEOF_BITINDEXOF_UINTPTR

stadef bitsizeof (t : vt@ype) = 8 * sizeof (t)

(********************************************************************)

absview link_v

vtypedef link_vt (p : addr) =
  @(link_v | uptr p)
vtypedef link_vt =
  [p : addr] link_vt p

castfn
uintptr2link :
  uintptr -<> [p : addr] link_vt p

castfn
link2uintptr :
  {p : addr} link_vt p -<> uintptr

stadef population_map_addr (p : addr) : addr = p
stadef leaf_map_addr (p : addr) : addr = p + sizeof (uintptr)
stadef chaining_map_addr (p : addr) : addr = p + 2 * sizeof (uintptr)
stadef entries_addr (p : addr) : addr = p + 3 * sizeof (uintptr)

(* node_vt -- an internal node, fully formed. *)
vtypedef node_vt (length : int, p : addr) =
  @{
    view_of_population_map = uintptr @ population_map_addr (p),
    view_of_leaf_map = uintptr @ leaf_map_addr (p),
    view_of_chaining_map = uintptr @ chaining_map_addr (p),
    view_of_entries = @[link_vt][length] @ entries_addr (p),
    mfree = mfree_gc_v p |
    pointer = uptr p
  }
vtypedef node_vt (length : int) =
  [p : addr] node_vt (length, p)
vtypedef node_vt (p : addr) =
  [length : int] node_vt (length, p)
vtypedef node_vt =
  [length : int] [p : addr] node_vt (length, p)

castfn
node2uptr :
  {length : int} {p : addr}
  node_vt (length, p) -<> uptr p

castfn
uptr2node :
  {p : addr}
  uptr p -<> [length : int] node_vt (length, p)

castfn
uptr2node_of_length :
  {length : int}
  {p      : addr}
  uptr p -<> node_vt (length, p)

fn {}
uintptr2node :
  uintptr -<>
    [length : int]
    [p : addr]
    node_vt (length, p)

fn {}
node2uintptr :
  {length : int} {p : addr}
  node_vt (length, p) -<> uintptr

(* expired_node_vt -- what is left of an internal node, after its
                      contents have been freed. *)
vtypedef expired_node_vt (length : int, p : addr) =
  @{
    view_of_population_map = uintptr @ population_map_addr (p),
    view_of_leaf_map = uintptr @ leaf_map_addr (p),
    view_of_chaining_map = uintptr @ chaining_map_addr (p),
    view_of_entries = @[link_vt?!][length] @ entries_addr (p),
    mfree = mfree_gc_v p |
    pointer = uptr p
  }
vtypedef expired_node_vt (length : int) =
  [p : addr] expired_node_vt (length, p)
vtypedef expired_node_vt =
  [length : int] expired_node_vt (length)

(* slotted_node_vt -- an internal node, one of whose entries
                      needs filling in (as do its maps). *)
vtypedef slotted_node_vt (length : int, index : int, p : addr) =
  @{
    view_of_population_map = (uintptr?) @ population_map_addr (p),
    view_of_leaf_map = (uintptr?) @ leaf_map_addr (p),
    view_of_chaining_map = (uintptr?) @ chaining_map_addr (p),
    view_of_left_entries = @[link_vt][index] @ entries_addr (p),
    view_of_new_entry =
      (link_vt?) @ (entries_addr (p) + index * sizeof (link_vt)),
    view_of_right_entries =
      @[link_vt][length - 1 - index]
          @ (entries_addr (p) + index * sizeof (link_vt)
                + sizeof (link_vt?)),
    mfree = mfree_gc_v p |
    pointer = uptr p
  }
vtypedef slotted_node_vt (length : int, index : int) =
  [p : addr] slotted_node_vt (length, index, p)
vtypedef slotted_node_vt =
  [length, index : int] slotted_node_vt (length, index)

(* new_slotted_node_vt -- like a slotted_node_vt, but all the
                          fields need filling in. *)
vtypedef new_slotted_node_vt (length : int, index : int, p : addr) =
  @{
    view_of_population_map = (uintptr?) @ population_map_addr (p),
    view_of_leaf_map = (uintptr?) @ leaf_map_addr (p),
    view_of_chaining_map = (uintptr?) @ chaining_map_addr (p),
    view_of_left_entries =
      @[link_vt?][index] @ entries_addr (p),
    view_of_new_entry =
      (link_vt?) @ (entries_addr (p) + index * sizeof (link_vt?)),
    view_of_right_entries =
      @[link_vt?][length - 1 - index]
          @ (entries_addr (p) + index * sizeof (link_vt?)
                + sizeof (link_vt?)),
    mfree = mfree_gc_v p |
    pointer = uptr p
  }
vtypedef new_slotted_node_vt (length : int, index : int) =
  [p : addr] new_slotted_node_vt (length, index, p)
vtypedef new_slotted_node_vt =
  [length, index : int] new_slotted_node_vt (length, index)

(* new_length1_node_vt -- A node of length one that needs
                          filling in. *)
vtypedef new_length1_node_vt (p : addr) =
  @{
    view_of_population_map = (uintptr?) @ population_map_addr (p),
    view_of_leaf_map = (uintptr?) @ leaf_map_addr (p),
    view_of_chaining_map = (uintptr?) @ chaining_map_addr (p),
    view_of_entries = @[link_vt?][1] @ entries_addr (p),
    mfree = mfree_gc_v p |
    pointer = uptr p
  }

praxi
lemma_node_vt_param :
  {length : int}
  {p : addr}
  (!node_vt (length, p) >> _) -<prf>
    [0 < length; length <= bitsizeof (uintptr)]
    void

praxi
lemma_expired_node_vt_param :
  {length : int}
  {p : addr}
  (!expired_node_vt (length, p) >> _) -<prf>
    [0 < length; length <= bitsizeof (uintptr)]
    void

praxi
lemma_slotted_node_vt_param :
  {length, index : int}
  {p : addr}
  (!slotted_node_vt (length, index, p) >> _) -<prf>
    [0 < length; length <= bitsizeof (uintptr);
     0 <= index; index < length]
    void

fun {}
extract_static_length_of_node
        {length : int}
        {node_p : addr}
        (node : !node_vt (length, node_p) >> _) :<>
    [len : int | len == length]
    void

(********************************************************************)

fun {}
population_map_ptr
        {p : addr}
        (p : uptr p) :<> uptr (population_map_addr p)

fun {}
leaf_map_ptr
        {p : addr}
        (p : uptr p) :<> uptr (leaf_map_addr p)

fun {}
chaining_map_ptr
        {p : addr}
        (p : uptr p) :<> uptr (chaining_map_addr p)

fun {}
entries_ptr
        {p : addr}
        (p : uptr p) :<> uptr (entries_addr p)

(********************************************************************)

fun {}
get_population_map
        {length : int}
        {p      : addr}
        (node   : !node_vt (length, p) >> _) :<!ref> uintptr

fun {}
get_leaf_map
        {length : int}
        {p      : addr}
        (node   : !node_vt (length, p) >> _) :<!ref> uintptr

fun {}
set_leaf_map
        {length : int}
        {p      : addr}
        (node   : !node_vt (length, p) >> _,
         value  : uintptr) :<!refwrt> void

fun {}
get_chaining_map
        {length : int}
        {p      : addr}
        (node   : !node_vt (length, p) >> _) :<!ref> uintptr

(********************************************************************)

fun {tk : tkind}
get_entry_value_g1uint
        {length, index : int | index < length}
        {p      : addr}
        (node   : !node_vt (length, p) >> _,
         index  : g1uint (tk, index)) :<!ref> uintptr

fun {tk : tkind}
get_entry_value_g1int
        {length, index : int | 0 <= index; index < length}
        {p      : addr}
        (node   : !node_vt (length, p) >> _,
         index  : g1int (tk, index)) :<!ref> uintptr

overload get_entry_value with get_entry_value_g1uint
overload get_entry_value with get_entry_value_g1int
overload [] with get_entry_value

(********************************************************************)

fun {tk : tkind}
set_entry_value_g1uint
        {length, index : int | index < length}
        {p      : addr}
        (node   : !node_vt (length, p) >> _,
         index  : g1uint (tk, index),
         value  : uintptr) :<!refwrt> void

fun {tk : tkind}
set_entry_value_g1int
        {length, index : int | 0 <= index; index < length}
        {p      : addr}
        (node   : !node_vt (length, p) >> _,
         index  : g1int (tk, index),
         value  : uintptr) :<!refwrt> void

overload set_entry_value with set_entry_value_g1uint
overload set_entry_value with set_entry_value_g1int
overload [] with set_entry_value

(********************************************************************)

fun {}
get_popcount {population_map : int}
             (population_map : uintptr population_map) :<>
    [popcount : int | 0 <= popcount; popcount <= BITSIZEOF_UINTPTR]
    @(POPCOUNT (population_map, popcount) | size_t popcount)

fun {}
get_popcount_low_bits {population_map : int}
                      {i              : int | i < BITSIZEOF_UINTPTR}
                      (population_map : uintptr population_map,
                       i              : uint i) :<>
    [popcount : int | 0 <= popcount; popcount <= i]
    @(POPCOUNT_LOW_BITS (population_map, i, popcount) | int popcount)

(********************************************************************)

fun {}
node_alloc {length : int}
           (length : size_t length) :<!wrt>
    [p : addr | null < p]
    @(@[uintptr?][length + 3] @ p, mfree_gc_v p | uptr p)

fun {}
new_slotted_node_alloc
        {length, index : int | index < length}
        (length : size_t length,
         index  : size_t index) :<!wrt>
    [p : addr | null < p]
    new_slotted_node_vt (length, index, p)

fun {}
new_length1_node_alloc () :<!wrt>
    [p : addr | null < p]
    new_length1_node_vt p

fun {}
expired_node_vt_free
        {length : int}
        {p      : addr}
        (node   : expired_node_vt (length, p)) :<!wrt> void

(********************************************************************)

fun {}
expand_node {length, index : int | 0 <= index; index <= length}
            {p      : addr}
            (node   : node_vt (length, p),
             length : size_t length,
             index  : size_t index) :
    [q : addr | null < q]
    slotted_node_vt (length + 1, index, q)

(********************************************************************)
(*
  Notes on hash_function_vt:

      * If the first argument of a hash function is to be treated
        as a pointer, then it has to be able to point to either a
        key or a key-value pair; in the latter case, the pair must
        start with the key. There must be no padding before the key.

      * A hash function stores the hash into space that was allocated
        for it ahead of time.
*)
vtypedef hash_function_vt (hash_vt : vt@ype) =
  (uintptr, &hash_vt? >> hash_vt) -<cloptr1> void

vtypedef key_test_vt = (uintptr, uintptr) -<cloptr1> bool

(********************************************************************)

(* start_new_tree -- this assumes the bits_source returns at least
                     one bit. Any useful bits_source will do so. *)
fun {hash_vt : vt@ype}
start_new_tree
        {key_value    : int}
        (bits_source  : !bits_source_cloptr (hash_vt, NUM_BITS) >> _,
         hash_func    : !hash_function_vt (hash_vt) >> _,
         hash_storage : &hash_vt? >> hash_vt?,
         key_value    : uintptr key_value) :
    node_vt (1)

fun {hash_vt : vt@ype}
get_subtree_entry
        {length       : int | length <= bitsizeof (uintptr)}
        {key          : int}
        {depth        : int}
        (node         : !node_vt (length) >> _,
         bits_source  : !bits_source_cloptr (hash_vt, NUM_BITS) >> _,
         hash_func    : !hash_function_vt (hash_vt) >> _,
         hash_storage : &hash_vt? >> hash_vt?,
         key_test     : !key_test_vt >> _,
         key          : uintptr key,
         depth        : uint depth,
         is_stored    : &bool? >> bool is_stored,
         key_value    : &uintptr? >> uintptr key_value) :
    #[is_stored : bool]
    #[key_value : int | is_stored || key_value == 0]
    void

(* set_subtree_entry -- this assumes bits_source will return at
                        least one bit. (Note that, if depth = 0U,
                        then any *useful* bits_source has to
                        return at least one bit.) *)
fun {hash_vt : vt@ype}
set_subtree_entry
        {length        : int | length <= bitsizeof (uintptr)}
        {key_value     : int}
        {depth         : int}
        (node          : &node_vt (length) >> node_vt (new_length),
         bits_source   : !bits_source_cloptr (hash_vt, NUM_BITS) >> _,
         hash_func     : !hash_function_vt (hash_vt) >> _,
         hash_storage1 : &hash_vt? >> hash_vt?,
         hash_storage2 : &hash_vt? >> hash_vt?,
         key_test      : !key_test_vt >> _,
         key_value     : uintptr key_value,
         depth         : uint depth,
         is_new_slot   : &bool? >> bool is_new_slot) :
    #[new_length : int | (new_length == length ||
                          new_length == length + 1)]
    #[is_new_slot : bool]
    void

(*
FIXME: Add delete_subtree_entry.
*)

(********************************************************************)
