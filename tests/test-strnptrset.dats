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

#include "hashmap/HATS/strnptrset.hats"
#include "tests/INCLUDE/runtime-support.dats"

#define NIL list_vt_nil ()
#define :: list_vt_cons

macdef str1 = $UNSAFE.castvwtp1{string}

implement
main0 () =
  {
    val set = strnptrset ()

    val _ = assertloc (strnptrset_is_empty set)
    val _ = assertloc (iseqz set)
    val _ = assertloc (not (strnptrset_isnot_empty set))
    val _ = assertloc (not (isneqz set))
    val _ = assertloc (size set = i2sz 0)
    val _ = assertloc (strnptrset_size set = i2sz 0)

    val set = strnptrset_add (set, "one")
    val set = strnptrset_add (set, string0_copy "two")
    val set = strnptrset_add (set, string1_copy "three")

    val _ = assertloc (not (strnptrset_is_empty set))
    val _ = assertloc (not (iseqz set))
    val _ = assertloc (strnptrset_isnot_empty set)
    val _ = assertloc (isneqz set)
    val _ = assertloc (size set = i2sz 3)
    val _ = assertloc (strnptrset_size set = i2sz 3)

    val _ = assertloc (strnptrset_contains (set, "one"))

    val s = string0_copy "two"
    val _ = assertloc (strnptrset_contains (set, s))
    val _ = free s

    val s = string1_copy "three"
    val _ = assertloc (strnptrset_contains (set, s))
    val _ = free s

    val _ = assertloc (not (strnptrset_contains (set, "four")))

    val elements = strnptrset_elements (set)
    val _ = assertloc (length elements = 3)
    val- @ head :: tail = elements
    val _ = assertloc (str1 head = "one" ||
                       str1 head = "two" ||
                       str1 head = "three")
    val- @ second :: tail2 = tail
    val _ = assertloc (str1 second = "one" ||
                       str1 second = "two" ||
                       str1 second = "three")
    val- @ third :: tail3 = tail2
    val _ = assertloc (str1 third = "one" ||
                       str1 third = "two" ||
                       str1 third = "three")
    val- @ NIL = tail3
    prval _ = fold@ tail3
    prval _ = fold@ tail2
    prval _ = fold@ tail
    prval _ = fold@ elements
    val _ = strnptrset_elements_free elements

    val set = strnptrset_del (set, "two")

    val elements = strnptrset_elements (set)
    val _ = assertloc (length elements = 2)
    val- @ head :: tail = elements
    val _ = assertloc (str1 head = "one" ||
                       str1 head = "three")
    val- @ second :: tail2 = tail
    val _ = assertloc (str1 second = "one" ||
                       str1 second = "three")
    val- @ NIL = tail2
    prval _ = fold@ tail2
    prval _ = fold@ tail
    prval _ = fold@ elements
    val _ = strnptrset_elements_free elements

    val set = strnptrset_add (set, "two")
    val s = string0_copy "two"
    val set = strnptrset_del (set, s)
    val _ = free s

    val elements = strnptrset_elements (set)
    val _ = assertloc (length elements = 2)
    val- @ head :: tail = elements
    val _ = assertloc (str1 head = "one" ||
                       str1 head = "three")
    val- @ second :: tail2 = tail
    val _ = assertloc (str1 second = "one" ||
                       str1 second = "three")
    val- @ NIL = tail2
    prval _ = fold@ tail2
    prval _ = fold@ tail
    prval _ = fold@ elements
    val _ = strnptrset_elements_free elements

    val set = strnptrset_add (set, "two")
    val s = string1_copy "two"
    val set = strnptrset_del (set, s)
    val _ = free s

    val elements = strnptrset_elements (set)
    val _ = assertloc (length elements = 2)
    val- @ head :: tail = elements
    val _ = assertloc (str1 head = "one" ||
                       str1 head = "three")
    val- @ second :: tail2 = tail
    val _ = assertloc (str1 second = "one" ||
                       str1 second = "three")
    val- @ NIL = tail2
    prval _ = fold@ tail2
    prval _ = fold@ tail
    prval _ = fold@ elements
    val _ = strnptrset_elements_free elements

    val _ = free set
  }
