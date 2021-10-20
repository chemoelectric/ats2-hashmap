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
  my_map_include
          {size  : int}
          (map   : my_map_vt size,
           key   : key_t,
           value : value_t) :
      [new_size : int | new_size == size || new_size == size + 1]
      my_map_vt new_size =
    hashmap_include<hash_t><key_t, value_t> {size} (map, key, value)

  fn
  my_map_find
          {size : int}
          (map  : !my_map_vt size >> _,
           key  : !key_t >> _) :
      Option_vt (value_t) =
    hashmap_find<hash_t><key_t, value_t> {size} (map, key)

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
    map := my_map_include {size} (map, key, value)

  (* map[key] := value *)
  overload [] with my_map_var_include

  (* val- Some_vt value = map[key1] *)
  (* val- None_vt () = map[key2]    *)
  (* Etc.                           *)
  overload [] with my_map_find

  (* - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)

end

fn
test1 () : void =
  {
    val map = hashmap ()
    val- 0 = sz2i (size map)
    val- true = iseqz map
    val- false = isneqz map

    val map = my_map_include (map, cast8 2, 36)
    val- 1 = sz2i (size map)
    val- false = iseqz map
    val- true = isneqz map

    val- ~Some_vt 36 = my_map_find (map, cast8 2)
    val- ~Some_vt value = my_map_find (map, cast8 2)
    val- 36 = value
    val- ~None_vt () = my_map_find (map, cast8 3)
    val _ =
      let
        var i : [i : int | 0 <= i; i <= 256] uint i
      in
        for (i := 0U; i <= 255U; i := succ i)
          if i = 2U then
            { val- ~Some_vt 36 = my_map_find (map, cast8 i) }
          else
            { val- ~None_vt () = my_map_find (map, cast8 i) }
      end

(* FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
    val _ = free map // FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME: ****** NOT YET IMPLEMENTED ******
*)  prval _ = $UNSAFE.castvwtp0{void} map // FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
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

(* FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
    val _ = free map // FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME: ****** NOT YET IMPLEMENTED ******
*)  prval _ = $UNSAFE.castvwtp0{void} map // FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
  }

implement
main0 () =
  {
    val _ = test1 ()
    val _ = test2 ()
  }
