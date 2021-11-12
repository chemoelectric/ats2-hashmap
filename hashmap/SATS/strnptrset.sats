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
(* Sets of strings                                                  *)
(*                                                                  *)
(********************************************************************)

#define ATS_PACKNAME "ats2-hashmap"
#define ATS_EXTERN_PREFIX "ats2_hashmap_"

(********************************************************************)

absvtype strnptrset_vt (size : int)
vtypedef strnptrset_vt =
  [size : int]
  strnptrset_vt (size)

prfun
lemma_strnptrset_vt_param :
  {size : int}
  (!strnptrset_vt (size) >> _) -<prf>
    [0 <= size] void

(********************************************************************)

fun {}
strnptrset () :
  strnptrset_vt (0)

fun {}
strnptrset_size
        {size : int}
        (set  : !strnptrset_vt (size) >> _) :
    size_t size
overload size with strnptrset_size

fun {}
strnptrset_is_empty
        {size : int}
        (set  : !strnptrset_vt (size) >> _) :
    bool (size == 0)
overload iseqz with strnptrset_is_empty

fun {}
strnptrset_isnot_empty
        {size : int}
        (set  : !strnptrset_vt (size) >> _) :
    bool (size != 0)
overload isneqz with strnptrset_isnot_empty

fun {}
strnptrset_add_string
        {size    : int}
        (set     : strnptrset_vt (size),
         element : string) :
    [new_size : int | new_size == size || new_size == size + 1]
    strnptrset_vt (new_size)
fun {}
strnptrset_add_strptr
        {size    : int}
        (set     : strnptrset_vt (size),
         element : Strptr1) :
    [new_size : int | new_size == size || new_size == size + 1]
    strnptrset_vt (new_size)
fun {}
strnptrset_add_strnptr
        {size    : int}
        (set     : strnptrset_vt (size),
         element : Strnptr1) :
    [new_size : int | new_size == size || new_size == size + 1]
    strnptrset_vt (new_size)
overload strnptrset_add with strnptrset_add_string of 0
overload strnptrset_add with strnptrset_add_strptr of 10
overload strnptrset_add with strnptrset_add_strnptr of 20

fun {}
strnptrset_del_string
        {size    : int}
        (set     : strnptrset_vt (size),
         element : string) :
    [new_size : int | new_size == size || new_size == size - 1]
    strnptrset_vt (new_size)
fun {}
strnptrset_del_strptr
        {size    : int}
        (set     : strnptrset_vt (size),
         element : !RD(Strptr1) >> _) :
    [new_size : int | new_size == size || new_size == size - 1]
    strnptrset_vt (new_size)
fun {}
strnptrset_del_strnptr
        {size    : int}
        (set     : strnptrset_vt (size),
         element : !RD(Strnptr1) >> _) :
    [new_size : int | new_size == size || new_size == size - 1]
    strnptrset_vt (new_size)
overload strnptrset_del with strnptrset_del_string of 0
overload strnptrset_del with strnptrset_del_strptr of 10
overload strnptrset_del with strnptrset_del_strnptr of 20

fun {}
strnptrset_contains_string
        {size    : int}
        (set     : !RD(strnptrset_vt (size)) >> _,
         element : string) :
    bool
fun {}
strnptrset_contains_strptr
        {size    : int}
        (set     : !RD(strnptrset_vt (size)) >> _,
         element : !RD(Strptr1) >> _) :
    bool
fun {}
strnptrset_contains_strnptr
        {size    : int}
        (set     : !RD(strnptrset_vt (size)) >> _,
         element : !RD(Strnptr1) >> _) :
    bool
overload strnptrset_contains with strnptrset_contains_string of 0
overload strnptrset_contains with strnptrset_contains_strptr of 10
overload strnptrset_contains with strnptrset_contains_strnptr of 20

fun {}
strnptrset_elements
        {size : int}
        (set  : !RD(strnptrset_vt (size)) >> _) :
    list_vt (Strnptr1, size)

fun {}
strnptrset_elements_free
        {size     : int}
        (elements : list_vt (Strnptr1, size)) :
    void

fun {}
strnptrset_free
        {size : int}
        (set  : strnptrset_vt (size)) :
    void
overload free with strnptrset_free

(********************************************************************)
