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

#include "hashmap/HATS/hashmap.hats"

#define NIL list_vt_nil ()
#define :: list_vt_cons

macdef cast64 = $UNSAFE.cast{uint64}

implement
gcompare_val_val<uint64> (x, y) =
  compare (x, y)

implement
list_vt_mergesort$cmp<@(uint64, int)> (x, y) =
  compare (x.0, y.0)

local

  typedef hash_t = uint64
  typedef key_t = uint64
  typedef value_t = int

  implement
  hashmap$hash_function<hash_t><key_t> (key, hash) =
    (* Keep only 32 bits of the key. *)
    hash := key land (cast64 0xFFFFU)

  implement
  hashmap$hash_vt_free<hash_t> (hash) =
    ()

  implement
  hashmap$bits_source<hash_t> (hash, depth) =
    bits_source_uint64 (hash, depth)

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
  my_map_del
        {size : int}
        (map  : my_map_vt size,
         key  : !RD(key_t) >> _) :
      [new_size : int | new_size == size || new_size == size - 1]
      my_map_vt new_size =
    hashmap_del<hash_t><key_t, value_t> {size} (map, key)

  fn
  my_map_get_opt
          {size : int}
          (map  : !my_map_vt size >> _,
           key  : !key_t >> _) :
      Option_vt (value_t) =
    hashmap_get_opt<hash_t><key_t, value_t> {size} (map, key)

  fn
  my_map_has_key
          {size : int}
          (map  : !my_map_vt size >> _,
           key  : !key_t >> _) :
      bool =
    hashmap_has_key<hash_t><key_t, value_t> {size} (map, key)

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

  fn
  my_map_fprint
        {size : int}
        (f    : FILEref,
         map  : !my_map_vt size >> _) : void =
    {
      val key_fprint =
        lam (f   : FILEref,
             key : !key_t >> _) : void =<cloptr1>
          fprint! (f, key)
      val value_fprint =
        lam (f     : FILEref,
             value : !value_t >> _) : void =<cloptr1>
          fprint! (f, value)

      val _ = hashmap_fprint<key_t, value_t> (f, map, key_fprint,
                                              value_fprint)

      val _ = cloptr_free ($UNSAFE.castvwtp0{cloptr0} key_fprint)
      val _ = cloptr_free ($UNSAFE.castvwtp0{cloptr0} value_fprint)
    }

  (* - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)

end

fn
compare_structure (map                : !my_map_vt >> _,
                   filename           : String0,
                   reference_filename : String0) : bool =
  let
    val f = fileref_open_exn (filename, file_mode_w)
    val _ = my_map_fprint (f, map)
    val _ = fileref_close (f)

    val space = string1_copy (" ")
    val fname = string1_copy (filename)
    val reffname = string1_copy (reference_filename)
    val cmp = string1_copy ("cmp -s ")
    val command1 = strnptr_append (space, fname)
    val command2 = strnptr_append (reffname, command1)
    val _ = free (command1)
    val command = strnptr_append (cmp, command2)
    val _ = free (command2)
    val status =
      $extfcall (int, "system", $UNSAFE.castvwtp1{string} command)
    val _ = free (command)
    val _ = free (space)
    val _ = free (fname)
    val _ = free (reffname)
    val _ = free (cmp)
  in
    status = 0
  end

fn
test_delete_1 () : void =
  {
    val map = hashmap ()

    val map = my_map_set (map, cast64 0x0FFF, 0)
    val map = my_map_set (map, cast64 0x1FFF, 1)
    val map = my_map_set (map, cast64 0x2FFF, 2)
    val map = my_map_set (map, cast64 0x3FFF, 3)
    val map = my_map_set (map, cast64 0x4FFF, 4)
    val map = my_map_set (map, cast64 0x5FFF, 5)

    val _ =
      assertloc
        (compare_structure
          (map, "tests/2021.11.04.15.37.36.structure",
           "tests/2021.11.04.15.37.36.structure.reference"))

    val map = my_map_del (map, cast64 0x0FFF)
    val map = my_map_del (map, cast64 0x1FFF)
    val map = my_map_del (map, cast64 0x2FFF)
    val map = my_map_del (map, cast64 0x3FFF)

    val _ =
      assertloc
        (compare_structure
          (map, "tests/2021.11.04.15.45.14.structure",
           "tests/2021.11.04.15.45.14.structure.reference"))

    val map = my_map_del (map, cast64 0x4FFF)

    val _ =
      assertloc
        (compare_structure
          (map, "tests/2021.11.04.15.42.11.structure",
           "tests/2021.11.04.15.42.11.structure.reference"))

    val _ = free map
  }

fn
test_delete_2 () : void =
  {
    val map = hashmap ()

    val map = my_map_set (map, cast64 0x0FFFFFFFULL, 0)
    val map = my_map_set (map, cast64 0x1FFFFFFFULL, 1)
    val map = my_map_set (map, cast64 0x2FFFFFFFULL, 2)
    val map = my_map_set (map, cast64 0x3FFFFFFFULL, 3)
    val map = my_map_set (map, cast64 0x4FFFFFFFULL, 4)
    val map = my_map_set (map, cast64 0x5FFFFFFFULL, 5)

    val _ =
      assertloc
        (compare_structure
          (map, "tests/2021.11.04.15.47.40.structure",
           "tests/2021.11.04.15.47.40.structure.reference"))

    val map = my_map_del (map, cast64 0x0FFFFFFFULL)
    val map = my_map_del (map, cast64 0x1FFFFFFFULL)
    val map = my_map_del (map, cast64 0x2FFFFFFFULL)
    val map = my_map_del (map, cast64 0x3FFFFFFFULL)

    val _ =
      assertloc
        (compare_structure
          (map, "tests/2021.11.04.15.49.22.structure",
           "tests/2021.11.04.15.49.22.structure.reference"))

    val map = my_map_del (map, cast64 0x4FFFFFFFULL)

    val _ =
      assertloc
        (compare_structure
          (map, "tests/2021.11.04.15.51.36.structure",
           "tests/2021.11.04.15.51.36.structure.reference"))

    val _ = free map
  }

implement
main0 () =
  {
    val _ = test_delete_1 ()
    val _ = test_delete_2 ()
  }
