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
(* Maps from strings to strings                                     *)
(*                                                                  *)
(********************************************************************)

#define ATS_PACKNAME "ats2-hashmap"
#define ATS_EXTERN_PREFIX "ats2_hashmap_"

staload "hashmap/SATS/strnptrmap.sats"

(********************************************************************)

vtypedef strnptr2strnptrmap_vt (size : int) =
  strnptrmap_vt (Strnptr1, size)
vtypedef strnptr2strnptrmap_vt =
  [size : int]
  strnptr2strnptrmap_vt (size)

prfun
lemma_strnptr2strnptrmap_vt_param :
  {size : int}
  (!strnptr2strnptrmap_vt (size) >> _) -<prf>
    [0 <= size] void

(********************************************************************)

fun {}
strnptr2strnptrmap () :
  strnptr2strnptrmap_vt (0)

fun
strnptr2strnptrmap_size
        {size : int}
        (map  : !strnptr2strnptrmap_vt (size) >> _) :
    size_t size

fun {}
strnptr2strnptrmap_is_empty
        {size : int}
        (map  : !strnptr2strnptrmap_vt (size) >> _) :
    bool (size == 0)

fun {}
strnptr2strnptrmap_isnot_empty
        {size : int}
        (map  : !strnptr2strnptrmap_vt (size) >> _) :
    bool (size != 0)

fun
strnptr2strnptrmap_set_string_string
        {size        : int}
        (map         : strnptr2strnptrmap_vt (size),
         key         : string,
         value       : string) :
    [new_size : int | new_size == size || new_size == size + 1]
    strnptr2strnptrmap_vt (new_size)
fun
strnptr2strnptrmap_set_string_strptr
        {size        : int}
        (map         : strnptr2strnptrmap_vt (size),
         key         : string,
         value       : Strptr1) :
    [new_size : int | new_size == size || new_size == size + 1]
    strnptr2strnptrmap_vt (new_size)
fun
strnptr2strnptrmap_set_string_strnptr
        {size        : int}
        (map         : strnptr2strnptrmap_vt (size),
         key         : string,
         value       : Strnptr1) :
    [new_size : int | new_size == size || new_size == size + 1]
    strnptr2strnptrmap_vt (new_size)
fun
strnptr2strnptrmap_set_strptr_string
        {size        : int}
        (map         : strnptr2strnptrmap_vt (size),
         key         : Strptr1,
         value       : string) :
    [new_size : int | new_size == size || new_size == size + 1]
    strnptr2strnptrmap_vt (new_size)
fun
strnptr2strnptrmap_set_strptr_strptr
        {size        : int}
        (map         : strnptr2strnptrmap_vt (size),
         key         : Strptr1,
         value       : Strptr1) :
    [new_size : int | new_size == size || new_size == size + 1]
    strnptr2strnptrmap_vt (new_size)
fun
strnptr2strnptrmap_set_strptr_strnptr
        {size  : int}
        (map   : strnptr2strnptrmap_vt (size),
         key   : Strptr1,
         value : Strnptr1) :
    [new_size : int | new_size == size || new_size == size + 1]
    strnptr2strnptrmap_vt (new_size)
fun
strnptr2strnptrmap_set_strnptr_string
        {size  : int}
        (map   : strnptr2strnptrmap_vt (size),
         key   : Strnptr1,
         value : string) :
    [new_size : int | new_size == size || new_size == size + 1]
    strnptr2strnptrmap_vt (new_size)
fun
strnptr2strnptrmap_set_strnptr_strptr
        {size  : int}
        (map   : strnptr2strnptrmap_vt (size),
         key   : Strnptr1,
         value : Strptr1) :
    [new_size : int | new_size == size || new_size == size + 1]
    strnptr2strnptrmap_vt (new_size)
fun
strnptr2strnptrmap_set_strnptr_strnptr
        {size  : int}
        (map   : strnptr2strnptrmap_vt (size),
         key   : Strnptr1,
         value : Strnptr1) :
    [new_size : int | new_size == size || new_size == size + 1]
    strnptr2strnptrmap_vt (new_size)

overload strnptr2strnptrmap_set with
  strnptr2strnptrmap_set_string_string of 0
overload strnptr2strnptrmap_set with
  strnptr2strnptrmap_set_string_strptr of 10
overload strnptr2strnptrmap_set with
  strnptr2strnptrmap_set_string_strnptr of 20

overload strnptr2strnptrmap_set with
  strnptr2strnptrmap_set_strptr_string of 30
overload strnptr2strnptrmap_set with
  strnptr2strnptrmap_set_strptr_strptr of 40
overload strnptr2strnptrmap_set with
  strnptr2strnptrmap_set_strptr_strnptr of 50

overload strnptr2strnptrmap_set with
  strnptr2strnptrmap_set_strnptr_string of 60
overload strnptr2strnptrmap_set with
  strnptr2strnptrmap_set_strnptr_strptr of 70
overload strnptr2strnptrmap_set with
  strnptr2strnptrmap_set_strnptr_strnptr of 80

fun
strnptr2strnptrmap_del_string
        {size : int}
        (map  : strnptr2strnptrmap_vt (size),
         key  : string) :
    [new_size : int | new_size == size || new_size == size - 1]
    strnptr2strnptrmap_vt (new_size)
fun
strnptr2strnptrmap_del_strptr
        {size : int}
        (map  : strnptr2strnptrmap_vt (size),
         key  : !RD(Strptr1) >> _) :
    [new_size : int | new_size == size || new_size == size - 1]
    strnptr2strnptrmap_vt (new_size)
fun
strnptr2strnptrmap_del_strnptr
        {size : int}
        (map  : strnptr2strnptrmap_vt (size),
         key  : !RD(Strnptr1) >> _) :
    [new_size : int | new_size == size || new_size == size - 1]
    strnptr2strnptrmap_vt (new_size)
overload strnptr2strnptrmap_del with
  strnptr2strnptrmap_del_string of 0
overload strnptr2strnptrmap_del with
  strnptr2strnptrmap_del_strptr of 10
overload strnptr2strnptrmap_del with
  strnptr2strnptrmap_del_strnptr of 20

fun
strnptr2strnptrmap_get_opt_string
        {size : int}
        (map  : !RD(strnptr2strnptrmap_vt (size)) >> _,
         key  : string) :
    Option_vt (Strnptr1)
fun
strnptr2strnptrmap_get_opt_strptr
        {size : int}
        (map  : !RD(strnptr2strnptrmap_vt (size)) >> _,
         key  : !RD(Strptr1) >> _) :
    Option_vt (Strnptr1)
fun
strnptr2strnptrmap_get_opt_strnptr
        {size : int}
        (map  : !RD(strnptr2strnptrmap_vt (size)) >> _,
         key  : !RD(Strnptr1) >> _) :
    Option_vt (Strnptr1)
overload strnptr2strnptrmap_get_opt with
  strnptr2strnptrmap_get_opt_string of 0
overload strnptr2strnptrmap_get_opt with
  strnptr2strnptrmap_get_opt_strptr of 10
overload strnptr2strnptrmap_get_opt with
  strnptr2strnptrmap_get_opt_strnptr of 20

fun
strnptr2strnptrmap_has_key_string
        {size : int}
        (map  : !RD(strnptr2strnptrmap_vt (size)) >> _,
         key  : string) :
    bool
fun
strnptr2strnptrmap_has_key_strptr
        {size : int}
        (map  : !RD(strnptr2strnptrmap_vt (size)) >> _,
         key  : !RD(Strptr1) >> _) :
    bool
fun
strnptr2strnptrmap_has_key_strnptr
        {size : int}
        (map  : !RD(strnptr2strnptrmap_vt (size)) >> _,
         key  : !RD(Strnptr1) >> _) :
    bool
overload strnptr2strnptrmap_has_key with
  strnptr2strnptrmap_has_key_string of 0
overload strnptr2strnptrmap_has_key with
  strnptr2strnptrmap_has_key_strptr of 10
overload strnptr2strnptrmap_has_key with
  strnptr2strnptrmap_has_key_strnptr of 20

fun
strnptr2strnptrmap_pairs
        {size : int}
        (map  : !RD(strnptr2strnptrmap_vt (size)) >> _) :
    list_vt (@(Strnptr1, Strnptr1), size)

fun
strnptr2strnptrmap_pairs_free
        {size : int}
        (pairs: list_vt (@(Strnptr1, Strnptr1), size)) :
    void

fun
strnptr2strnptrmap_keys
        {size : int}
        (map  : !RD(strnptr2strnptrmap_vt (size)) >> _) :
    list_vt (Strnptr1, size)

fun
strnptr2strnptrmap_keys_free
        {size : int}
        (keys : list_vt (Strnptr1, size)) :
    void

fun
strnptr2strnptrmap_values
        {size : int}
        (map  : !RD(strnptr2strnptrmap_vt (size)) >> _) :
    list_vt (Strnptr1, size)

fun
strnptr2strnptrmap_values_free
        {size   : int}
        (values : list_vt (Strnptr1, size)) :
    void

fun
strnptr2strnptrmap_free
        {size : int}
        (map  : strnptr2strnptrmap_vt (size)) :
    void

(********************************************************************)
