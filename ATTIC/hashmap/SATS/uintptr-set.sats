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

(********************************************************************)

absvtype uintptr_set_vt (size : int)
vtypedef uintptr_set_vt = [size : int] uintptr_set_vt size

praxi
lemma_uintptr_set_vt_param :
  {size : int}
  (uintptr_set_vt size) -<prf> [0 <= size] void

(********************************************************************)

fun {}
uintptr_set () :
    uintptr_set_vt 0

fun
uintptr_set_free
        {size : int}
        (set  : uintptr_set_vt size) :
    void
overload free with uintptr_set_free

fun {}
uintptr_set_size
        {size : int}
        (set  : !(uintptr_set_vt size) >> _) :
    size_t size
overload size with uintptr_set_size

fun {}
uintptr_set_is_empty {size : int}
                     (set  : !(uintptr_set_vt size) >> _) :
    bool (size == 0)
overload iseqz with uintptr_set_is_empty

fun {}
uintptr_set_isnot_empty
        {size : int}
        (set  : !(uintptr_set_vt size) >> _) :
    bool (size <> 0)
overload isneqz with uintptr_set_isnot_empty

fun
uintptr_set_add_element
        {size    : int}
        (set     : uintptr_set_vt size,
         element : uintptr) :
    [new_size : int | new_size == size || new_size == size + 1]
    uintptr_set_vt (new_size)
overload add_element with uintptr_set_add_element
overload + with uintptr_set_add_element

fun
uintptr_set_remove_element
        {size    : int}
        (set     : uintptr_set_vt size,
         element : uintptr) :
    [new_size : int | new_size == size || new_size == size - 1]
    uintptr_set_vt (new_size)
overload remove_element with uintptr_set_remove_element
overload - with uintptr_set_remove_element

fun
uintptr_set_has_element
        {size    : int}
        (set     : !(uintptr_set_vt size) >> _,
         element : uintptr) :
    bool
overload has_element with uintptr_set_has_element
overload contains with uintptr_set_has_element

fun
uintptr_set_elements
        {size : int}
        (set  : !(uintptr_set_vt size) >> _) :
    list_vt (uintptr, size)

(********************************************************************)

(* Something useful for testing and debugging. *)
fun
uintptr_set_print_structure
        (out             : FILEref,
         set             : !uintptr_set_vt >> _,
         print_key_value : !((FILEref, uintptr) -<cloptr1> void)) :
    void

(********************************************************************)
