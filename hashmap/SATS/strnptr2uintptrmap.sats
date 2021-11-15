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
(* Maps from strings to uintptr                                     *)
(*                                                                  *)
(* These are useful for making string maps in C, because uintptr    *)
(* can represent all C pointers and most integer values.            *)
(*                                                                  *)
(* They also are a reasonable representation for string sets,       *)
(* although the unused uintptr field takes up space.                *)
(*                                                                  *)
(********************************************************************)

#define ATS_PACKNAME "ats2-hashmap"
#define ATS_EXTERN_PREFIX "ats2_hashmap_"

staload "hashmap/SATS/strnptrmap.sats"

(********************************************************************)

vtypedef strnptr2uintptrmap_vt (size : int) =
  strnptrmap_vt (uintptr, size)
vtypedef strnptr2uintptrmap_vt =
  [size : int]
  strnptr2uintptrmap_vt (size)

prfun
lemma_strnptr2uintptrmap_vt_param :
  {size : int}
  (!strnptr2uintptrmap_vt (size) >> _) -<prf>
    [0 <= size] void

(********************************************************************)

fun {}
strnptr2uintptrmap () :
  strnptr2uintptrmap_vt (0)

fun
strnptr2uintptrmap_size
        {size : int}
        (map  : !strnptr2uintptrmap_vt (size) >> _) :
    size_t size

fun {}
strnptr2uintptrmap_is_empty
        {size : int}
        (map  : !strnptr2uintptrmap_vt (size) >> _) :
    bool (size == 0)

fun {}
strnptr2uintptrmap_isnot_empty
        {size : int}
        (map  : !strnptr2uintptrmap_vt (size) >> _) :
    bool (size != 0)

(* The "value_free" argument may be a NULL pointer.
   The "ptr" argument to value_free is for passing a
   closure environment in C. *)
fun
strnptr2uintptrmap_set_string
        {size        : int}
        (map         : strnptr2uintptrmap_vt (size),
         key         : string,
         value       : uintptr,
         value_free  : (uintptr, ptr) -> void,
         environment : ptr) :
    [new_size : int | new_size == size || new_size == size + 1]
    strnptr2uintptrmap_vt (new_size)
fun
strnptr2uintptrmap_set_strptr
        {size        : int}
        (map         : strnptr2uintptrmap_vt (size),
         key         : Strptr1,
         value       : uintptr,
         value_free  : (uintptr, ptr) -> void,
         environment : ptr) :
    [new_size : int | new_size == size || new_size == size + 1]
    strnptr2uintptrmap_vt (new_size)
fun
strnptr2uintptrmap_set_strnptr
        {size        : int}
        (map         : strnptr2uintptrmap_vt (size),
         key         : Strnptr1,
         value       : uintptr,
         value_free  : (uintptr, ptr) -> void,
         environment : ptr) :
    [new_size : int | new_size == size || new_size == size + 1]
    strnptr2uintptrmap_vt (new_size)
overload strnptr2uintptrmap_set with
  strnptr2uintptrmap_set_string of 0
overload strnptr2uintptrmap_set with
  strnptr2uintptrmap_set_strptr of 10
overload strnptr2uintptrmap_set with
  strnptr2uintptrmap_set_strnptr of 20

fun
strnptr2uintptrmap_del_string
        {size        : int}
        (map         : strnptr2uintptrmap_vt (size),
         key         : string,
         value_free  : (uintptr, ptr) -> void,
         environment : ptr) :
    [new_size : int | new_size == size || new_size == size - 1]
    strnptr2uintptrmap_vt (new_size)
fun
strnptr2uintptrmap_del_strptr
        {size        : int}
        (map         : strnptr2uintptrmap_vt (size),
         key         : !RD(Strptr1) >> _,
         value_free  : (uintptr, ptr) -> void,
         environment : ptr) :
    [new_size : int | new_size == size || new_size == size - 1]
    strnptr2uintptrmap_vt (new_size)
fun
strnptr2uintptrmap_del_strnptr
        {size        : int}
        (map         : strnptr2uintptrmap_vt (size),
         key         : !RD(Strnptr1) >> _,
         value_free  : (uintptr, ptr) -> void,
         environment : ptr) :
    [new_size : int | new_size == size || new_size == size - 1]
    strnptr2uintptrmap_vt (new_size)
overload strnptr2uintptrmap_del with
  strnptr2uintptrmap_del_string of 0
overload strnptr2uintptrmap_del with
  strnptr2uintptrmap_del_strptr of 10
overload strnptr2uintptrmap_del with
  strnptr2uintptrmap_del_strnptr of 20

fun
strnptr2uintptrmap_get_opt_string
        {size        : int}
        (map         : !RD(strnptr2uintptrmap_vt (size)) >> _,
         key         : string,
         value_copy  : (uintptr, ptr) -> uintptr,
         environment : ptr) :
    Option_vt (uintptr)
fun
strnptr2uintptrmap_get_opt_strptr
        {size        : int}
        (map         : !RD(strnptr2uintptrmap_vt (size)) >> _,
         key         : !RD(Strptr1) >> _,
         value_copy  : (uintptr, ptr) -> uintptr,
         environment : ptr) :
    Option_vt (uintptr)
fun
strnptr2uintptrmap_get_opt_strnptr
        {size        : int}
        (map         : !RD(strnptr2uintptrmap_vt (size)) >> _,
         key         : !RD(Strnptr1) >> _,
         value_copy  : (uintptr, ptr) -> uintptr,
         environment : ptr) :
    Option_vt (uintptr)
overload strnptr2uintptrmap_get_opt with
  strnptr2uintptrmap_get_opt_string of 0
overload strnptr2uintptrmap_get_opt with
  strnptr2uintptrmap_get_opt_strptr of 10
overload strnptr2uintptrmap_get_opt with
  strnptr2uintptrmap_get_opt_strnptr of 20

fun
strnptr2uintptrmap_has_key_string
        {size : int}
        (map  : !RD(strnptr2uintptrmap_vt (size)) >> _,
         key  : string) :
    bool
fun
strnptr2uintptrmap_has_key_strptr
        {size : int}
        (map  : !RD(strnptr2uintptrmap_vt (size)) >> _,
         key  : !RD(Strptr1) >> _) :
    bool
fun
strnptr2uintptrmap_has_key_strnptr
        {size : int}
        (map  : !RD(strnptr2uintptrmap_vt (size)) >> _,
         key  : !RD(Strnptr1) >> _) :
    bool
overload strnptr2uintptrmap_has_key with
  strnptr2uintptrmap_has_key_string of 0
overload strnptr2uintptrmap_has_key with
  strnptr2uintptrmap_has_key_strptr of 10
overload strnptr2uintptrmap_has_key with
  strnptr2uintptrmap_has_key_strnptr of 20

fun
strnptr2uintptrmap_pairs
        {size        : int}
        (map         : !RD(strnptr2uintptrmap_vt (size)) >> _,
         value_copy  : (uintptr, ptr) -> uintptr,
         environment : ptr) :
    list_vt (@(Strnptr1, uintptr), size)

fun
strnptr2uintptrmap_pairs_free
        {size        : int}
        (pairs       : list_vt (@(Strnptr1, uintptr), size),
         value_free  : (uintptr, ptr) -> void,
         environment : ptr) :
    void

fun
strnptr2uintptrmap_keys
        {size : int}
        (map  : !RD(strnptr2uintptrmap_vt (size)) >> _) :
    list_vt (Strnptr1, size)

fun
strnptr2uintptrmap_keys_free
        {size : int}
        (keys : list_vt (Strnptr1, size)) :
    void

fun
strnptr2uintptrmap_values
        {size        : int}
        (map         : !RD(strnptr2uintptrmap_vt (size)) >> _,
         value_copy  : (uintptr, ptr) -> uintptr,
         environment : ptr) :
    list_vt (uintptr, size)

fun
strnptr2uintptrmap_values_free
        {size        : int}
        (values      : list_vt (uintptr, size),
         value_free  : (uintptr, ptr) -> void,
         environment : ptr) :
    void

fun
strnptr2uintptrmap_free
        {size : int}
        (map  : strnptr2uintptrmap_vt (size)) :
    void
overload free with strnptr2uintptrmap_free

(********************************************************************)
