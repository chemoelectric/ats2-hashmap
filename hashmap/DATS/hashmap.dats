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

staload UN = "prelude/SATS/unsafe.sats"

staload "hashmap/SATS/hashmap.sats"

staload "hashmap/SATS/array-proofs.sats"
staload "hashmap/SATS/bits_source.sats"
staload "hashmap/SATS/bits_source-parameters.sats"
staload "hashmap/SATS/population_map.sats"
staload "popcount/SATS/popcount.sats"

staload _ = "hashmap/DATS/bits_source.dats"
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
key_value_vt (key_vt   : vt@ype+,
              value_vt : vt@ype+) =
  @{
    key = key_vt,
    value = value_vt
  }

vtypedef
key_value_list_vt (key_vt   : vt@ype+,
                   value_vt : vt@ype+,
                   length   : int) =
  list_vt (key_value_vt (key_vt, value_vt), length)
vtypedef
key_value_list_vt (key_vt   : vt@ype+,
                   value_vt : vt@ype+) =
  [length : int]
  list_vt (key_value_vt (key_vt, value_vt), length)

datavtype
node_vt (key_vt   : vt@ype+,
         value_vt : vt@ype+) =
| node_vt_key_value (key_vt, value_vt) of
    key_value_vt (key_vt, value_vt)
| node_vt_list (key_vt, value_vt) of
    (* For separate chaining. *)
    key_value_list_vt (key_vt, value_vt)
| node_vt_array (key_vt, value_vt) of
    node_array_vt (key_vt, value_vt)
where
node_array_vt (key_vt            : vt@ype+,
               value_vt          : vt@ype+,
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
node_array_vt (key_vt            : vt@ype+,
               value_vt          : vt@ype+) =
  [population_map : int]
  [length         : int]
  [p              : addr]
  node_array_vt (key_vt, value_vt, population_map, length, p)

datavtype
map_vt (key_vt            : vt@ype+,
        value_vt          : vt@ype+,
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

#define NODESZ (sizeof (node_vt))

(********************************************************************)

primplement
lemma_hashmap_vt_param (map) =
  case+ map of
  | map_vt_nil () => ()
  | map_vt_root _ => ()

(********************************************************************)

implement {}
hashmap () = map_vt_nil ()

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

fn {key_vt, value_vt : vt@ype}
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
    val new_leaf = node_vt_key_value @{key = key, value = value}

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
hashmap_set {size} (map, key, value) =
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

fun {hash_vt : vt@ype}
    {key_vt, value_vt : vt@ype}
find_entry {population_map : int}
           {length  : int}
           {p_array : addr}
           {depth   : int}
           (hash    : &hash_vt >> _,
            tree    : !node_array_vt (key_vt, value_vt,
                                      population_map,
                                      length, p_array) >> _,
            key     : !key_vt >> _,
            depth   : size_t depth) : Option_vt (value_vt) =
  let
    vtypedef t = node_vt (key_vt, value_vt)
    vtypedef kv_t = key_value_vt (key_vt, value_vt)

    val [bits : int] bits = hashmap$bits_source<hash_vt> (hash, 0U)
  in
    if bits = BITS_SOURCE_EXHAUSTED then
      (* There are no more hash bits. *)
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

            (* FIXME: Prove this. *)
            prval _ = $UN.prop_assert {array_index < length} ()

            val p_entry = ptr_add<t> (tree.p_array, array_index)
            prval @(pf_left, pf_entry, pf_right) =
              array_v_isolate_entry {t} {..} {length} {array_index}
                                    (tree.array_view)
          in
            case+ !p_entry of
            | node_vt_key_value key_value =>
              if hashmap$key_vt_eq<key_vt> (key, key_value.key) then
                (* A key-value pair was found. *)
                let
                  val value =
                    hashmap$value_vt_copy<value_vt> (key_value.value)
                  prval _ = tree.array_view :=
                    array_v_merge_entry (pf_left, pf_entry, pf_right)
                in
                  Some_vt value
                end
              else
                (* The key is not in the tree. *)
                let
                  prval _ = tree.array_view :=
                    array_v_merge_entry (pf_left, pf_entry, pf_right)
                in
                  None_vt ()
                end
            | node_vt_list lst =>
              (* Search for the key in lst. *)
              let
                fun
                search_list {n   : int | 0 <= n} .<n>.
                            (lst : !list_vt (kv_t, n) >> _,
                             key : !key_vt >> _) :
                    Option_vt value_vt =
                  case+ lst of
                  | NIL =>
                    (* The key is not in lst. *)
                    None_vt ()
                  | @ key_value :: tail =>
                    if hashmap$key_vt_eq<key_vt>
                        (key, key_value.key) then
                      let
                        val value =
                          hashmap$value_vt_copy<value_vt>
                            (key_value.value)
                        prval _ = fold@ lst
                      in
                        (* A key-value pair was found in lst. *)
                        Some_vt value
                      end
                    else
                      (* Search the tail. *)
                      let
                        val result = search_list (tail, key)
                        prval _ = fold@ lst
                      in
                        result
                      end

                prval _ = lemma_list_vt_param lst
                val result = search_list (lst, key)

                prval _ = tree.array_view :=
                  array_v_merge_entry (pf_left, pf_entry, pf_right)
              in
                result
              end
            | node_vt_array subtree =>
              (* Search for the key in a subtree. *)
              let
                val result =
                  find_entry<hash_vt><key_vt, value_vt>
                    (hash, subtree, key, succ depth)
                prval _ = tree.array_view :=
                  array_v_merge_entry (pf_left, pf_entry, pf_right)
              in
                result
              end
          end
        else
          (* There is no array entry for the current hash bits. *)
          None_vt ()
      end
  end

implement {hash_vt} {key_vt, value_vt}
hashmap_get_opt (map, key) =
  case+ map of
  | map_vt_nil () => None_vt ()
  | map_vt_root root =>
    let
      var hash : hash_vt

      val () = hashmap$hash_function<hash_vt><key_vt> (key, hash)

      val result =
        find_entry<hash_vt><key_vt, value_vt>
          (hash, root.tree, key, i2sz 0)

      val () = hashmap$hash_vt_free<hash_vt> (hash)
    in
      result
    end

(********************************************************************)

extern fn {list_entry_vt    : vt@ype}
          {key_vt, value_vt : vt@ype}
make_list$make_list_entry
        (key_value : !key_value_vt (key_vt, value_vt) >> _) :
    list_entry_vt

fn {list_entry_vt    : vt@ype}
   {key_vt, value_vt : vt@ype}
make_list {size    : int}
          {population_map : int}
          {length  : int}
          {p_array : addr}
          (size    : size_t size,
           tree    : !node_array_vt (key_vt, value_vt, population_map,
                                     length, p_array) >> _) :
    list_vt (list_entry_vt, size) =
  let
    vtypedef k = key_vt
    vtypedef v = value_vt
    vtypedef node_vt = node_vt (k, v)

    extern praxi
    UNSAFELY_make_array_v :
      {n : int} {p : addr}
      (size_t n, ptr p) -<prf> @[node_vt][n] @ p

    extern praxi
    UNSAFELY_consume_array_v :
      {n : int} {p : addr} @[node_vt][n] @ p -<prf> void

    vtypedef stkentry_vt (n : int, i : int, p : addr) =
      @{
        length = size_t n,
        index = size_t i,
        p_array = ptr p
      }
    vtypedef stkentry_vt =
      [n : int]
      [i : int | i <= n]
      [p : addr]
      stkentry_vt (n, i, p)

    fun
    big_loop {length   : int | 0 <= length}
             {p_array  : addr}
             {index    : int | 0 <= index; index <= length}
             {stacksz  : int | 0 <= stacksz}
             {nresult  : int | 0 <= nresult}
             (pf_array : !(@[node_vt][length] @ p_array) >> _ |
              length   : size_t length,
              index    : size_t index,
              p_array  : ptr p_array,
              stack    : list_vt (stkentry_vt, stacksz),
              result   : list_vt (list_entry_vt, nresult),
              nresult  : size_t nresult) :
        [nresult : int]
        @(list_vt (list_entry_vt, nresult),
          size_t nresult) =
      (* Depth-first traversal by tail recursion.      
         Some "mildly unsafe" operations are employed. *)
      if index = length then
        begin
          case+ stack of
          | ~ NIL => @(result, nresult)
          | ~ head :: tail =>
            (* Pop a stack entry and continue where we left off
               in an array. *)
            let
              val @{
                    length = length,
                    index = index,
                    p_array = p_array
                  } = head
              prval _ = lemma_g1uint_param index

              prval pf_array1 =
                UNSAFELY_make_array_v (length, p_array)
  
              val results =
                big_loop (pf_array1 | length, index, p_array, tail,
                          result, nresult)

              prval _ = UNSAFELY_consume_array_v pf_array1
            in
              results
            end
        end
      else
        let
          val p_entry = ptr_add<node_vt> (p_array, index)

          prval @(pf_entry, fpf_restore_array) =
            array_v_takeout {node_vt} {p_array} {length} {index}
                            pf_array

          macdef entry = !p_entry
        in
          case+ entry of
          | node_vt_key_value key_value =>
            (* Cons a list entry. *)
            let
              val list_entry =
                make_list$make_list_entry<list_entry_vt><k,v>
                  (key_value)

              prval _ = pf_array := fpf_restore_array pf_entry
            in
              big_loop (pf_array | length, succ index, p_array, stack,
                        list_entry :: result, succ nresult)
            end
          | node_vt_list lst =>
            (* Cons multiple list entries. *)
            let
              fun
              loop {n       : int | 0 <= n}
                   {nresult : int | 0 <= nresult} .<n>.
                   (lst     : !list_vt (key_value_vt (k, v), n) >> _,
                    result  : list_vt (list_entry_vt, nresult),
                    nresult : size_t nresult) :
                  [nresult : int]
                  @(list_vt (list_entry_vt, nresult),
                    size_t nresult) =
                case+ lst of
                | NIL => @(result, nresult)
                | @ head :: tail =>
                  let
                    val list_entry =
                      make_list$make_list_entry<list_entry_vt><k,v>
                        (head)
                    val result_pair =
                      loop (tail, list_entry :: result, succ nresult)
                    prval _ = fold@ lst
                  in
                    result_pair
                  end

              prval _ = lemma_list_vt_param lst
              val @(result, nresult) = loop (lst, result, nresult)

              prval _ = pf_array := fpf_restore_array pf_entry

              prval _ = lemma_g1uint_param nresult
            in
              big_loop (pf_array | length, succ index, p_array, stack,
                        result, nresult)
            end
          | @ node_vt_array subtree =>
            (* The node is a subtree. Push a stack entry for
               the next position in the current array; then loop to
               handle the subtree. *)
            let
              val stack_entry =
                @{
                  length = length,
                  index = succ index,
                  p_array = p_array
                }
              val stack = stack_entry :: stack

              val [popcount : int] @(pf_popcount | popcount) =
                popcount_with_proof (subtree.population_map)
              prval _ = popcount_isfun (subtree.population_map_view,
                                        pf_popcount)
              prval _ = popcount_is_nonnegative pf_popcount
              val length = i2sz popcount

              prval pf_array_subtree =
                UNSAFELY_make_array_v (length, subtree.p_array) 

              val results =
                big_loop
                  (pf_array_subtree |
                   length, i2sz 0, subtree.p_array, stack,
                   result, nresult)

              prval _ = UNSAFELY_consume_array_v pf_array_subtree

              prval _ = fold@ entry
              prval _ = pf_array := fpf_restore_array pf_entry
            in
              results
            end
        end

    val [popcount : int] @(pf_popcount | popcount) =
      popcount_with_proof (tree.population_map)
    prval _ = popcount_isfun (tree.population_map_view, pf_popcount)
    prval _ = prop_verify {length == popcount} ()
    prval _ = popcount_is_nonnegative pf_popcount
    val length = i2sz popcount

    val @(result, nresult) =
      big_loop (tree.array_view | length, i2sz 0, tree.p_array,
                                  NIL, NIL, i2sz 0)

    (* Equality of the sizes of the hashmap and the result list
       is checked at runtime, rather than proven. *)
    val _ = assertloc (size = nresult)
  in
    result
  end

implement {key_vt, value_vt}
hashmap_pairs {size} (map) =
  case+ map of
  | map_vt_nil () => NIL
  | map_vt_root root =>
    let
      vtypedef k = key_vt
      vtypedef v = value_vt
      vtypedef list_entry_vt = @(key_vt, value_vt)

      implement
      make_list$make_list_entry<list_entry_vt><k,v> (key_value) =
        @(hashmap$key_vt_copy (key_value.key),
          hashmap$value_vt_copy (key_value.value))

      val result =
        make_list<list_entry_vt><k,v> {size} (root.size, root.tree)
    in
      result
    end

implement {key_vt, value_vt}
hashmap_keys {size} (map) =
  case+ map of
  | map_vt_nil () => NIL
  | map_vt_root root =>
    let
      vtypedef k = key_vt
      vtypedef v = value_vt
      vtypedef list_entry_vt = key_vt

      implement
      make_list$make_list_entry<list_entry_vt><k,v> (key_value) =
        hashmap$key_vt_copy (key_value.key)

      val result =
        make_list<list_entry_vt><k,v> {size} (root.size, root.tree)
    in
      result
    end

implement {key_vt, value_vt}
hashmap_values {size} (map) =
  case+ map of
  | map_vt_nil () => NIL
  | map_vt_root root =>
    let
      vtypedef k = key_vt
      vtypedef v = value_vt
      vtypedef list_entry_vt = value_vt

      implement
      make_list$make_list_entry<list_entry_vt><k,v> (key_value) =
        hashmap$value_vt_copy (key_value.value)

      val result =
        make_list<list_entry_vt><k,v> {size} (root.size, root.tree)
    in
      result
    end

(********************************************************************)

fn {key_vt, value_vt : vt@ype}
free_tree {population_map : int}
          {length         : int}
          {p_array        : addr}
          (tree : node_array_vt (key_vt, value_vt, population_map,
                                 length, p_array)) : void =
  let
    vtypedef k = key_vt
    vtypedef v = value_vt
    vtypedef node_vt = node_vt (k, v)

    vtypedef stkentry_vt (n : int, i : int, p : addr) =
      @(@[node_vt?!][i] @ p,
        @[node_vt][n - i] @ (p + i * NODESZ),
        mfree_gc_v p |
        size_t n,
        size_t i,
        ptr p)
    vtypedef stkentry_vt =
      [n : int]
      [i : int | i <= n]
      [p : addr]
      stkentry_vt (n, i, p)

    fun
    big_loop {length   : int | 0 <= length}
             {index    : int | 0 <= index; index <= length}
             {p_array  : addr}
             {stacksz  : int | 0 <= stacksz}
             (pf_left  : @[node_vt?!][index] @ p_array,
              pf_right : @[node_vt][length - index]
                            @ (p_array + index * NODESZ),
              pf_mfree : mfree_gc_v p_array |
              length   : size_t length,
              index    : size_t index,
              p_array  : ptr p_array,
              stack    : list_vt (stkentry_vt, stacksz)) : void =
      (* Depth-first traversal by tail recursion. *)
      if index = length then
        let
          val _ = array_ptr_free (pf_left, pf_mfree | p_array)
          prval _ = array_v_unnil pf_right
        in
          case+ stack of
          | ~ NIL => ()
          | ~ head :: tail =>
            (* Pop a stack entry and continue where we left off
               in an array. *)
            let
              val @(pf_left, pf_right, pf_mfree |
                    length, index, p_array) = head
              prval _ = lemma_g1uint_param index
            in
              big_loop (pf_left, pf_right, pf_mfree |
                        length, index, p_array, tail)
            end
        end
      else
        let
          val p_entry = ptr_add<node_vt> (p_array, index)
          prval @(pf_entry, pf_right1) = array_v_uncons (pf_right)
        in
          case+ !p_entry of
          | ~ node_vt_key_value key_value =>
            (* Free a key-value pair. *)
            let
              val _ = hashmap$key_vt_free<k> (key_value.key)
              val _ = hashmap$value_vt_free<v> (key_value.value)
              prval pf_left1 = array_v_extend (pf_left, pf_entry)
            in
              big_loop (pf_left1, pf_right1, pf_mfree |
                        length, succ index, p_array, stack)
            end
          | ~ node_vt_list lst =>
            (* Free a list of key-value pairs. *)
            let
              fun
              loop {n   : int | 0 <= n} .<n>.
                   (lst : list_vt (key_value_vt (k, v), n)) :
                  void =
                case+ lst of
                | ~ NIL => ()
                | ~ head :: tail =>
                  let
                    val _ = hashmap$key_vt_free<k> (head.key)
                    val _ = hashmap$value_vt_free<v> (head.value)
                  in
                    loop (tail)
                  end
              prval _ = lemma_list_vt_param lst
              val _ = loop (lst)
              prval pf_left1 = array_v_extend (pf_left, pf_entry)
            in
              big_loop (pf_left1, pf_right1, pf_mfree |
                        length, succ index, p_array, stack)
            end
          | ~ node_vt_array subtree =>
            (* The node is a subtree. Push a stack entry for
               the next position in the current array; then loop to
               handle the subtree. *)
            let
              val stack_entry =
                @(array_v_extend (pf_left, pf_entry),
                  pf_right1, pf_mfree |
                  length, succ index, p_array)
              val stack = stack_entry :: stack

              val [popcount : int] @(pf_popcount | popcount) =
                popcount_with_proof (subtree.population_map)
              prval _ = popcount_isfun (subtree.population_map_view,
                                        pf_popcount)
              prval _ = popcount_is_nonnegative pf_popcount
              val length = i2sz popcount
            in
              big_loop (array_v_nil (), subtree.array_view,
                        subtree.mfree_view |
                        length, i2sz 0, subtree.p_array, stack)
            end
        end

    val [popcount : int] @(pf_popcount | popcount) =
      popcount_with_proof (tree.population_map)
    prval _ = popcount_isfun (tree.population_map_view, pf_popcount)
    prval _ = prop_verify {length == popcount} ()
    prval _ = popcount_is_nonnegative pf_popcount
    val length = i2sz popcount
  in
    big_loop (array_v_nil (), tree.array_view, tree.mfree_view |
              length, i2sz 0, tree.p_array, NIL)
  end

implement {key_vt, value_vt}
hashmap_free (map) =
  case+ map of
  | ~ map_vt_nil () => ()
  | ~ map_vt_root @{size = _, tree = tree} =>
    free_tree<key_vt, value_vt> (tree)

(********************************************************************)
