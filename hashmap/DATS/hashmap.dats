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
staload "hashmap/SATS/memory.sats"
staload "hashmap/SATS/population_map.sats"
staload "popcount/SATS/popcount.sats"

staload _ = "hashmap/DATS/bits_source.dats"
staload _ = "hashmap/DATS/population_map.dats"
staload _ = "hashmap/DATS/memory.dats"
staload _ = "popcount/DATS/popcount.dats"

#define NIL list_vt_nil ()
#define :: list_vt_cons

#define CHAR_BIT 8              (* The size of a byte, in bits. *)

prval _ = lemma_sizeof {population_map_t} ()

prval _ =
  $UN.prop_assert
    {BITS_SOURCE_MAXVAL == CHAR_BIT * sizeof (population_map_t) - 1}
    ()

(*
  A "view tunnel": view v enters through the entry, then exits
  through the exit.

  FIXME:
  This "view tunnel" seems to me "safe", and good for informal proof,
  as long as you use the "entry" before you use the "exit".
  One avoids tedious passing-around of proof objects, views, etc.
  But is there a *nice* way to *ensure* the entry and exit are used
  in the correct order?

  (If the exit runs before the entry, then you may have two copies of
  the view at the same time, thus violating linearity. One may or may
  not consider this a problem.)
*)
extern praxi
make_view_tunnel :
  {v : view}
  (!v >> _) -<prf>
    @{
      entry = v -<lin,prf> void,
      exit = () -<lin,prf> v
    }

fn {}
orelse1 {x, y : bool}
        (x : bool x,
         y : bool y) :<>
    [z : bool | z == (x || y)]
    bool z =
  if x then
    true
  else
    y
infixl ( || ) |||
macdef ||| = orelse1

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
    population_map_prop = POPCOUNT (population_map, length),
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

fn {key_vt, value_vt : vt@ype}
extract_key_value (node : node_vt (key_vt, value_vt)) :
    key_value_vt (key_vt, value_vt) =
  case- node of
  | ~ node_vt_key_value key_value => key_value

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

fn {key_vt, value_vt : vt@ype}
make_new_length1_node_array
        {bits  : int | bits_source_valid_bits bits}
        (bits  : int bits,
         key   : key_vt,
         value : value_vt) :
    [population_map : int]
    [p_array        : addr]
    node_array_vt (key_vt, value_vt, population_map, 1, p_array) =
  let
    val [population_map : int] population_map =
      bits_to_population_map (bits)
    prval _ =
      $UN.prop_assert {popcount_relation (population_map, 1)} ()
    prval pf_popcount =
      popcount_relation_to_proof {population_map} {1} ()

    val @(pf_array, pf_mfree | p_array) =
      make_new_array<key_vt, value_vt>
        (pf_popcount | population_map, key, value)
  in
    @{
      population_map_prop = pf_popcount,
      array_view = pf_array,
      mfree_view = pf_mfree |
      population_map = population_map,
      p_array = p_array
    }
  end

fn {hash_vt : vt@ype}
   {key_vt, value_vt : vt@ype}
set_entry {size  : int | 1 <= size}
          (size  : size_t size,
           tree  : node_array_vt (key_vt, value_vt),
           hash  : &hash_vt >> _,
           key   : key_vt,
           value : value_vt) :
    [new_size : int | new_size == size || new_size == size + 1]
    @{
      size = size_t new_size,
      tree = node_array_vt (key_vt, value_vt)
    } =
  let
    vtypedef t = node_vt (key_vt, value_vt)
    vtypedef kv_t = key_value_vt (key_vt, value_vt)

    (* We shall need storage for a hash of an internal key.
       Pretend it is already initialized. *)
    var hash2 : hash_vt
    var hash2_is_set : Bool = false
    prval _ = $UN.castview2void_at{hash_vt} (view@ hash2)

    fn
    stored_key_to_hash2
            {hash2_is_set : bool}
            (stored_key   : !key_vt >> _,
             hash2        : &hash_vt >> _,
             hash2_is_set : &(bool hash2_is_set) >> bool true) :
        void =
      if not hash2_is_set then
        let
          prval _ = $UN.castview2void_at{hash_vt?} (view@ hash2)
        in
          hashmap$hash_function<hash_vt><key_vt> (stored_key, hash2);
          hash2_is_set := true
        end

    fn
    hash2_free {hash2_is_set : bool}
               (hash2        : &hash_vt >> hash_vt?,
                hash2_is_set : &(bool hash2_is_set) >> Bool?!) :
        void =
      if hash2_is_set then
        hashmap$hash_vt_free<hash_vt> (hash2)
      else
        let
          extern castfn
          fake_free : (&hash_vt >> hash_vt?) -> void
        in
          fake_free (hash2)
        end

    fun
    big_loop {size           : int | 1 <= size}
             {hash2_is_set   : bool}
             {bits           : int | bits_source_valid_bits bits}
             {depth          : int}
             (size           : &size_t size >> size_t new_size,
              node           : &node_vt (key_vt, value_vt) >> _,
              hash1          : &hash_vt >> _,
              hash2          : &hash_vt >> _,
              hash2_is_set   : &(bool hash2_is_set) >> Bool,
              bits           : int bits,
              depth          : uint depth,
              key            : key_vt,
              value          : value_vt) :
        #[new_size : int | new_size == size || new_size == size + 1]
        void =
      (* A tail-recursive implementation. *)
      let
        val- @ node_vt_array tree = node

        (* Get the statics for "tree", via a bit of trickery. *)
        prval [population_map : int]
              [length : int]
              [p_array : addr]
              tree_tmp =
          (tree : [population_map : int]
                  [length         : int]
                  [p_array        : addr]
                  node_array_vt (key_vt, value_vt, population_map,
                                 length, p_array))
        prval _ = $effmask_wrt tree := tree_tmp

        val [mask : int] mask = bits_to_population_map (bits)
        val population_map = (tree.population_map)
        val array_has_an_entry = isneqz (population_map land mask)
      in
        if array_has_an_entry then
          let
            val [array_index : int] @(pf_array_index | array_index) =
              popcount_low_bits_with_proof<population_map_kind>
                (population_map, i2u bits)
            prval _ = popcount_low_bits_is_nonnegative pf_array_index
            prval _ = prop_verify {0 <= array_index} ()

            (* FIXME: Prove this. It is true if any of
                      bits i, i+1, ..., is set in the population map.
                      (That is: if (1<<i) <= popcount.)
                      This is satisfied by ‘array_has_an_entry’.
                      The trouble is we do not yet have, in this
                      package, proof-time bitwise operations
                      on population_map_t. *)
            prval _ = $UN.prop_assert {array_index < length} ()

            val p_entry = ptr_add<t> (tree.p_array, array_index)
            prval @(pf_left, pf_entry, pf_right) =
              array_v_isolate_entry {t} {..} {length} {array_index}
                                    (tree.array_view)
            macdef entry = !p_entry
          in
            case+ entry of
            | @ node_vt_key_value key_value =>
              let
                macdef k = (key_value.key)
                macdef v = (key_value.value)
              in
                if hashmap$key_vt_eq<key_vt> (key, k) then
                  (* A key-value pair was found. Replace it. The map
                     does not grow. *)
                  {
                    val _ = hashmap$key_vt_free<key_vt> (k)
                    val _ = hashmap$value_vt_free<value_vt> (v)
                    val _ = key_value.key := key
                    val _ = key_value.value := value
                    prval _ = fold@ entry
                    prval _ = tree.array_view :=
                      array_v_merge_entry (pf_left, pf_entry, pf_right)
                    prval _ = fold@ node
                  }
                else
                  (* The key is not in the tree, but some of its
                     hash bits were matched. Either a new node or
                     separate chaining is required. The map will
                     grow by one. *)
                  let
                    (* More bits of the stored key's hash
                       will be needed. *)
                    val _ =
                      stored_key_to_hash2 (k, hash2, hash2_is_set)

                    val bits1 =
                      hashmap$bits_source<hash_vt> (hash1, succ depth)
                    val bits2 =
                      hashmap$bits_source<hash_vt> (hash2, succ depth)
                  in
                    if (bits1 = BITS_SOURCE_EXHAUSTED |||
                        bits2 = BITS_SOURCE_EXHAUSTED) then
                      (* All of the available hash bits are matched.
                         Separate chaining is required. *)
                      {
                        prval _ = fold@ entry

                        val- ~ node_vt_key_value kv = entry
                        val lst =
                          @{key = key, value = value} :: kv :: NIL
                        val new_node = node_vt_list lst
                        val _ =
                          ptr_set<t> (pf_entry | p_entry, new_node)

                        prval _ = tree.array_view :=
                          array_v_merge_entry (pf_left, pf_entry, pf_right)
                        prval _ = fold@ node
                      }
                    else
                      (* We have come upon a point where the hash bits
                         diverge. Create a new node, which will
                         contain only the old entry; store it in the
                         old location; and then do a loop. *)
                      {
                        prval _ = fold@ entry

                        (* Remove the old entry from the
                           existing array. *)
                        val key_value = extract_key_value entry
                        val @{key = k, value = v} = key_value

                        (* Make a new entry, containing a
                           new array of length one. *)
                        val subtree =
                          make_new_length1_node_array (bits2, k, v)
                        val new_node = node_vt_array subtree
                        val _ =
                          ptr_set<t> (pf_entry | p_entry, new_node)

                        (* Tail recursion. *)
                        val () =
                          big_loop (size, entry, hash1, hash2,
                                    hash2_is_set, bits1, succ depth,
                                    key, value)

                        prval _ = tree.array_view :=
                          array_v_merge_entry
                            (pf_left, pf_entry, pf_right)

                        prval _ = fold@ node
                      }
                  end
              end
            | node_vt_list lst =>
              (* Search for the key in lst. *)
              let
(*
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
*)

                prval _ = tree.array_view :=
                  array_v_merge_entry (pf_left, pf_entry, pf_right)
                prval _ = fold@ node
              in
                $UN.castvwtp0{void} key; // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME
                $UN.castvwtp0{void} value; // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME
              end
            | node_vt_array subtree =>
              (* Search for the key in a subtree. *)
              {
                (* The next set of bits. *)
                val bits1 =
                  hashmap$bits_source<hash_vt> (hash1, succ depth)

                (* In a properly designed hashmap, with hash and
                   bits source functions working as they should,
                   the bits cannot be exhausted. Otherwise there
                   would be no subnode here. *)
                val _ = assertloc (bits1 <> BITS_SOURCE_EXHAUSTED)

                (* Tail recursion. *)
                val () = big_loop (size, entry, hash1, hash2,
                                   hash2_is_set, bits1, succ depth,
                                   key, value)

                prval _ = tree.array_view :=
                  array_v_merge_entry (pf_left, pf_entry, pf_right)

                prval _ = fold@ node
              }
          end
        else
          (* There is no entry in the current node for such a value
             of the hash bits. Expand the node. The size of the map
             will increase by one. *)
          {
            val @{
                  population_map_prop = pf_popcount,
                  array_view = pf_array,
                  mfree_view = pf_mfree |
                  population_map = population_map,
                  p_array = p_array
                } = tree

            val [array_index : int] @(pf_array_index | array_index) =
              popcount_low_bits_with_proof<population_map_kind>
                (population_map, i2u bits)
            prval _ = popcount_low_bits_is_nonnegative pf_array_index
            prval _ = prop_verify {0 <= array_index} ()

            (* FIXME: Prove this. *)
            prval _ = $UN.prop_assert {array_index < length} ()

            val [new_population_map : int] new_population_map =
              population_map lor mask

            val [new_popcount : int]
                @(pf_new_popcount | new_popcount) =
              popcount_with_proof (new_population_map)
            prval _ = popcount_param (pf_new_popcount |
                                      new_population_map)

            (* FIXME: Prove this. *)
            prval _ = $UN.prop_assert {new_popcount == length + 1} ()

            val [p_new_array : addr]
                @(pf_new_array, pf_new_mfree | p_new_array) =
              array_ptr_alloc<t> (i2sz new_popcount)

            val p_new_entry = ptr_add<t> (p_new_array, array_index)

            prval @(pf_left, pf_right) =
              array_v_subdivide2 {t} {p_array}
                                 {array_index, length - array_index}
                                 pf_array
            prval @(qf_left, qf_entry, qf_right) =
              array_v_isolate_entry {t?} {p_new_array} {length + 1}
                                    {array_index}
                                    pf_new_array

            val _ =
              array_move<t> (qf_left, pf_left |
                             p_new_array, p_array, i2sz array_index)

            val new_entry =
              node_vt_key_value @{key = key, value = value}
            val _ = ptr_set<t> (qf_entry | p_new_entry, new_entry)

            val _ =
              array_move<t> (qf_right, pf_right |
                             ptr_succ<t> (p_new_entry),
                             ptr_add<t> (p_array, i2sz array_index),
                             i2sz (new_popcount - succ array_index))

            prval _ = pf_array :=
              array_v_join2 {t?} {p_array}
                            {array_index, length - array_index}
                            (pf_left, pf_right)
            prval _ = pf_new_array :=
              array_v_merge_entry {t} {p_new_array} {length + 1}
                                  {array_index}
                                  (qf_left, qf_entry, qf_right)

            val _ = array_ptr_free (pf_array, pf_mfree | p_array)
            
            val new_tree =
              @{
                population_map_prop = pf_new_popcount,
                array_view = pf_new_array,
                mfree_view = pf_new_mfree |
                population_map = new_population_map,
                p_array = p_new_array
              }

            val _ = tree := new_tree
            val _ = size := succ size

            prval _ = fold@ node
          }
      end

    val bits = hashmap$bits_source<hash_vt> (hash, 0U)

    var sz : [sz : int | sz == size || sz == size + 1] size_t sz
    var node : node_vt (key_vt, value_vt)
    
    val _ = sz := size
    val _ = node := node_vt_array tree
    val _ =
      big_loop (sz, node, hash, hash2, hash2_is_set, bits, 0U,
                key, value)

    val _ = hash2_free (hash2, hash2_is_set)
  in
    case- node of
    | ~ node_vt_array tree => @{size = sz, tree = tree}
  end

implement {hash_vt} {key_vt, value_vt}
hashmap_set {size} (map, key, value) =
  case+ map of
  | ~ map_vt_nil () =>
    let
      var hash : hash_vt

      val () = hashmap$hash_function<hash_vt><key_vt> (key, hash)
      val bits = hashmap$bits_source<hash_vt> (hash, 0U)
      val () = hashmap$hash_vt_free<hash_vt> (hash)

      val tree = make_new_length1_node_array (bits, key, value)
    in
      map_vt_root @{size = i2sz 1, tree = tree}
    end
  | @ map_vt_root root =>
    let
      val @{size = size, tree = tree} = root

      var hash : hash_vt

      val () = hashmap$hash_function<hash_vt><key_vt> (key, hash)

      val @{size = new_size, tree = new_tree} =
        set_entry {size} (size, tree, hash, key, value)
      val _ = root.size := new_size
      val _ = root.tree := new_tree

      val () = hashmap$hash_vt_free<hash_vt> (hash)

      prval _ = fold@ map
    in
      map
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
            depth   : uint depth) : Option_vt (value_vt) =
  let
    vtypedef t = node_vt (key_vt, value_vt)
    vtypedef kv_t = key_value_vt (key_vt, value_vt)

    val [bits : int] bits = hashmap$bits_source<hash_vt> (hash, depth)
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
          (hash, root.tree, key, 0U)

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

    vtypedef stkentry_vt (n : int, i : int, p : addr) =
      @{
        pf_array = @[node_vt][n] @ p,
        fpf_consume_array = @[node_vt][n] @ p -<lin,prf> void |
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
             (pf_array : @[node_vt][length] @ p_array |
              length   : size_t length,
              index    : size_t index,
              p_array  : ptr p_array,
              stack    : list_vt (stkentry_vt, stacksz),
              result   : list_vt (list_entry_vt, nresult),
              nresult  : size_t nresult) :
        [nresult : int]
        @(@[node_vt][length] @ p_array |
          list_vt (list_entry_vt, nresult),
          size_t nresult) =
      (* Depth-first traversal by tail recursion. *)
      if index = length then
        begin
          case+ stack of
          | ~ NIL => @(pf_array | result, nresult)
          | ~ head :: tail =>
            (* Pop a stack entry and continue where we left off
               in an array. *)
            let
              val @{
                    pf_array = pf_parent,
                    fpf_consume_array = fpf_consume_parent |
                    length = length,
                    index = index,
                    p_array = p_array
                  } = head

              prval _ = lemma_g1uint_param index

              val @(pf_parent | result, nresult) =
                big_loop (pf_parent | length, index, p_array, tail,
                                      result, nresult)

              prval _ = fpf_consume_parent pf_parent
            in
              @(pf_array | result, nresult)
            end
        end
      else
        let
          val p_entry = ptr_add<node_vt> (p_array, index)
          prval @(pf_entry, fpf_restore_array) =
            array_v_takeout {node_vt} {p_array} {length} {index}
                            pf_array

          (* Move the view to entry_value. This way we do not have
             to use fold@ *)
          val entry_value = ptr_get<node_vt> (pf_entry | p_entry)
        in
          case+ entry_value of
          | node_vt_key_value key_value =>
            (* Cons a list entry. *)
            let
              (* Restore the array. *)
              prval _ =
                $effmask_wrt
                  ptr_set<node_vt> (pf_entry | p_entry, entry_value)
              prval pf_array = fpf_restore_array pf_entry

              val list_entry =
                make_list$make_list_entry<list_entry_vt><k,v>
                  (key_value)
            in
              big_loop (pf_array |
                        length, succ index, p_array, stack,
                        list_entry :: result, succ nresult)
            end
          | node_vt_list lst =>
            (* Cons multiple list entries. *)
            let
              (* Restore the array. *)
              prval _ =
                $effmask_wrt
                  ptr_set<node_vt> (pf_entry | p_entry, entry_value)
              prval pf_array = fpf_restore_array pf_entry

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

              prval _ = lemma_g1uint_param nresult
            in
              big_loop (pf_array | length, succ index, p_array, stack,
                        result, nresult)
            end
          | node_vt_array subtree =>
            (* The node is a subtree. Push a stack entry for
               the next position in the current array; then loop to
               handle the subtree. *)
            let
              (* Restore the parent tree's array. This way, one avoids
                 the need for fold@. *)
              prval _ =
                $effmask_wrt 
                  ptr_set<node_vt> (pf_entry | p_entry, entry_value)
              prval pf_array = fpf_restore_array pf_entry

              prval @{
                      entry = fpf_tunnel_entry,
                      exit = fpf_tunnel_exit
                    } = make_view_tunnel pf_array

              val stack_entry =
                @{
                  pf_array = pf_array,
                  fpf_consume_array = fpf_tunnel_entry |
                  length = length,
                  index = succ index,
                  p_array = p_array
                }
              val stack = stack_entry :: stack

              val [popcount : int] @(pf_popcount | popcount) =
                popcount_with_proof (subtree.population_map)
              prval _ = popcount_isfun (subtree.population_map_prop,
                                        pf_popcount)
              prval _ = popcount_is_nonnegative pf_popcount
              val length = i2sz popcount

              val @(pf_subtree_array | result, nresult) =
                big_loop (subtree.array_view |
                          length, i2sz 0, subtree.p_array, stack,
                          result, nresult)
              prval _ = subtree.array_view := pf_subtree_array
            in
              @(fpf_tunnel_exit () | result, nresult)
            end
        end

    val [popcount : int] @(pf_popcount | popcount) =
      popcount_with_proof (tree.population_map)
    prval _ = popcount_isfun (tree.population_map_prop, pf_popcount)
    prval _ = prop_verify {length == popcount} ()
    prval _ = popcount_is_nonnegative pf_popcount
    val length = i2sz popcount

    val @(pf_array | result, nresult) =
      big_loop (tree.array_view | length, i2sz 0, tree.p_array,
                                  NIL, NIL, i2sz 0)
    prval _ = tree.array_view := pf_array

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
              prval _ = popcount_isfun (subtree.population_map_prop,
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
    prval _ = popcount_isfun (tree.population_map_prop, pf_popcount)
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

fn {key_vt, value_vt : vt@ype}
fprint_tree
        {population_map : int}
        {length         : int}
        {p_array        : addr}
        (f              : FILEref,
         tree           : !(node_array_vt (key_vt, value_vt,
                                           population_map,
                                           length, p_array)) >> _,
         key_fprint     : !((FILEref, !key_vt >> _)
                                -<cloptr1> void) >> _,
         value_fprint   : !((FILEref, !value_vt >> _)
                                -<cloptr1> void) >> _) : void =
  (* FIXME: Have this print out useful information such as the
            bits for getting to the entries. *)
  let
    fn
    fprint_indentation
            {depth : int}
            (f     : FILEref,
             depth : uint depth) : void =
      let
        var i : [i : int | 0 <= i] uint i
      in
        for (i := 0U; i < depth; i := succ i)
          fprint! (f, "         ")
      end

    fn
    fprint_population_map
            (f              : FILEref,
             population_map : population_map_t) : void =
      let
        var buf = @[char][65] ('\0')
        var i : [i : int | 0 <= i; i <= 64] int i
      in
        for (i := 0; i <> 64; i := succ i)
          let
            val mask = bits_to_population_map i
          in
            if isneqz (population_map land mask) then
              buf[63 - i] := '1'
            else
              buf[63 - i] := '0'
          end;
        fprint! (f, "[", $UNSAFE.cast{string (64)} (addr@ buf), "]")
      end

    fn
    fprint_bits (f    : FILEref,
                 bits : uint) : void =
      fprint! (f, "[", bits, "]")

    fn
    infer_bits {index   : int}
               (pop_map : population_map_t,
                index   : size_t index) : uint =
      (* This implementation does not try to be efficient. *)
      let
        val one = $UN.cast{population_map_t} 1
        typedef t = [i : int | 0 <= i] int i
        var i : t = 0
        var j : t = 0
        var result : t = 0
      in
        while (i <= sz2i index && j < 64 && result < 64)
          begin
            while (iseqz (pop_map land (one << j)))
              j := succ j;
            result := j;
            j := succ j;
            i := succ i
          end;
        i2u result
      end

    vtypedef k = key_vt
    vtypedef v = value_vt
    vtypedef node_vt = node_vt (k, v)

    vtypedef stkentry_vt (n : int, i : int, p : addr) =
      @{
        pf_array = @[node_vt][n] @ p,
        fpf_consume_array = @[node_vt][n] @ p -<lin,prf> void |
        population_map = population_map_t,
        length = size_t n,
        index = size_t i,
        p_array = ptr p
      }
    vtypedef stkentry_vt =
      [n : int]
      [i : int | i <= n]
      [p : addr]
      stkentry_vt (n, i, p)

    vtypedef key_fprint_vt =
      (FILEref, !key_vt >> _) -<cloptr1> void
    vtypedef value_fprint_vt =
      (FILEref, !value_vt >> _) -<cloptr1> void

    fun
    big_loop {length   : int | 0 <= length}
             {p_array  : addr}
             {index    : int | 0 <= index; index <= length}
             {stacksz  : int | 0 <= stacksz}
             {depth    : int | 0 <= depth}
             (pf_array : @[node_vt][length] @ p_array |
              pop_map  : population_map_t,
              length   : size_t length,
              index    : size_t index,
              p_array  : ptr p_array,
              stack    : list_vt (stkentry_vt, stacksz),
              depth    : uint depth,
              key_fprint : !key_fprint_vt >> _,
              value_fprint : !value_fprint_vt >> _) :
        @(@[node_vt][length] @ p_array | ) =
      (* Depth-first traversal by tail recursion. *)
      if index = length then
        begin
          case+ stack of
          | ~ NIL => @(pf_array | )
          | ~ head :: tail =>
            (* Pop a stack entry and continue where we left off
               in an array. *)
            let
              val @{
                    pf_array = pf_parent,
                    fpf_consume_array = fpf_consume_parent |
                    population_map = pop_map,
                    length = length,
                    index = index,
                    p_array = p_array
                  } = head

              prval _ = lemma_g1uint_param index

              val _ = assertloc (1U <= depth)
              val @(pf_parent | ) =
                big_loop (pf_parent | pop_map, length, index, p_array,
                                      tail, pred depth, key_fprint,
                                      value_fprint)

              prval _ = fpf_consume_parent pf_parent
            in
              @(pf_array | )
            end
        end
      else
        let
          val _ =
            if iseqz index then
              begin
                fprintln! (f, "depth (", depth, ")");

                fprint_indentation (f, depth);
                fprint_population_map (f, pop_map);
                fprintln! (f)
              end

          val p_entry = ptr_add<node_vt> (p_array, index)
          prval @(pf_entry, fpf_restore_array) =
            array_v_takeout {node_vt} {p_array} {length} {index}
                            pf_array

          (* Move the view to entry_value. This way we do not have
             to use fold@ *)
          val entry_value = ptr_get<node_vt> (pf_entry | p_entry)
        in
          case+ entry_value of
          | node_vt_key_value key_value =>
            (* Print a key-value pair. *)
            let
              (* Restore the array. *)
              prval _ =
                $effmask_wrt
                  ptr_set<node_vt> (pf_entry | p_entry, entry_value)
              prval pf_array = fpf_restore_array pf_entry

              val _ = fprint_indentation (f, depth)
              val _ = fprint_bits (f, infer_bits (pop_map, index))
              val _ = fprint! (f, " (")
              val _ = key_fprint (f, key_value.key)
              val _ = fprint! (f, " . ")
              val _ = value_fprint (f, key_value.value)
              val _ = fprintln! (f, ")")
            in
              big_loop (pf_array | pop_map, length, succ index,
                                   p_array, stack, depth,
                                   key_fprint, value_fprint)
            end
          | node_vt_list lst =>
            (* Print multiple key-value pairs. *)
            let
              (* Restore the array. *)
              prval _ =
                $effmask_wrt
                  ptr_set<node_vt> (pf_entry | p_entry, entry_value)
              prval pf_array = fpf_restore_array pf_entry

              fun
              loop {n       : int | 0 <= n} .<n>.
                   (lst     : !list_vt (key_value_vt (k, v), n) >> _,
                    separator : string,
                    key_fprint : !key_fprint_vt >> _,
                    value_fprint : !value_fprint_vt >> _) : void =
                case+ lst of
                | NIL => ()
                | @ head :: tail =>
                  {
                    val _ = fprint_indentation (f, depth)
                    val _ = fprint! (f, separator)
                    val _ = fprint! (f, "(")
                    val _ = key_fprint (f, head.key)
                    val _ = fprint! (f, " . ")
                    val _ = value_fprint (f, head.value)
                    val _ = fprint! (f, ")")
                    val _ = loop (tail, " ", key_fprint, value_fprint)
                    prval _ = fold@ lst
                  }
              prval _ = lemma_list_vt_param lst
              val _ = fprint_indentation (f, depth)
              val _ = fprint_bits (f, infer_bits (pop_map, index))
              val _ = fprint! (f, " (")
              val _ = loop (lst, "", key_fprint, value_fprint)
              val _ = fprint_indentation (f, depth)
              val _ = fprintln! (f, ")")
            in
              big_loop (pf_array | pop_map, length, succ index,
                                   p_array, stack, depth,
                                   key_fprint, value_fprint)
            end
          | node_vt_array subtree =>
            (* The node is a subtree. Push a stack entry for
               the next position in the current array; then loop to
               handle the subtree. *)
            let
              (* Restore the parent tree's array. This way, one avoids
                 the need for fold@. *)
              prval _ =
                $effmask_wrt 
                  ptr_set<node_vt> (pf_entry | p_entry, entry_value)
              prval pf_array = fpf_restore_array pf_entry

              prval @{
                      entry = fpf_tunnel_entry,
                      exit = fpf_tunnel_exit
                    } = make_view_tunnel pf_array

              val stack_entry =
                @{
                  pf_array = pf_array,
                  fpf_consume_array = fpf_tunnel_entry |
                  population_map = pop_map,
                  length = length,
                  index = succ index,
                  p_array = p_array
                }
              val stack = stack_entry :: stack

              val [popcount : int] @(pf_popcount | popcount) =
                popcount_with_proof (subtree.population_map)
              prval _ = popcount_isfun (subtree.population_map_prop,
                                        pf_popcount)
              prval _ = popcount_is_nonnegative pf_popcount
              val length = i2sz popcount

              val _ =
                begin
                  fprint_indentation (f, depth);
                  fprint_bits (f, infer_bits (pop_map, index));
                  fprint! (f, " ")
                end

              val @(pf_subtree_array | ) =
                big_loop (subtree.array_view |
                          subtree.population_map,
                          length, i2sz 0, subtree.p_array, stack,
                          succ depth, key_fprint, value_fprint)
              prval _ = subtree.array_view := pf_subtree_array
            in
              @(fpf_tunnel_exit () | )
            end
        end

    val [popcount : int] @(pf_popcount | popcount) =
      popcount_with_proof (tree.population_map)
    prval _ = popcount_isfun (tree.population_map_prop, pf_popcount)
    prval _ = prop_verify {length == popcount} ()
    prval _ = popcount_is_nonnegative pf_popcount
    val length = i2sz popcount

    val @(pf_array | ) =
      big_loop (tree.array_view | tree.population_map, length, i2sz 0,
                                  tree.p_array, NIL, 0U, key_fprint,
                                  value_fprint)
    prval _ = tree.array_view := pf_array
  in
  end

implement {key_vt, value_vt}
hashmap_fprint (f, map, key_fprint, value_fprint) =
  case+ map of
  | map_vt_nil () =>
    fprintln! (f, "size (0)")
  | map_vt_root root =>
    begin
      fprintln! (f, "size (", root.size, ")");
      fprint_tree<key_vt, value_vt> (f, root.tree, key_fprint,
                                     value_fprint)
    end

(********************************************************************)
