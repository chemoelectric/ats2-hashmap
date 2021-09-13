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

staload "hashmap/SATS/array_prf.sats"

staload "hashmap/SATS/memory.sats"
staload _ = "hashmap/DATS/memory.dats"

staload "hashmap/SATS/count-one-bits.sats"
staload _ = "hashmap/DATS/count-one-bits.dats"

staload "hashmap/SATS/bits-source.sats"

staload UN = "prelude/SATS/unsafe.sats"

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

prval _ = $UN.prop_assert {sizeof (uintptr) == SIZEOF_UINTPTR} ()
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

absview link_v

vtypedef link_vt =
  @(link_v | uintptr)

prval _ = prop_verify {sizeof (link_vt) == sizeof (uintptr)} ()
prval _ = prop_verify {sizeof (link_vt) == SIZEOF_UINTPTR} ()

(* node_vt -- an internal node, fully formed. *)
vtypedef node_vt (length : int, p : addr) =
  @{
    view_of_population_map = uintptr @ p,
    view_of_node_kind_map = uintptr @ (p + sizeof (uintptr)),
    view_of_entries = @[link_vt][length] @ (p + 2 * sizeof (uintptr)),
    mfree = mfree_gc_v p |
    pointer = ptr p
  }
vtypedef node_vt (length : int) =
  [p : addr] node_vt (length, p)
vtypedef node_vt =
  [length : int] node_vt (length)

(* expired_node_vt -- what is left of an internal node, after its
                      contents have been freed. *)
vtypedef expired_node_vt (length : int, p : addr) =
  @{
    view_of_population_map = uintptr @ p,
    view_of_node_kind_map = uintptr @ (p + sizeof (uintptr)),
    view_of_entries =
      @[link_vt?!][length] @ (p + 2 * sizeof (uintptr)),
    mfree = mfree_gc_v p |
    pointer = ptr p
  }
vtypedef expired_node_vt (length : int) =
  [p : addr] expired_node_vt (length, p)
vtypedef expired_node_vt =
  [length : int] expired_node_vt (length)

(* expanded_node_vt -- an internal node, one of whose entries
                       needs filling in. *)
vtypedef expanded_node_vt (length : int, index : int, p : addr) =
  @{
    view_of_population_map = (uintptr?) @ p,
    view_of_node_kind_map = (uintptr?) @ (p + sizeof (uintptr)),
    view_of_left_entries =
      @[link_vt][index] @ (p + 2 * sizeof (uintptr)),
    view_of_new_entry =
      (link_vt?)
        @ (p + 2 * sizeof (uintptr) + index * sizeof (link_vt)),
    view_of_right_entries =
      @[link_vt][length - 1 - index]
          @ (p + 2 * sizeof (uintptr) +
              (1 + index) * sizeof (link_vt)),
    mfree = mfree_gc_v p |
    pointer = ptr p
  }
vtypedef expanded_node_vt (length : int, index : int) =
  [p : addr] expanded_node_vt (length, index, p)
vtypedef expanded_node_vt =
  [length, index : int] expanded_node_vt (length, index)

extern praxi
lemma_node_vt_param :
  {length : int}
  {p : addr}
  (!node_vt (length, p) >> _) -<prf>
    [0 < length; length <= bitsizeof (uintptr)]
    void

extern praxi
lemma_expired_node_vt_param :
  {length : int}
  {p : addr}
  (!expired_node_vt (length, p) >> _) -<prf>
    [0 < length; length <= bitsizeof (uintptr)]
    void

extern praxi
lemma_expanded_node_vt_param :
  {length, index : int}
  {p : addr}
  (!expanded_node_vt (length, index, p) >> _) -<prf>
    [0 < length; length <= bitsizeof (uintptr);
     0 <= index; index < length]
    void

fn {}
extract_static_length_of_node (node : node_vt) :<>
    [length : int] node_vt length =
  $UN.castvwtp0 node

(********************************************************************)

vtypedef leaf_free_vt (vt : vtype) = vt -<cloptr1> void
vtypedef leaf_free_vt = [vt : vtype] leaf_free_vt vt

fn {vt : vtype}
leaf_free_vt_is_null (closure : !leaf_free_vt (vt) >> _) :<> bool =
  ptr_is_null ($UN.castvwtp1{Ptr} closure)

(********************************************************************)

fn {}
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

fn {}
expired_node_vt_free
        {length : int}
        {p      : addr}
        (node   : expired_node_vt (length, p)) :<!wrt>
    void =
  let
    val @{
          view_of_population_map = pf_pop_map,
          view_of_node_kind_map = pf_kind_map,
          view_of_entries = pf_entries,
          mfree = pf_mfree |
          pointer = p
        } = node

    prval _ =
      $UN.castview2void_at
        {@[uintptr][length]} {@[link_vt?!][length]}
        {p + 2 * sizeof (uintptr)}
        pf_entries
    prval pf = array_v_cons (pf_kind_map, pf_entries)
    prval pf = array_v_cons (pf_pop_map, pf)
  in
    array_ptr_free {uintptr} {p} {length + 2} (pf, pf_mfree | p)
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

    stadef p_entries = p + 2 * sizeof (uintptr)
    val p_entries : ptr p_entries = ptr_add<uintptr> (p, i2sz 2)
    macdef entries = !p_entries

    (* Temporarily make the entries uintptr instead of link_vt,
       so one can copy their data without consuming their views. *)
    prval _ =
      $UN.castview2void_at
        {@[uintptr][length]} {@[link_vt][length]} {p_entries}
        pf_entries

    val entry_value = entries[index]

    prval _ =
      $UN.castview2void_at
        {@[link_vt][length]} {@[uintptr][length]} {p_entries}
        pf_entries

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

overload [] with get_entry_value

(********************************************************************)

fn {}
node_vt_to_expanded_node_vt
        {length, index : int | index < length}
        {p     : addr}
        (node  : node_vt (length, p),
         index : size_t index) :<!ref>
    (* Returns the original node_vt recast as a expanded_node_vt. *)
    expanded_node_vt (length, index, p) =
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
      array_v_subdivide2 {link_vt}
                         {p + 2 * sizeof (uintptr)}
                         {index, length - index}
                         pf_entries
    prval @(pf_entry, pf_right) = array_v_uncons pf_right

    prval _ =
      $UN.castview2void_at {link_vt?} {link_vt} pf_entry

    val expanded_node =
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
    expanded_node
  end

fn {}
expanded_node_vt_to_node_vt
        {length, index : int | index < length}
        {p            : addr}
        (node         : expanded_node_vt (length, index, p),
         index        : size_t index,
         value        : uintptr,
         old_pop_map  : uintptr,
         old_kind_map : uintptr,
         is_leaf      : bool) :<!wrt>
    node_vt (length, p) =
  let
    val new_bit = (one << (sz2i index))
    val new_pop_map = old_pop_map <+> new_bit
    val new_kind_map =
      if is_leaf then
        old_kind_map <+> new_bit
      else
        old_kind_map <*> (<~> new_bit)

    val @{
        view_of_population_map = pf_pop_map,
        view_of_node_kind_map = pf_kind_map,
        view_of_left_entries = pf_left,
        view_of_new_entry = pf_entry,
        view_of_right_entries = pf_right,
        mfree = pf_mfree |
        pointer = p
      } = node

    val () = ptr_set<uintptr> (pf_pop_map | p, new_pop_map)

    val p_kind_map = ptr_succ<uintptr> (p)
    val node_kind_map =
      ptr_set<uintptr> (pf_kind_map | p_kind_map, new_kind_map)

    prval _ = lemma_g1uint_param index

    val p_entry = ptr_add<uintptr> (p, i2sz 2 + index)
    val () = ptr_set<uintptr> (pf_entry | p_entry, value)

    prval _ = $UN.castview2void_at {link_vt} {uintptr} pf_entry

    prval pf_entry_right = array_v_cons (pf_entry, pf_right)
    prval pf_entries = array_v_join2 (pf_left, pf_entry_right)
  in
    @{
      view_of_population_map = pf_pop_map,
      view_of_node_kind_map = pf_kind_map,
      view_of_entries = pf_entries,
      mfree = pf_mfree |
      pointer = p
    }
  end

(********************************************************************)

vtypedef node_list_vt (n : int) = list_vt (node_vt, n)
vtypedef node_list_vt = [n : int] node_list_vt n

vtypedef more_nodes_vt (n : int) = list_vt (node_list_vt, n)
vtypedef more_nodes_vt = [n : int] more_nodes_vt n

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
fn {vt : vtype}
free_nodes (nodes      : node_list_vt,
            leaf_free  : !leaf_free_vt (vt) >> _,
            more_nodes : &more_nodes_vt? >> more_nodes_vt) :
    void =
  let
    typedef link_t = link_vt?!

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

          val population_map = get_population_map (node)
          val node_kind_map = get_node_kind_map (node)

          prval _ = lemma_node_vt_param {length} node

          val [popcount : int] @(_ | length) =
            get_popcount (g1ofg0 population_map)
          prval _ = $UN.prop_assert {length == popcount} ()

          fun {vt : vtype}
          for_each_bit
                  {p_entries  : addr}
                  {restlen    : int | 0 <= restlen; restlen <= length}
                  .<restlen>.
                  (pf_entries : !(@[link_vt][restlen] @ p_entries)
                                  >> @[link_t][restlen] @ p_entries |
                   leaf_free  : !leaf_free_vt (vt) >> _,
                   population : uintptr,
                   node_kinds : uintptr,
                   p_entries  : ptr p_entries,
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

                val @(population, node_kinds) =
                  skip_unpopulated (population, node_kinds)
                val is_leaf = ((node_kinds <*> one) <> zero)

                prval @(pf_entry, pf_rest) = array_v_uncons pf_entries
                val p_rest = ptr_succ<link_vt> (p_entries)

                (* Render the entry expired. *)
                prval _ =
                  $UN.castview2void_at {link_t} {link_vt} {p_entries}
                                       pf_entry
              in
                if not is_leaf then
                  (* The expired entry is a subnode, and must be
                     freed. Add it to a list for freeing later. *)
                  let
                    val entry = ptr_get<link_t> (pf_entry | p_entries)
                    val entry_p = $UN.cast{Ptr} entry
                    val next_node = $UN.castvwtp0{node_vt} entry_p
                    val new_nodes = next_node :: new_nodes
                    val result =
                      for_each_bit<vt>
                        {p_entries + sizeof (link_vt)} {restlen - 1}
                        (pf_rest | leaf_free, population, node_kinds,
                                   p_rest, pred restlen, new_nodes)
                    prval _ = pf_entries :=
                      array_v_cons (pf_entry, pf_rest)
                  in
                    result
                  end
                else if not (leaf_free_vt_is_null leaf_free) then
                  (* The expired entry is a leaf that must be
                     freed. Free it now. *)
                  let
                    val entry = ptr_get<link_t> (pf_entry | p_entries)
                    val entry_p = $UN.cast{Ptr} entry
                    val leaf = $UN.castvwtp0{vt} entry_p
                    val _ = leaf_free (leaf)
                    val result =
                      for_each_bit<vt>
                        {p_entries + sizeof (link_vt)} {restlen - 1}
                        (pf_rest | leaf_free, population, node_kinds,
                                   p_rest, pred restlen, new_nodes)
                    prval _ = pf_entries :=
                      array_v_cons (pf_entry, pf_rest)
                  in
                    result
                  end
                else
                  (* The expired entry is a leaf that need not be
                     freed (and which can be regarded as an integer
                     rather than a pointer). *)
                  let
                    val result =
                      for_each_bit<vt>
                        {p_entries + sizeof (link_vt)} {restlen - 1}
                        (pf_rest | leaf_free, population, node_kinds,
                                   p_rest, pred restlen, new_nodes)
                    prval _ = pf_entries :=
                      array_v_cons (pf_entry, pf_rest)
                  in
                    result
                  end
              end

          val @{
                view_of_population_map = pf_pop_map,
                view_of_node_kind_map = pf_kind_map,
                view_of_entries = pf_entries,
                mfree = pf_mfree |
                pointer = p
              } = node
          val p_entries = ptr_add<uintptr> (p, i2sz 2)
          val new_nodes =
            for_each_bit<vt>
              {..} {length}
              (pf_entries | leaf_free, population_map, node_kind_map,
                            p_entries, length, NIL)
          val node : expired_node_vt =
            @{
              view_of_population_map = pf_pop_map,
              view_of_node_kind_map = pf_kind_map,
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

fn {vt : vtype}
node_vt_free {length    : int}
             {p         : addr}
             (node      : node_vt (length, p),
              leaf_free : !leaf_free_vt (vt) >> _) : void =
  free_more_nodes<vt> (leaf_free, ((node :: NIL) :: NIL))  

(********************************************************************)

implement
free_array_mapped_tree (node_p, leaf_free_p) =
  {
    val node = $UN.castvwtp0{node_vt} node_p
    val leaf_free = $UN.castvwtp0{leaf_free_vt} leaf_free_p
    val _ = node_vt_free (node, leaf_free)
    prval _ = $UN.castvwtp0{Ptr} leaf_free
  }

(********************************************************************)

typedef get_entry_t = array_mapped_tree_get_entry_t

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
    prval _ = lemma_node_vt_param {length} node
    prval _ = prop_verify {0 <= length} ()

    prval _ = lemma_g1uint_param i
    prval _ = prop_verify {0 <= i} ()

    val population_map = get_population_map (node)
    val bit_selection_mask = (one << (u2i i))
    val is_stored = ((population_map <*> bit_selection_mask) <> zero)
  in
    if is_stored then
      let
        val node_kind_map = get_node_kind_map (node)
        val is_leaf =
          ((node_kind_map <*> bit_selection_mask) <> zero)

        val [index : int] @(_ | index) =
          get_popcount_low_bits (g1ofg0 population_map, i)
        prval _ = $UN.prop_assert {index < length} ()

        val entry = node[i2sz index]
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
  end

fun {vt : vtype} {hash_vt : vt@ype}
get_subtree_entry
        {length      : int | length <= bitsizeof (uintptr)}
        (node        : !node_vt (length) >> _,
         bits_source : !bits_source_cloptr (hash_vt, NUM_BITS) >> _,
         index_data  : &hash_vt >> _,
         depth       : uint) : get_entry_t =
  let
    val [bits : int] (pf_bits | bits) =
      bits_source (index_data, depth)
    prval _ = bits_source_bits_bounds pf_bits
    prval _ = prop_verify {BITS_SOURCE_EXHAUSTED <= bits} ()
    prval _ = prop_verify {bits_maxval (NUM_BITS, bits)} ()
  in
    if bits = BITS_SOURCE_EXHAUSTED then
      @{
        is_stored = false,
        value = zero
      }
    else
      let
        val @{
              is_leaf = is_leaf,
              is_stored = is_stored,
              value = value
            } = get_node_entry<> {length} {bits} (node, g1i2u bits)
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
              $UN.castvwtp0{node_vt} ($UN.cast{Ptr} value)
            prval _ = lemma_node_vt_param {length1} {p1} (next_node)
            val result =
              get_subtree_entry<vt><hash_vt>
                (next_node, bits_source, index_data, succ depth)
            prval _ = $UN.castvwtp0{Ptr} next_node
          in
            result
          end
      end
  end

implement
array_mapped_tree_get_entry {node_p} {bits_source_p} {index_data_p}
                            (node_p, bits_source_p, index_data_p) =
  let
    fn {}
    get_result {node_p        : addr}
               {bits_source_p : addr}
               {index_data_p  : addr}
               {vt            : vtype}
               {hash_vt       : vt@ype}
               (node_p        : ptr node_p,
                bits_source_p : ptr bits_source_p,
                index_data_p  : ptr index_data_p) : get_entry_t =
      let
        (* Create linear types from the pointers. *)
        val node = $UN.castvwtp0{node_vt} node_p
        val bits_source =
          $UN.castvwtp0 {bits_source_cloptr (hash_vt, NUM_BITS)}
                         bits_source_p
        val index_data =
          $UN.castvwtp0 {@(hash_vt @ index_data_p | ptr index_data_p)}
                        index_data_p

        (* Search in the tree. *)
        prval _ = lemma_node_vt_param node
        val result =
          get_subtree_entry<vt><hash_vt> (node, bits_source,
                                          !(index_data.1), 0U)

        (* Consume the linear types. *)
        prval _ = $UN.castvwtp0{Ptr} node
        prval _ = $UN.castvwtp0{Ptr} bits_source
        prval _ = $UN.castvwtp0{Ptr} index_data
      in
        result
      end
  in
    get_result<> {node_p} {bits_source_p} {index_data_p}
                 (node_p, bits_source_p, index_data_p)
  end



(*
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
    prval _ = $UN.prop_assert {length == popcount} ()

    val [index : int] @(_ | index) =
      get_popcount_low_bits (g1ofg0 population_map, i)
    prval _ = $UN.prop_assert {index < length} ()

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
