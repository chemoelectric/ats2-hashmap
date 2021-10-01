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

staload "hashmap/SATS/array-mapped-tree-print-subtree-structure.sats"
staload "hashmap/SATS/array-mapped-tree-templates.sats"
staload "hashmap/SATS/uptr.sats"

staload _ = "hashmap/DATS/array-mapped-tree-templates.dats"
staload _ = "hashmap/DATS/uptr.dats"
staload _ = "hashmap/DATS/count-one-bits.dats"

staload "hashmap/SATS/nth-bit-index.sats"
staload "hashmap/SATS/print-bitmap.sats"

#include "hashmap/HATS/array-mapped-tree-helpers.hats"

implement
print_subtree_structure (out, node, depth, print_key_value) =
  let
    typedef traversal_point_vt =
      @{
        node_p = uptr,
        length = Size_t,
        index = Size_t,
        depth = Size_t,
        
        (* bits could overflow, but this happening would merely
           make the printout less useful. *)
        bits = ullint
      }

    vtypedef traversal_stack_vt =
      @{
        size = Size_t,
        top = traversal_point_vt,
        rest = List_vt (traversal_point_vt)
      }

    fn
    shifted_bits {bit_index : int | 0 <= bit_index}
                 (depth     : Size_t,
                  bit_index : int bit_index) : ullint =
      let
        var i : [i : int | 0 <= i] size_t i
        var result : g0uint (ullintknd) = g1i2u bit_index
      in
        for (i := i2sz 0; i < depth; i := succ i)
          result :=
            g0uint_lsl_ullint (result, SIZEOF_BITINDEXOF_UINTPTR);
        result
      end

    fn
    print_indentation {depth : int}
                      (out   : FILEref,
                       depth : size_t depth) : void =
      let
        fun
        loop {i : int | 0 <= i} .<i>.
             (i : size_t i) : void =
          if i <> i2sz 0 then
            begin
              fprint! (out, "| ");
              loop (pred i)
            end
        prval _ = lemma_g1uint_param depth
      in
        loop (depth)
      end

    fn
    print_key_value_heading {bit_index : int | 0 <= bit_index}
                            (out       : FILEref,
                             depth     : Size_t,
                             bit_index : int bit_index,
                             bits      : ullint) : void =
      begin
        print_indentation (out, depth);
        fprint! (out, "key-value (", bit_index, ", ",
                 bits + shifted_bits (depth, bit_index), "): ")
      end

    fun
    big_loop (out             : FILEref,
              print_key_value : !((FILEref, uintptr) -<cloptr1> void),
              stack           : &traversal_stack_vt) : void =
      (* Depth-first traversal by tail recursion. *)
      let
        val size = stack.size
        prval _ = lemma_g1uint_param size

        val @{
              node_p = node_p,
              length = length,
              index = index,
              depth = depth,
              bits = bits
            } = (stack.top)

        val [length : int] length = g1ofg0 length
        prval _ = lemma_g1uint_param length

        (* Make a linear type from the uptr. *)
        val node = uptr2node_of_length {length} node_p

        val population_map = get_population_map (node)
        val leaf_map = get_leaf_map (node)
        val chaining_map = get_chaining_map (node)
      in
        if index < length then
          let
            val bit_index = nth_bit_index (population_map, index)
            val bit_selection_mask = (one << bit_index)
            val is_leaf = bit_is_set<> (leaf_map, bit_selection_mask)
            val is_chain =
              (is_leaf &&
               bit_is_set<> (chaining_map, bit_selection_mask))

            val entry = node[index]

          in
            if index = i2sz 0 then
              begin
                print_indentation (out, depth);
                fprintln! (out, "depth: ", depth);
                print_indentation (out, depth);
                fprint! (out, "population_map: ");
                print_bitmap (out, population_map);
                fprintln! (out);
                print_indentation (out, depth);
                fprint! (out, "leaf_map:       ");
                print_bitmap (out, leaf_map);
                fprintln! (out);
                print_indentation (out, depth);
                fprint! (out, "chaining_map:   ");
                print_bitmap (out, chaining_map);
                fprintln! (out)
              end;

            if not is_leaf then
              let
                val subnode = uintptr2node entry
                val @(_ | subnode_length) =
                  get_popcount (g1ofg0 (get_population_map (subnode)))
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
                    bits = bits + shifted_bits (depth, bit_index)
                  };
                stack.rest :=
                  @{
                    node_p = node_p,
                    length = length,
                    index = succ index,
                    depth = depth,
                    bits = bits
                  } :: (stack.rest);
                big_loop (out, print_key_value, stack)
              end
            else if is_chain then
              {
                fun
                loop {n   : int | 0 <= n} .<n>.
                     (lst : !list_vt (uintptr, n) >> _,
                      print_key_value :
                          !((FILEref, uintptr) -<cloptr1> void),
                      separator : string) :
                    void =
                  case+ lst of
                  | NIL => ()
                  | @ head :: tail =>
                    {
                      val _ = fprint! (out, separator)
                      val _ = print_key_value (out, head)
                      val _ = loop (tail, print_key_value, " ")
                      prval _ = fold@ lst
                    }

                val lst =
                  $UN.castvwtp0{List_vt uintptr} (uintptr2ptr entry)
                prval _ = lemma_list_vt_param lst
                val _ =
                  begin
                    print_key_value_heading (out, depth, bit_index,
                                             bits);
                    fprint! (out, "(");
                    loop (lst, print_key_value, "");
                    fprintln! (out, ")")
                  end
                prval _ = $UN.castvwtp0{void} lst
              }
            else (* is_leaf but not is_chain *)
              begin
                print_key_value_heading (out, depth, bit_index, bits);
                print_key_value (out, entry);
                fprintln! (out);
                stack.top :=
                  @{
                    node_p = node_p,
                    length = length,
                    index = succ index,
                    depth = depth,
                    bits = bits
                  };
                big_loop (out, print_key_value, stack)
              end
          end
        else if i2sz 0 < size then 
          let
          in
            stack.size := pred size;
            case+ (stack.rest) of
            | NIL => ()
            | ~ head :: tail =>
              begin
                stack.top := head;
                stack.rest := tail
              end;
            big_loop (out, print_key_value, stack)
          end;

        (* Consume the linear type. *)
        { prval _ = $UN.castvwtp0{void} node }
      end

    val population_map = get_population_map (node)

    val [length : int] _ = extract_static_length_of_node node
    prval _ = lemma_node_vt_param {length} node

    val [popcount : int] @(_ | length) =
      get_popcount (g1ofg0 population_map)
    prval _ = $UN.prop_assert {popcount == length} ()

    stadef index = 0
    val index : size_t index = i2sz 0

    stadef depth = 0
    val depth : size_t depth = i2sz 0

    prval _ = prop_verify {0 <= length} ()
    prval _ = prop_verify {0 <= index} ()
    prval _ = prop_verify {index <= length} ()
    prval _ = prop_verify {0 <= depth} ()

    val starting_point : traversal_point_vt =
      @{
        node_p = ptr2uptr ($UN.castvwtp1{Ptr} node),
        length = length,
        index = index,
        depth = depth,
        bits = 0ULL
      }

    var stack =
      @{
        size = i2sz 1,
        top = starting_point,
        rest = NIL
      }
  in
    big_loop (out, print_key_value, stack);
    case- stack.rest of
    | ~ NIL => ()
  end
