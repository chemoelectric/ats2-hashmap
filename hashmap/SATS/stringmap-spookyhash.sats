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
(* String maps by means of hashmap and ats2-spookyhash              *)
(*                                                                  *)
(********************************************************************)

#define ATS_PACKNAME "ats2-hashmap"
#define ATS_EXTERN_PREFIX "ats2_hashmap_"

staload "hashmap/SATS/hashmap.sats"

(********************************************************************)

vtypedef stringmap_vt (value_vt : vt@ype+,
                       size     : int) =
  hashmap_vt (Strnptr1, value_vt, size)
vtypedef stringmap_vt (value_vt : vt@ype+) =
  [size : int]
  stringmap_vt (value_vt, size)

prfun
lemma_stringmap_vt_param :
  {value_vt : vt@ype}
  {size     : int}
  (!stringmap_vt (value_vt, size) >> _) -<prf>
    [0 <= size] void

(********************************************************************)

fun {}
stringmap {value_vt : vt@ype} () :
  stringmap_vt (value_vt, 0)

fun {}
stringmap_size
        {size     : int}
        {value_vt : vt@ype}
        (map      : !stringmap_vt (value_vt, size) >> _) :
    size_t size
overload size with stringmap_size of 10

fun {}
stringmap_is_empty
        {size     : int}
        {value_vt : vt@ype}
        (map      : !stringmap_vt (value_vt, size) >> _) :
    bool (size == 0)
overload iseqz with stringmap_is_empty of 10

fun {}
stringmap_isnot_empty
        {size     : int}
        {value_vt : vt@ype}
        (map      : !stringmap_vt (value_vt, size) >> _) :
    bool (size != 0)
overload isneqz with stringmap_isnot_empty of 10

fun {value_vt : vt@ype}
stringmap_set_string
        {size  : int}
        (map   : stringmap_vt (value_vt, size),
         key   : string,
         value : value_vt) :
    [new_size : int | new_size == size || new_size == size + 1]
    stringmap_vt (value_vt, new_size)
fun {value_vt : vt@ype}
stringmap_set_strptr
        {size  : int}
        (map   : stringmap_vt (value_vt, size),
         key   : Strptr1,
         value : value_vt) :
    [new_size : int | new_size == size || new_size == size + 1]
    stringmap_vt (value_vt, new_size)
fun {value_vt : vt@ype}
stringmap_set_strnptr
        {size  : int}
        (map   : stringmap_vt (value_vt, size),
         key   : Strnptr1,
         value : value_vt) :
    [new_size : int | new_size == size || new_size == size + 1]
    stringmap_vt (value_vt, new_size)
overload stringmap_set with stringmap_set_string of 0
overload stringmap_set with stringmap_set_strptr of 10
overload stringmap_set with stringmap_set_strnptr of 20

fun {value_vt : vt@ype}
stringmap_del_string
        {size : int}
        (map  : stringmap_vt (value_vt, size),
         key  : string) :
    [new_size : int | new_size == size || new_size == size - 1]
    stringmap_vt (value_vt, new_size)
fun {value_vt : vt@ype}
stringmap_del_strptr
        {size : int}
        (map  : stringmap_vt (value_vt, size),
         key  : !RD(Strptr1) >> _) :
    [new_size : int | new_size == size || new_size == size - 1]
    stringmap_vt (value_vt, new_size)
fun {value_vt : vt@ype}
stringmap_del_strnptr
        {size : int}
        (map  : stringmap_vt (value_vt, size),
         key  : !RD(Strnptr1) >> _) :
    [new_size : int | new_size == size || new_size == size - 1]
    stringmap_vt (value_vt, new_size)
overload stringmap_del with stringmap_del_string of 0
overload stringmap_del with stringmap_del_strptr of 10
overload stringmap_del with stringmap_del_strnptr of 20

fun {value_vt : vt@ype}
stringmap_get_opt_string
        {size : int}
        (map  : !RD(stringmap_vt (value_vt, size)) >> _,
         key  : string) :
    Option_vt (value_vt)
fun {value_vt : vt@ype}
stringmap_get_opt_strptr
        {size : int}
        (map  : !RD(stringmap_vt (value_vt, size)) >> _,
         key  : !RD(Strptr1) >> _) :
    Option_vt (value_vt)
fun {value_vt : vt@ype}
stringmap_get_opt_strnptr
        {size : int}
        (map  : !RD(stringmap_vt (value_vt, size)) >> _,
         key  : !RD(Strnptr1) >> _) :
    Option_vt (value_vt)
overload stringmap_get_opt with stringmap_get_opt_string of 0
overload stringmap_get_opt with stringmap_get_opt_strptr of 10
overload stringmap_get_opt with stringmap_get_opt_strnptr of 20

fun {value_vt : vt@ype}
stringmap_pairs
        {size : int}
        (map  : !RD(stringmap_vt (value_vt, size)) >> _) :
    list_vt (@(Strnptr1, value_vt), size)

fun {value_vt : vt@ype}
stringmap_keys
        {size : int}
        (map  : !RD(stringmap_vt (value_vt, size)) >> _) :
    list_vt (Strnptr1, size)

fun {value_vt : vt@ype}
stringmap_values
        {size : int}
        (map  : !RD(stringmap_vt (value_vt, size)) >> _) :
    list_vt (value_vt, size)

fun {value_vt : vt@ype}
stringmap_free
        {size : int}
        (map  : stringmap_vt (value_vt, size)) :
    void

(********************************************************************)
