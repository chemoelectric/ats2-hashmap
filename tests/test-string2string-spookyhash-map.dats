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

#include "hashmap/HATS/hashmap.hats"
staload "hashmap/SATS/stringmap-spookyhash.sats"
staload _ = "hashmap/DATS/stringmap-spookyhash.dats"

#define NIL list_vt_nil ()
#define :: list_vt_cons

local

  implement
  hashmap$value_vt_free<Strnptr1> (value) =
    free value

  implement
  hashmap$value_vt_copy<Strnptr1> (value) =
    string1_copy ($UN.strnptr2string value)

in

  fn
  s2s_map_set_string_string
          {size  : int}
          (map   : stringmap_vt (Strnptr1, size),
           key   : string,
           value : string) :
      [new_size : int | new_size == size || new_size == size + 1]
      stringmap_vt (Strnptr1, new_size) =
    let
      val value = g1ofg0 value
      prval _ = lemma_string_param value
    in
      stringmap_set<Strnptr1> (map, key, string1_copy value)
    end
  fn
  s2s_map_set_strptr_strptr
          {size  : int}
          (map   : stringmap_vt (Strnptr1, size),
           key   : Strptr1,
           value : Strptr1) :
      [new_size : int | new_size == size || new_size == size + 1]
      stringmap_vt (Strnptr1, new_size) =
    let
      val value = strptr2strnptr value
      prval _ = lemma_strnptr_param value
    in
      stringmap_set<Strnptr1> (map, key, value)
    end
  fn
  s2s_map_set_strnptr_strnptr
          {size  : int}
          (map   : stringmap_vt (Strnptr1, size),
           key   : Strnptr1,
           value : Strnptr1) :
      [new_size : int | new_size == size || new_size == size + 1]
      stringmap_vt (Strnptr1, new_size) =
    stringmap_set<Strnptr1> (map, key, value)
  overload s2s_map_set with s2s_map_set_string_string of 50
  overload s2s_map_set with s2s_map_set_strptr_strptr of 60
  overload s2s_map_set with s2s_map_set_strnptr_strnptr of 70

  fn
  s2s_map_keys
          {size : int}
          (map  : !stringmap_vt (Strnptr1, size) >> _) :
      list_vt (Strnptr1, size) =
    stringmap_keys<Strnptr1> {size} map

  fn
  s2s_map_values
          {size : int}
          (map  : !stringmap_vt (Strnptr1, size) >> _) :
      list_vt (Strnptr1, size) =
    stringmap_values<Strnptr1> {size} map

  fn
  s2s_map_free
          {size : int}
          (map  : stringmap_vt (Strnptr1, size)) :
      void =
    stringmap_free<Strnptr1> map
  overload free with s2s_map_free of 20

end

implement
list_vt_freelin$clear<Strnptr1> (x) =
  free x

fn
fprint_strnptr_list_vt
        {n   : int}
        (f   : FILEref,
         lst : !list_vt (Strnptr1, n) >> _) :
    void =
  let
    fun
    loop {m         : int | 0 <= m} .<m>.
         (lst       : !list_vt (Strnptr1, m) >> _,
          separator : string) :
        void =
      case+ lst of
      | NIL => ()
      | @ head :: tail =>
        {
          val _ = fprint! (f, separator)
          val _ = fprint! (f, head)
          val _ = loop (tail, " ")
          prval _ = fold@ lst
        }
    prval _ = lemma_list_vt_param lst
  in
    fprint! (f, "(");
    loop (lst, "");
    fprint! (f, ")")
  end

implement
main0 () =
  {
    val foo2 = string0_copy "foo1"
    val bar2 = string0_copy "bar1"
    val foo3 = string1_copy "foo1"
    val bar3 = string1_copy "bar1"

    val map = stringmap ()
    val map = s2s_map_set (map, "foo1", "bar1")
    val map = s2s_map_set (map, "foo2", "bar2")
    val map = s2s_map_set (map, "foo3", "bar3")

    val keys = s2s_map_keys (map)
    val _ = fprint_strnptr_list_vt (stdout_ref, keys)
    val _ = fprintln! (stdout_ref)
    val _ = list_vt_freelin keys

    val values = s2s_map_values (map)
    val _ = fprint_strnptr_list_vt (stdout_ref, values)
    val _ = fprintln! (stdout_ref)
    val _ = list_vt_freelin values

    val _ = free map
    val _ = free foo2
    val _ = free bar2
    val _ = free foo3
    val _ = free bar3
  }
