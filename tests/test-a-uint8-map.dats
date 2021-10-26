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

staload "hashmap/SATS/hashmap.sats"
staload "hashmap/SATS/bits_source.sats"

staload _ = "hashmap/DATS/hashmap.dats"
staload _ = "hashmap/DATS/bits_source.dats"
staload _ = "hashmap/DATS/memory.dats"
staload _ = "hashmap/DATS/population_map.dats"
staload _ = "popcount/DATS/popcount.dats"

#define NIL list_vt_nil ()
#define :: list_vt_cons

macdef cast8 = $UNSAFE.cast{uint8}

implement
gcompare_val_val<uint8> (x, y) =
  compare (x, y)

implement
list_vt_mergesort$cmp<@(uint8, int)> (x, y) =
  compare (x.0, y.0)

local

  typedef hash_t = uint8
  typedef key_t = uint8
  typedef value_t = int

  implement
  hashmap$hash_function<hash_t><key_t> (key, hash) =
    hash := key

  implement
  hashmap$hash_vt_free<hash_t> (hash) =
    ()

  implement
  hashmap$bits_source<hash_t> (hash, depth) =
    bits_source_uint8 (hash, depth)

  implement
  hashmap$key_vt_free<key_t> (key) =
    ()

  implement
  hashmap$value_vt_free<value_t> (value) =
    ()

  implement
  hashmap$key_vt_copy<key_t> (key) =
    key

  implement
  hashmap$value_vt_copy<value_t> (value) =
    value

  implement
  hashmap$key_vt_eq<key_t> (key_arg, key_stored) =
    key_arg = key_stored

in

  vtypedef my_map_vt (size : int) = hashmap_vt (key_t, value_t, size)
  vtypedef my_map_vt = [size : int] my_map_vt (size)

  fn
  my_map_set
          {size  : int}
          (map   : my_map_vt size,
           key   : key_t,
           value : value_t) :
      [new_size : int | new_size == size || new_size == size + 1]
      my_map_vt new_size =
    hashmap_set<hash_t><key_t, value_t> {size} (map, key, value)

  fn
  my_map_get_opt
          {size : int}
          (map  : !my_map_vt size >> _,
           key  : !key_t >> _) :
      Option_vt (value_t) =
    hashmap_get_opt<hash_t><key_t, value_t> {size} (map, key)

  fn
  my_map_pairs
          {size : int}
          (map  : !my_map_vt size >> _) :
      list_vt (@(key_t, value_t), size) =
    hashmap_pairs<key_t, value_t> {size} map

  fn
  my_map_keys
          {size : int}
          (map  : !my_map_vt size >> _) :
      list_vt (key_t, size) =
    hashmap_keys<key_t, value_t> {size} map

  fn
  my_map_values
          {size : int}
          (map  : !my_map_vt size >> _) :
      list_vt (value_t, size) =
    hashmap_values<key_t, value_t> {size} map

  fn
  my_map_free
          {size : int}
          (map  : my_map_vt size) : void =
    hashmap_free<key_t, value_t> (map)
  overload free with my_map_free of 10

  (* - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)
  (* Support for "imperative" style. *)

  fn
  my_map_var_set
          {size  : int}
          (map   : &my_map_vt size >> my_map_vt new_size,
           key   : key_t,
           value : value_t) :
      #[new_size : int | new_size == size || new_size == size + 1]
      void =
    map := my_map_set {size} (map, key, value)

  (* map[key] := value *)
  overload [] with my_map_var_set

  (* val- Some_vt value = map[key1] *)
  (* val- None_vt () = map[key2]    *)
  (* Etc.                           *)
  overload [] with my_map_get_opt

  (* - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)

end

fn
test1 () : void =
  {
    val map = hashmap ()
    val- 0 = sz2i (size map)
    val- true = iseqz map
    val- false = isneqz map

    val pairs = my_map_pairs map
    val keys = my_map_keys map
    val values = my_map_values map
    val _ = assertloc (length pairs = 0)
    val _ = assertloc (length keys = 0)
    val _ = assertloc (length values = 0)
    val+ ~ NIL = pairs
    val+ ~ NIL = keys
    val+ ~ NIL = values

    val map = my_map_set (map, cast8 2, 36)
    val- 1 = sz2i (size map)
    val- false = iseqz map
    val- true = isneqz map

    val- ~Some_vt 36 = my_map_get_opt (map, cast8 2)
    val- ~Some_vt value = my_map_get_opt (map, cast8 2)
    val- 36 = value
    val- ~None_vt () = my_map_get_opt (map, cast8 3)

    fun
    loop {size : int}
         {i    : int | 0 <= i; i <= 256} .<256 - i>.
         (map  : !my_map_vt size >> _,
          i    : uint i) : void =
      if i <> 256U then
        case+ my_map_get_opt (map, cast8 i) of
        | ~ Some_vt n =>
          begin
            assertloc (i = 2U);
            assertloc (n = 36);
            loop (map, succ i)
          end
        | ~ None_vt () =>
          begin
            assertloc (i <> 2U);
            loop (map, succ i)
          end
    val _ = loop {1} (map, 0U)

    val pairs = my_map_pairs map
    val keys = my_map_keys map
    val values = my_map_values map
    val _ = assertloc (length pairs = 1)
    val _ = assertloc (length keys = 1)
    val _ = assertloc (length values = 1)
    val+ ~ @(key, value) :: tail = pairs
    val+ ~ NIL = tail
    val _ = assertloc (key = cast8 2)
    val _ = assertloc (value = 36)
    val+ ~ key :: tail = keys
    val+ ~ NIL = tail
    val _ = assertloc (key = cast8 2)
    val+ ~ value :: tail = values
    val+ ~ NIL = tail
    val _ = assertloc (value = 36)

    val _ = free map
  }

fn
test2 () : void =
  {
    (* Making map a "var" has the disadvantage references to it
       must be passed around. I cannot recommend making a general
       practice of this "imperative" style. *)
    var map = hashmap ()

    val- 0 = sz2i (size map)
    val- true = iseqz map
    val- false = isneqz map

    val _ = map[cast8 2] := 36
    val- 1 = sz2i (size map)
    val- false = iseqz map
    val- true = isneqz map

    val- ~Some_vt 36 = map[cast8 2]
    val- ~Some_vt value = map[cast8 2]
    val- 36 = value
    val- ~None_vt () = map[cast8 3]

    val _ = free map
  }

fn
test_node_expansion_1 () : void =
  {
    val map = hashmap ()

    val map = my_map_set (map, cast8 0x01, 10)
    val map = my_map_set (map, cast8 0x05, 50)
    val map = my_map_set (map, cast8 0x15, 210)
    val map = my_map_set (map, cast8 0x00, 1)
    val map = my_map_set (map, cast8 0x0F, 150)

    val- 5 = sz2i (size map)
    val- false = iseqz map
    val- true = isneqz map

    fun
    loop {size : int}
         {i    : int | 0 <= i; i <= 256} .<256 - i>.
         (map  : !my_map_vt size >> _,
          i    : uint i) : void =
      if i <> 256U then
        let
          val n_opt = my_map_get_opt (map, cast8 i)
        in
          case+ n_opt of
          | ~ Some_vt (n) =>
            begin
              case+ i of
              | 0x01U => assertloc (n = 10)
              | 0x05U => assertloc (n = 50)
              | 0x15U => assertloc (n = 210)
              | 0x00U => assertloc (n = 1)
              | 0x0FU => assertloc (n = 150)
              | _ => assertloc (false)
            end
          | ~ None_vt () =>
            begin
              assertloc (i <> 0x01U);
              assertloc (i <> 0x05U);
              assertloc (i <> 0x15U);
              assertloc (i <> 0x00U);
              assertloc (i <> 0x0FU)
            end;
          loop (map, succ i)
        end
    val _ = loop {5} (map, 0U)

    val pairs = list_vt_mergesort<@(uint8, int)> (my_map_pairs map)
    val _ = assertloc (length pairs = 5)
    val- 0x00U = $UNSAFE.cast{uint} ((list_vt_get_at (pairs, 0)).0)
    val- 0x01U = $UNSAFE.cast{uint} ((list_vt_get_at (pairs, 1)).0)
    val- 0x05U = $UNSAFE.cast{uint} ((list_vt_get_at (pairs, 2)).0)
    val- 0x0FU = $UNSAFE.cast{uint} ((list_vt_get_at (pairs, 3)).0)
    val- 0x15U = $UNSAFE.cast{uint} ((list_vt_get_at (pairs, 4)).0)
    val- 1 = ((list_vt_get_at (pairs, 0)).1)
    val- 10 = ((list_vt_get_at (pairs, 1)).1)
    val- 50 = ((list_vt_get_at (pairs, 2)).1)
    val- 150 = ((list_vt_get_at (pairs, 3)).1)
    val- 210 = ((list_vt_get_at (pairs, 4)).1)
    val _ = free pairs

    val keys = list_vt_mergesort<uint8> (my_map_keys map)
    val _ = assertloc (length keys = 5)
    val- 0x00U = $UNSAFE.cast{uint} (list_vt_get_at (keys, 0))
    val- 0x01U = $UNSAFE.cast{uint} (list_vt_get_at (keys, 1))
    val- 0x05U = $UNSAFE.cast{uint} (list_vt_get_at (keys, 2))
    val- 0x0FU = $UNSAFE.cast{uint} (list_vt_get_at (keys, 3))
    val- 0x15U = $UNSAFE.cast{uint} (list_vt_get_at (keys, 4))
    val _ = free keys

    val values = list_vt_mergesort<int> (my_map_values map)
    val _ = assertloc (length values = 5)
    val- 1 = list_vt_get_at (values, 0)
    val- 10 = list_vt_get_at (values, 1)
    val- 50 = list_vt_get_at (values, 2)
    val- 150 = list_vt_get_at (values, 3)
    val- 210 = list_vt_get_at (values, 4)
    val _ = free values

    val _ = free map
  }

implement
main0 () =
  {
    val _ = test1 ()
    val _ = test2 ()
    val _ = test_node_expansion_1 ()
  }
