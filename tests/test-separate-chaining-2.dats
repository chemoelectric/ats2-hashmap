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
    (* Keep only four bits of the key. *)
    hash := key land (cast8 0x0FU)

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
test_fill_1 () : void =
  {
    fun
    fill {i    : int | 0 <= i; i <= 256} .<256 - i>.
         (map  : my_map_vt,
          i    : int i) :
        my_map_vt =
      if i = 256 then
        map
      else
        fill (my_map_set (map, cast8 i, succ i), succ i)

    val map = fill (hashmap (), 0)

    val- 256 = sz2i (size map)
    val- false = iseqz map
    val- true = isneqz map

    fun
    loop {i    : int | 0 <= i; i <= 256} .<256 - i>.
         (map  : !my_map_vt >> _,
          i    : uint i) : void =
      if i <> 256U then
        let
          val n_opt = my_map_get_opt (map, cast8 i)
        in
          case+ n_opt of
          | ~ Some_vt (n) => assertloc (u2i i = pred n)
          | ~ None_vt () => assertloc (false);
          loop (map, succ i)
        end
    val _ = loop (map, 0U)

    val pairs = list_vt_mergesort<@(uint8, int)> (my_map_pairs map)
    val _ = assertloc (length pairs = 256)
    val _ =
      let
        var i : [i : int | 0 <= i; i <= 256] int i
      in
        for (i := 0; i < 256; i := succ i)
          begin
            assertloc ($UNSAFE.cast{int} ((list_vt_get_at (pairs, i)).0) = i);
            assertloc (((list_vt_get_at (pairs, i)).1) = succ i)
          end
      end
    val _ = free pairs

    val keys = list_vt_mergesort<uint8> (my_map_keys map)
    val _ = assertloc (length keys = 256)
    val _ =
      let
        var i : [i : int | 0 <= i; i <= 256] int i
      in
        for (i := 0; i < 256; i := succ i)
          assertloc ($UNSAFE.cast{int} (list_vt_get_at (keys, i)) = i)
      end
    val _ = free keys

    val values = list_vt_mergesort<int> (my_map_values map)
    val _ = assertloc (length values = 256)
    val _ =
      let
        var i : [i : int | 0 <= i; i <= 256] int i
      in
        for (i := 0; i < 256; i := succ i)
          assertloc (list_vt_get_at (values, i) = succ i)
      end
    val _ = free values

    val _ =
      assertloc
        (compare_structure
          (map, "tests/2021.10.29.14.01.48.structure",
           "tests/2021.10.29.14.01.48.structure.reference"))

    val _ = free map
  }

fn
test_replace_1 () : void =
  {
    fun
    fill {i    : int | 0 <= i; i <= 256} .<256 - i>.
         (map  : my_map_vt,
          i    : int i) :
        my_map_vt =
      if i = 256 then
        map
      else
        fill (my_map_set (map, cast8 i, succ i), succ i)

    fun
    replace {i    : int | 0 <= i; i <= 256} .<256 - i>.
            (map  : my_map_vt,
             i    : int i) :
        my_map_vt =
      if i = 256 then
        map
      else
        let
          val- ~ Some_vt value = my_map_get_opt (map, cast8 i)
        in
          replace (my_map_set (map, cast8 i, neg value), succ i)
        end

    val map = fill (hashmap (), 0)
    val map = replace (map, 0)

    val- 256 = sz2i (size map)
    val- false = iseqz map
    val- true = isneqz map

    fun
    loop {i    : int | 0 <= i; i <= 256} .<256 - i>.
         (map  : !my_map_vt >> _,
          i    : uint i) : void =
      if i <> 256U then
        let
          val n_opt = my_map_get_opt (map, cast8 i)
        in
          case+ n_opt of
          | ~ Some_vt (n) => assertloc (u2i i = pred (neg n))
          | ~ None_vt () => assertloc (false);
          loop (map, succ i)
        end
    val _ = loop (map, 0U)

    val pairs = list_vt_mergesort<@(uint8, int)> (my_map_pairs map)
    val _ = assertloc (length pairs = 256)
    val _ =
      let
        var i : [i : int | 0 <= i; i <= 256] int i
      in
        for (i := 0; i < 256; i := succ i)
          begin
            assertloc ($UNSAFE.cast{int} ((list_vt_get_at (pairs, i)).0) = i);
            assertloc (((list_vt_get_at (pairs, i)).1) = neg (succ i))
          end
      end
    val _ = free pairs

    val keys = list_vt_mergesort<uint8> (my_map_keys map)
    val _ = assertloc (length keys = 256)
    val _ =
      let
        var i : [i : int | 0 <= i; i <= 256] int i
      in
        for (i := 0; i < 256; i := succ i)
          assertloc ($UNSAFE.cast{int} (list_vt_get_at (keys, i)) = i)
      end
    val _ = free keys

    val values = list_vt_mergesort<int> (my_map_values map)
    val _ = assertloc (length values = 256)
    val _ =
      let
        var i : [i : int | 0 <= i; i <= 256] int i
      in
        for (i := 0; i < 256; i := succ i)
          assertloc (list_vt_get_at (values, i) = neg (256 - i))
      end
    val _ = free values

    val _ =
      assertloc
        (compare_structure
          (map, "tests/2021.10.29.14.02.11.structure",
           "tests/2021.10.29.14.02.11.structure.reference"))

    val _ = free map
  }

implement
main0 () =
  {
    val _ = test_fill_1 ()
    val _ = test_replace_1 ()
  }
