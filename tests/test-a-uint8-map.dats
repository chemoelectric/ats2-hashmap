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
staload _ = "hashmap/DATS/population_map.dats"
staload _ = "popcount/DATS/popcount.dats"

#define NIL list_vt_nil ()
#define :: list_vt_cons

macdef cast8 = $UNSAFE.cast{uint8}

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
  my_map_var_include
          {size  : int}
          (map   : &my_map_vt size >> my_map_vt new_size,
           key   : key_t,
           value : value_t) :
      #[new_size : int | new_size == size || new_size == size + 1]
      void =
    map := my_map_set {size} (map, key, value)

  (* map[key] := value *)
  overload [] with my_map_var_include

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
    loop {i   : int | 0 <= i; i <= 256} .<256 - i>.
         (map : !my_map_vt 1 >> _,
          i   : uint i) : void =
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
    val _ = loop (map, 0U)

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

implement
main0 () =
  {
    val _ = test1 ()
    val _ = test2 ()
  }
