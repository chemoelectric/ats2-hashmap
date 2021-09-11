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

staload "hashmap/SATS/array_prf.sats"

staload "hashmap/SATS/memory.sats"
staload _ = "hashmap/DATS/memory.dats"

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

symintr >>
infixl ( * ) >>
overload >> with g0uint_lsr_uintptr

symintr <*>
infixl ( * ) <*>
overload <*> with g0uint_land_uintptr

symintr <+>
infixl ( * ) <+>
overload <+> with g0uint_lor_uintptr

extern castfn
g1int2uint_int_uintpr :
  {i : int | 0 <= i} int i -<> uintptr i

implement
g1int2uint<intknd,uintptrknd> = g1int2uint_int_uintptr

macdef zero = g1int2uint<intknd,uintptrknd> 0
macdef one = g1int2uint<intknd,uintptrknd> 1

#define NIL list_vt_nil ()
#define :: list_vt_cons

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

vtypedef node_vt (length : int, p : addr) =
  @{
    view_of_population_map = uintptr @ p,
    view_of_node_kind_map = uintptr @ (p + sizeof (uintptr)),
    view_of_entries = @[uintptr][length] @ (p + 2 * sizeof (uintptr)),
    mfree = mfree_gc_v p |
    pointer = ptr p
  }
vtypedef node_vt (length : int) =
  [p : addr] node_vt (length, p)
vtypedef node_vt =
  [length : int] node_vt (length)

vtypedef new_node_vt (length : int, index : int, p : addr) =
  @{
    view_of_population_map = uintptr @ p,
    view_of_node_kind_map = uintptr @ (p + sizeof (uintptr)),
    view_of_left_entries =
      @[uintptr][index] @ (p + 2 * sizeof (uintptr)),
    view_of_new_entry =
      (uintptr?) @ (p + (2 + index) * sizeof (uintptr)),
    view_of_right_entries =
      @[uintptr][length - 1 - index]
          @ (p + (3 + index) * sizeof (uintptr)),
    mfree = mfree_gc_v p |
    pointer = ptr p
  }
vtypedef new_node_vt (length : int, index : int) =
  [p : addr] new_node_vt (length, index, p)
vtypedef new_node_vt =
  [length, index : int] new_node_vt (length, index)

extern praxi
lemma_node_vt_param :
  {length : int}
  {p : addr}
  (!node_vt (length, p) >> _) -<prf>
    [0 < length; length <= bitsizeof (uintptr)]
    void

extern praxi
lemma_new_node_vt_param :
  {length, index : int}
  {p : addr}
  (!new_node_vt (length, index, p) >> _) -<prf>
    [0 < length; length <= bitsizeof (uintptr);
     0 <= index; index < length]
    void

(********************************************************************)

fn
node_alloc {length : int}
           (length : size_t length) :<!wrt>
    [p : addr]
    @(@[uintptr?][length + 2] @ p, mfree_gc_v p | ptr p) =
  let
    val size = length + (g1u2u 2U)
    val @(view, mfree | pointer) = array_ptr_alloc<uintptr> (size)
  in
    @(view, mfree | pointer)
  end

fn
node_vt_free {length : int}
             {p      : addr}
             (node   : node_vt (length, p)) :<!wrt>
    void =
  let
    val @{
          view_of_population_map = pf_pop_map,
          view_of_node_kind_map = pf_kind_map,
          view_of_entries = pf_entries,
          mfree = pf_mfree |
          pointer = p
        } = node

    prval pf = array_v_cons (pf_kind_map, pf_entries)
    prval pf = array_v_cons (pf_pop_map, pf)
  in
    array_ptr_free {uintptr} {p} {length + 2} (pf, pf_mfree | p)
  end

(********************************************************************)

fn {}
node_vt_to_new_node_vt
        {length, index : int | index < length}
        {p     : addr}
        (node  : node_vt (length, p),
         index : size_t index) :<!ref>
    (* Returns the original node_vt recast as a new_node_vt,
       and the old value of the "new" entry. *)
    @(new_node_vt (length, index, p),
      uintptr) =
  let
    val @{
          view_of_population_map = pf_pop_map,
          view_of_node_kind_map = pf_kind_map,
          view_of_entries = pf_entries,
          mfree = pf_mfree |
          pointer = p
        } = node

    prval _ = lemma_g1uint_param index

    prval @(pf_left, pf_right) =
      array_v_subdivide2 {uintptr}
                         {p + 2 * sizeof (uintptr)}
                         {index, length - index}
                         pf_entries
    prval @(pf_entry, pf_right) = array_v_uncons pf_right

    val p_entry = ptr_add<uintptr> (p, i2sz 2 + index)
    val old_value = ptr_get<uintptr> (pf_entry | p_entry)

    val new_node =
      @{
        view_of_population_map = pf_pop_map,
        view_of_node_kind_map = pf_kind_map,
        view_of_left_entries = pf_left,
        view_of_new_entry = pf_entry,
        view_of_right_entries = pf_right,
        mfree = pf_mfree |
        pointer = p
      }
  in
    @(new_node, old_value)
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
          view_of_node_kind_map = pf_kind_map,
          view_of_entries = pf_entries,
          mfree = pf_mfree |
          pointer = p
        } = node

    val pop_map = ptr_get<uintptr> (pf_pop_map | p)

    prval _ = node :=
      @{
        view_of_population_map = pf_pop_map,
        view_of_node_kind_map = pf_kind_map,
        view_of_entries = pf_entries,
        mfree = pf_mfree |
        pointer = p
      }
  in
    pop_map
  end

fn {}
set_population_map
        {length, index : int}
        {p       : addr}
        (node    : !new_node_vt (length, index, p) >> _,
         pop_map : uintptr) :<!wrt>
    void =
  {
    val @{
          view_of_population_map = pf_pop_map,
          view_of_node_kind_map = pf_kind_map,
          view_of_left_entries = pf_left,
          view_of_new_entry = pf_entry,
          view_of_right_entries = pf_right,
          mfree = pf_mfree |
          pointer = p
        } = node

    val () = ptr_set<uintptr> (pf_pop_map | p, pop_map)

    prval _ = node :=
      @{
        view_of_population_map = pf_pop_map,
        view_of_node_kind_map = pf_kind_map,
        view_of_left_entries = pf_left,
        view_of_new_entry = pf_entry,
        view_of_right_entries = pf_right,
        mfree = pf_mfree |
        pointer = p
      }
  }

(********************************************************************)

fn {}
get_node_kind_map
        {length : int}
        {p      : addr}
        (node   : !node_vt (length, p) >> _) :<!ref>
    uintptr =
  let
    val @{
          view_of_population_map = pf_pop_map,
          view_of_node_kind_map = pf_kind_map,
          view_of_entries = pf_entries,
          mfree = pf_mfree |
          pointer = p
        } = node

    val p_kind_map = ptr_succ<uintptr> (p)
    val node_kind_map = ptr_get<uintptr> (pf_kind_map | p_kind_map)

    prval _ = node :=
      @{
        view_of_population_map = pf_pop_map,
        view_of_node_kind_map = pf_kind_map,
        view_of_entries = pf_entries,
        mfree = pf_mfree |
        pointer = p
      }
  in
    node_kind_map
  end

fn {}
set_node_kind_map
        {length, index : int}
        {p        : addr}
        (node     : !new_node_vt (length, index, p) >> _,
         kind_map : uintptr) :<!wrt>
    void =
  {
    val @{
          view_of_population_map = pf_pop_map,
          view_of_node_kind_map = pf_kind_map,
          view_of_left_entries = pf_left,
          view_of_new_entry = pf_entry,
          view_of_right_entries = pf_right,
          mfree = pf_mfree |
          pointer = p
        } = node

    val p_kind_map = ptr_succ<uintptr> (p)
    val () = ptr_set<uintptr> (pf_kind_map | p_kind_map, kind_map)

    prval _ = node :=
      @{
        view_of_population_map = pf_pop_map,
        view_of_node_kind_map = pf_kind_map,
        view_of_left_entries = pf_left,
        view_of_new_entry = pf_entry,
        view_of_right_entries = pf_right,
        mfree = pf_mfree |
        pointer = p
      }
  }

(********************************************************************)

fn {}
get_entry_value
        {length, index : int | index < length}
        {p      : addr}
        (node   : !node_vt (length, p) >> _,
         index  : size_t index) :<!ref>
    uintptr =
  let
    val @{
          view_of_population_map = pf_pop_map,
          view_of_node_kind_map = pf_kind_map,
          view_of_entries = pf_entries,
          mfree = pf_mfree |
          pointer = p
        } = node

    prval _ = lemma_g1uint_param index
    
    prval @(pf_left, pf_entry_right) =
      array_v_subdivide2 {uintptr} {p + 2 * sizeof (uintptr)}
                         {index, length - index}
                         pf_entries
    prval @(pf_entry, pf_right) = array_v_uncons pf_entry_right

    val p_entry = ptr_add<uintptr> (p, i2sz 2 + index)
    val entry_value = ptr_get<uintptr> (pf_entry | p_entry)

    prval _ = pf_entry_right := array_v_cons (pf_entry, pf_right)
    prval _ = pf_entries :=
       array_v_join2 {uintptr} {p + 2 * sizeof (uintptr)}
                     {index, length - index}
                     (pf_left, pf_entry_right)
    prval _ = node :=
      @{
        view_of_population_map = pf_pop_map,
        view_of_node_kind_map = pf_kind_map,
        view_of_entries = pf_entries,
        mfree = pf_mfree |
        pointer = p
      }
  in
    entry_value
  end

fn {}
set_entry_value
        {length, index : int | index < length}
        {p      : addr}
        (node   : !new_node_vt (length, index, p)
                      >> node_vt (length, p),
         index  : size_t index,
         value  : uintptr) :<!wrt>
    void =
  {
    val @{
        view_of_population_map = pf_pop_map,
        view_of_node_kind_map = pf_kind_map,
        view_of_left_entries = pf_left,
        view_of_new_entry = pf_entry,
        view_of_right_entries = pf_right,
        mfree = pf_mfree |
        pointer = p
      } = node

    prval _ = lemma_g1uint_param index

    val p_entry = ptr_add<uintptr> (p, i2sz 2 + index)
    val () = ptr_set<uintptr> (pf_entry | p_entry, value)

    prval pf_entry_right = array_v_cons (pf_entry, pf_right)
    prval pf_entries = array_v_join2 (pf_left, pf_entry_right)

    prval _ = node :=
      @{
        view_of_population_map = pf_pop_map,
        view_of_node_kind_map = pf_kind_map,
        view_of_entries = pf_entries,
        mfree = pf_mfree |
        pointer = p
      }
  }

overload [] with get_entry_value
overload [] with set_entry_value

(********************************************************************)





(*

(********************************************************************)

vtypedef nodes_vt = List_vt (array_mapped_tree_vt)
vtypedef more_nodes_vt = List_vt (nodes_vt)

fun
skip_unpopulated (population : uintptr,
                  node_kinds : uintptr) :
    @(uintptr, uintptr) =
  if (population <*> one) <> zero then
    @(population, node_kinds)
  else
    skip_unpopulated (population >> 1, node_kinds >> 1)

(* Rather than recursively deepen the stack, let us free nodes while
   also building up lists of more nodes to be freed. *)
fn
free_nodes {free_entry_p : addr}   (* May be null. *)
           (nodes        : nodes_vt,
            free_entry_p : ptr free_entry_p,
            more_nodes   : &more_nodes_vt? >> more_nodes_vt) :
    void =
  let
    fun
    for_each_node
            {n          : int | 0 <= n} .<n>.
            (nodes      : list_vt (array_mapped_tree_vt, n),
             more_nodes : more_nodes_vt) : more_nodes_vt =
      case+ nodes of
      | ~ NIL => more_nodes
      | ~ node_p :: tail =>
        let
          val [node_p : addr] node_p = g1ofg0 node_p

          (* Cast node_p to the node_vt it really is. *)
          val [length : int] node =
            $UNSAFE.castvwtp0
              {[length : int | length <= bitsizeof (uintptr)]
               node_vt (length, node_p)}
              node_p

          val @{
                view = pf_node,
                mfree = pf_mfree |
                pointer = p_node
              } = node
          prval _ = lemma_node_v_param {length} pf_node
          macdef node_array = !p_node

          val population_map = node_array[0]
          val node_kind_map = node_array[1]

          val [popcount : int] @(_ | length) =
            get_popcount (g1ofg0 population_map)
          prval _ = $UNSAFE.prop_assert {length == popcount} ()

          fun
          for_each_bit {vt         : vtype}
                       {node_p     : addr}
                       {length     : int}
                       {i          : int | i <= length}
                       .<length - i>.
                       (pf_node    : !node_v (length, node_p) >> _ |
                        p_node     : ptr node_p,
                        population : uintptr,
                        node_kinds : uintptr,
                        length     : size_t length,
                        i          : size_t i,
                        new_nodes  : nodes_vt) : nodes_vt =
            if i = length then
              new_nodes
            else
              let
                prval _ = lemma_list_vt_param new_nodes
                prval _ = lemma_g1uint_param i

                prval _ = lemma_node_v_param {length} pf_node
                macdef node_array = !p_node

                val @(population, node_kinds) =
                  skip_unpopulated (population, node_kinds)
                val is_leaf = ((node_kinds <*> one) <> zero)
              in
                if not is_leaf then
                  let
                    val entry = node_array[i + i2sz 2]
                    val [next_node_p : addr] next_node_p =
                      $UNSAFE.cast{[p : addr] ptr p} entry
                    val new_nodes = (next_node_p :: new_nodes)
                  in
                    for_each_bit (pf_node | p_node, population,
                                            node_kinds, length,
                                            succ i, new_nodes)
                  end
                else if ptr_isnot_null free_entry_p then
                  let
                    (* Cast free_entry_p to the closure it
                       actually is. *)
                    val free_func =
                      $UNSAFE.castvwtp0{vt -<cloptr1> void}
                        free_entry_p

                    val entry = node_array[i + i2sz 2]
                    val leaf = $UNSAFE.cast{ptr} entry
                    val _ = free_func ($UNSAFE.castvwtp0{vt} leaf)

                    (* The closure no longer is needed. *)
                    prval _ = $UNSAFE.castvwtp0{void} free_func
                  in
                    for_each_bit (pf_node | p_node, population,
                                            node_kinds, length,
                                            succ i, new_nodes)
                  end
                else
                  (* The entry need not be freed (and can be
                     regarded as an integer rather than a
                     pointer. *)
                  for_each_bit (pf_node | p_node, population,
                                          node_kinds, length,
                                          succ i, new_nodes)
              end

          val new_nodes =
            for_each_bit (pf_node | p_node, population_map,
                                    node_kind_map, length,
                                    i2sz 0, NIL)

          (* Having freed its leaves, and listed its subnodes
             for later handling, now free the node itself. *)
          val _ = node_vt_free {length} @{view = pf_node,
                                          mfree = pf_mfree |
                                          pointer = p_node}

          prval _ = lemma_list_vt_param more_nodes
        in
          for_each_node (tail, new_nodes :: more_nodes)
        end

    prval _ = lemma_list_vt_param nodes
  in
    more_nodes := for_each_node (nodes, NIL)
  end

fun
free_more_nodes {free_entry_p : addr} (* May be null. *)
                (free_entry_p : ptr free_entry_p,
                 more_nodes   : more_nodes_vt) : void =
  (* The more_nodes list may temporarily grow, but should
     eventually shrink to NIL. *)
  case+ more_nodes of
  | ~ NIL => ()
  | ~ nodes :: tail =>
    let
      var yet_more_nodes : more_nodes_vt
    in
      free_nodes (nodes, free_entry_p, yet_more_nodes);
      free_more_nodes (free_entry_p,
                       list_vt_reverse_append (yet_more_nodes, tail))
    end

implement
free_array_mapped_tree (node_p, free_entry_p) =
  free_more_nodes (free_entry_p, ((node_p :: NIL) :: NIL))

(********************************************************************)

primplement
lemma_node_vt_param {length} {p} (node) =
  lemma_node_v_param {length} {p} node.view

primplement
lemma_node_vt_bound {length} {p} (node) =
  lemma_node_v_bound {length} {p} node.view

(********************************************************************)

typedef node_entry_t =
  @{
    is_leaf = bool,
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
    val @{
          view = pf_node,
          mfree = mfree |
          pointer = p_node
        } = node
    prval _ = lemma_node_v_param {length} pf_node
    macdef node_array = !p_node

    val population_map = node_array[0]
    val bit_selection_mask = (one << (u2i i))
    val is_stored = ((population_map <*> bit_selection_mask) <> zero)

    val result =
      if is_stored then
        let
          val node_kind_map = node_array[1]
          val is_leaf =
            ((node_kind_map <*> bit_selection_mask) <> zero)

          val [index : int] @(_ | index) =
            get_popcount_low_bits (g1ofg0 population_map, i)
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

    prval _ = node :=
      @{
        view = pf_node,
        mfree = mfree |
        pointer = p_node
      }
  in
    result
  end

fun
get_subtree_entry
          {vt            : vtype}
          {node_p        : addr}
          {bits_source_p : addr}
          {index_data_p  : addr}
          (node_p        : ptr node_p,
           bits_source_p : ptr bits_source_p,
           index_data_p  : ptr index_data_p,
           depth         : uint) :
    array_mapped_tree_get_entry_t =
  let
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
        val [length : int] node =
          $UNSAFE.castvwtp0
            {[length : int | length <= bitsizeof (uintptr)]
             node_vt (length, node_p)}
            node_p

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
              get_subtree_entry {vt} {p1}
                                {bits_source_p} {index_data_p}
                                ($UNSAFE.castvwtp0{ptr p1} next_node,
                                 bits_source_p, index_data_p,
                                 succ depth)
          in
            result
          end
      end
  end

implement
array_mapped_tree_get_entry {node_p} {bits_source_p} {index_data_p}
                            (node_p, bits_source_p, index_data_p) =
  get_subtree_entry {..} {node_p} {bits_source_p} {index_data_p}
                    (node_p, bits_source_p, index_data_p, 0U)

(********************************************************************)

fn
insert_node_entry {length  : int | length <= bitsizeof (uintptr)}
                  {i       : int | i < bitsizeof (uintptr)}
                  (node    : node_vt (length),
                   i       : uint i,
                   is_leaf : bool) :
    (* Return the new node and a pointer to the new entry. *)
    @(node_vt (length + 1), Ptr) =
  let
    prval _ = lemma_g1uint_param i

    val @{
          view = pf_node,
          mfree = pf_mfree |
          pointer = p_node
        } = node
    prval _ = lemma_node_v_param {length} pf_node
    macdef node_array = !p_node

    val new_bit = (one << (u2i i))

    val population_map = node_array[0]
    val new_population_map = population_map <+> new_bit
    val _ = assertloc (new_population_map != population_map)

    val node_kind_map = node_array[1]
    val new_node_kind_map =
      if is_leaf then
        node_kind_map <+> new_bit
      else
        node_kind_map

    val [popcount : int] @(_ | length) =
      get_popcount (g1ofg0 population_map)
    prval _ = $UNSAFE.prop_assert {length == popcount} ()

    val [index : int] @(_ | index) =
      get_popcount_low_bits (g1ofg0 population_map, i)
    prval _ = $UNSAFE.prop_assert {index < length} ()

    val new_node = node_vt_alloc {length + 1} (length + 1)
    val @{
          view = pf_new_node,
          mfree = pf_new_mfree |
          pointer = p_new_node
        } = new_node
    prval _ = lemma_node_v_param {length + 1} pf_new_node
    macdef new_node_array = !p_new_node

    val _ = new_node_array[0] := new_population_map
    val _ = new_node_array[1] := new_node_kind_map

    (* Copy data that goes before the new entry. *)
    val _ =
      array_copy_elements<uintptr>
        {length + 3, length + 2} {2, 2} {index}
        (new_node_array, i2sz 2,
         node_array, i2sz 2,
         g1i2u index)

    (* Copy data that goes after the new entry. *)
    val _ =
      array_copy_elements<uintptr>
        {length + 3, length + 2} {3 + index, 2 + index}
        {length - index}
        (new_node_array, i2sz 3 + index,
         node_array, i2sz 2 + index,
         length - g1i2u index)

    val _ = node_vt_free {length} @{view = pf_node,
                                    mfree = pf_mfree |
                                    pointer = p_node}

    val entry_index = index + i2sz 2
    val entry_p = ptr_add<uintptr> (p_new_node, entry_index)
  in
    @(@{view = pf_new_node,
        mfree = pf_new_mfree |
        pointer = p_new_node},
      entry_p)
  end

(********************************************************************)

*)
