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

staload "hashmap/SATS/array-mapped-tree-subtree-to-list-vt.sats"
staload "hashmap/SATS/array-mapped-tree-templates.sats"
staload "hashmap/SATS/uptr.sats"
staload "hashmap/SATS/ctz.sats"

staload _ = "hashmap/DATS/array-mapped-tree-templates.dats"
staload _ = "hashmap/DATS/uptr.dats"
staload _ = "hashmap/DATS/popcount.dats"
staload _ = "hashmap/DATS/ctz.dats"

#include "hashmap/HATS/array-mapped-tree-helpers.hats"

implement
array_mapped_tree_subtree_to_list_vt {length} {p} (node) =
  let
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
    big_loop {m             : int}
             (result        : list_vt (uintptr, m),
              result_length : size_t m,
              stack         : &traversal_stack_vt) :
        [n : int] @(list_vt (uintptr, n), size_t n) =
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

//        val population_map = get_population_map (node) ????????????????????????????????????????????????????????????
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
                let
                  prval _ = $UN.castvwtp0{void} node
                in
                  big_loop (result, result_length, stack)
                end
              end
            else if is_chain then
              let
                fun
                loop {m, n   : int | 0 <= m; 0 <= n}
                     (result : list_vt (uintptr, m),
                      result_length : size_t m,
                      lst : !list_vt (uintptr, n)) :
                    @(list_vt (uintptr, m + n), size_t (m + n)) =
                  case+ lst of
                  | NIL => @(result, result_length)
                  | @ head :: tail =>
                    let
                      val result_and_length =
                        loop {m + 1, n - 1}
                             (head :: result,
                              succ (result_length),
                              tail)
                      prval _ = fold@ lst
                    in
                      result_and_length
                    end
                val lst =
                  $UN.castvwtp0{List_vt uintptr} (uintptr2ptr entry)
                prval _ = lemma_list_vt_param result
                prval _ = lemma_list_vt_param lst
                val @(result, result_length) =
                  loop (result, result_length, lst)
                prval _ = $UN.castvwtp0{void} lst
                prval _ = $UN.castvwtp0{void} node
              in
                stack.top :=
                  @{
                    node_p = node_p,
                    length = length,
                    index = succ index,
                    depth = depth,
                    population = population
                  };
                big_loop (result, result_length, stack)
              end
            else (* is_leaf but not is_chain *)
              let
                prval _ = lemma_list_vt_param result
                prval _ = $UN.castvwtp0{void} node
              in
                stack.top :=
                  @{
                    node_p = node_p,
                    length = length,
                    index = succ index,
                    depth = depth,
                    population = population
                  };
                big_loop (entry :: result,
                          succ (result_length),
                          stack)
              end
          end
        else if i2sz 0 < size then 
          begin
            stack.size := pred size;
            case+ (stack.rest) of
            | NIL => ()
            | ~ head :: tail =>
              begin
                stack.top := head;
                stack.rest := tail
              end;
            let
              prval _ = $UN.castvwtp0{void} node
            in
              big_loop (result, result_length, stack)
            end
          end
        else
          let
            prval _ = $UN.castvwtp0{void} node
          in
            @(result, result_length)
          end
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

    val result_and_length = big_loop {0} (NIL, i2sz 0, stack)
  in
    begin
      case- stack.rest of
      | ~ NIL => ()
    end;
    result_and_length
  end
