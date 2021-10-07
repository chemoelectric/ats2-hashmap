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

staload UN = "prelude/SATS/unsafe.sats"

staload "hashmap/SATS/array-mapped-tree-node-vt-free.sats"
staload "hashmap/SATS/array-mapped-tree-templates.sats"
staload "hashmap/SATS/uptr.sats"
staload "hashmap/SATS/ctz.sats"

staload _ = "hashmap/DATS/array-mapped-tree-templates.dats"
staload _ = "hashmap/DATS/uptr.dats"
staload _ = "hashmap/DATS/popcount.dats"
staload _ = "hashmap/DATS/ctz.dats"

#include "hashmap/HATS/array-mapped-tree-helpers.hats"

(*
  NOTE/WARNING:

  This code is quite "unsafe" and should be tested well.

  I have implemented a counter in node_alloc and node_vt_free.
  If you run a test in which every array mapped tree is freed,
  then the counter must equal zero, or there is a problem.

  Also, if the counter would go negative, an assertion is
  triggered.

  See the regression tests.

  (NDEBUG gets rid of the counting and makes the counter
   always equal zero.)
*)

implement
node_vt_free {length} {p} (node, key_value_free) =
  let
    typedef link_t = link_vt?!

    typedef traversal_point_vt =
      @{
        node_p = uptr,
        length = Size_t,
        index = Size_t,
        depth = Size_t,
        population = uintptr
      }

    vtypedef traversal_stack_vt =
      @{
        size = Size_t,
        top = traversal_point_vt,
        rest = List_vt (traversal_point_vt)
      }

    fun
    big_loop (stack          : &traversal_stack_vt,
              key_value_free : !(uintptr -<cloptr1> void) >> _) :
        void =
      (* Depth-first traversal by tail recursion. *)
      let
        val size = stack.size
        prval _ = lemma_g1uint_param size

        val @{
              node_p = node_p,
              length = length,
              index = index,
              depth = depth,
              population = population
            } = (stack.top)

        val [length : int] length = g1ofg0 length
        prval _ = lemma_g1uint_param length

        (* Make a linear type from the uptr. *)
        val node = uptr2node_of_length {length} node_p

        val leaf_map = get_leaf_map (node)
        val chaining_map = get_chaining_map (node)
      in
        if index < length then
          let
            val bit_index = g1ofg0 (ctz<uintptrknd> (population))
            val _ = assertloc (0 <= bit_index)
            val bit_selection_mask = (one << bit_index)

            val is_leaf = bit_is_set<> (leaf_map, bit_selection_mask)
            val is_chain =
              (is_leaf &&
               bit_is_set<> (chaining_map, bit_selection_mask))

            (* Next time, skip the current bit position. *)
            val population =
              clear_bit<> (population, bit_selection_mask)

            val entry = node[index]
          in
            if not is_leaf then
              let
                val subnode = uintptr2node entry
                val subnode_population_map =
                  get_population_map (subnode)
                val @(_ | subnode_length) =
                  get_popcount (g1ofg0 subnode_population_map)
                prval _ = $UN.castvwtp0{void} subnode

                prval _ = lemma_list_vt_param (stack.rest)
              in
                stack.size := succ size;
                stack.top := 
                  @{
                    node_p = uintptr2uptr entry,
                    length = subnode_length,
                    index = i2sz 0,
                    depth = succ depth,
                    population = subnode_population_map
                  };
                stack.rest :=
                  @{
                    node_p = node_p,
                    length = length,
                    index = succ index,
                    depth = depth,
                    population = population
                  } :: (stack.rest);
                big_loop (stack, key_value_free)
              end
            else if is_chain then
              {
                fun
                loop {n   : int | 0 <= n} .<n>.
                     (lst : !list_vt (uintptr, n) >> _,
                      key_value_free :
                            !(uintptr -<cloptr1> void) >> _) : void =
                  case+ lst of
                  | NIL => ()
                  | @ head :: tail =>
                    {
                      val _ = key_value_free (head)
                      val _ = loop (tail, key_value_free)
                      prval _ = fold@ lst
                    }

                val lst =
                  $UN.castvwtp0{List_vt uintptr} (uintptr2ptr entry)
                prval _ = lemma_list_vt_param lst
                val _ = loop (lst, key_value_free)
                prval _ = $UN.castvwtp0{void} lst
                val _ = big_loop (stack, key_value_free)
              }
            else (* is_leaf but not is_chain *)
              begin
                stack.top :=
                  @{
                    node_p = node_p,
                    length = length,
                    index = succ index,
                    depth = depth,
                    population = population
                  };
                big_loop (stack, key_value_free)
              end
          end
        else if i2sz 0 < size then 
          begin
            (* Shameless cheating to free the node. *)
            expired_node_vt_free
              ($UN.castvwtp1{expired_node_vt} node);

            stack.size := pred size;
            case+ (stack.rest) of
            | NIL => ()
            | ~ head :: tail =>
              begin
                stack.top := head;
                stack.rest := tail
              end;
            big_loop (stack, key_value_free)
          end;

        (* Consume the linear type. *)
        $UN.castvwtp0{void} node;
      end

    val population_map = get_population_map (node)

    val [length : int] _ = extract_static_length_of_node node
    prval _ = lemma_node_vt_param {length} node

    val [popcount : int] @(_ | length) =
      get_popcount (g1ofg0 population_map)
    prval _ = $UN.prop_assert {popcount == length} ()

    val starting_point : traversal_point_vt =
      @{
        node_p = ptr2uptr ($UN.castvwtp1{Ptr} node),
        length = length,
        index = i2sz 0,
        depth = i2sz 0,
        population = population_map
      }

    var stack =
      @{
        size = i2sz 1,
        top = starting_point,
        rest = NIL
      }
  in
    big_loop (stack, key_value_free);
    case- stack.rest of
    | ~ NIL => ();
  
    {
      (* The node has already been freed. *)
      prval _ = $UN.castvwtp0{void} node
    }
  end
