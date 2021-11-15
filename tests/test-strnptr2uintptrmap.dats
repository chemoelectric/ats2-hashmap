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

#include "hashmap/HATS/strnptr2uintptrmap.hats"
#include "tests/INCLUDE/runtime-support.dats"

#define NIL list_vt_nil ()
#define :: list_vt_cons

macdef up = $UNSAFE.cast{uintptr}
macdef str1 = $UNSAFE.castvwtp1{string}

fn {}
value_free_null () : (uintptr, ptr) -> void =
  $UNSAFE.cast the_null_ptr

fn {}
value_copy_null () : (uintptr, ptr) -> uintptr =
  $UNSAFE.cast the_null_ptr

fn
pairs_equal_strnptr_string
        (x : &(@(Strnptr1, uintptr)) >> _,
         y : @(string, uintptr)) :<>
    bool =
  (str1 (x.0) = (y.0)) && ((x.1) = (y.1))
overload = with pairs_equal_strnptr_string of 100

fn
test1 () : void =
  {
    val map = strnptr2uintptrmap ()

    val _ = assertloc (strnptr2uintptrmap_is_empty map)
    val _ = assertloc (iseqz map)
    val _ = assertloc (not (strnptr2uintptrmap_isnot_empty map))
    val _ = assertloc (not (isneqz map))
    val _ = assertloc (size map = i2sz 0)
    val _ = assertloc (strnptr2uintptrmap_size map = i2sz 0)

    val map = strnptr2uintptrmap_set (map, "one", up 1,
                                      value_free_null (),
                                      the_null_ptr)
    val map = strnptr2uintptrmap_set (map, string0_copy "two", up 2,
                                      value_free_null (),
                                      the_null_ptr)
    val map = strnptr2uintptrmap_set (map, string1_copy "three", up 3,
                                      value_free_null (),
                                      the_null_ptr)

    val _ = assertloc (not (strnptr2uintptrmap_is_empty map))
    val _ = assertloc (not (iseqz map))
    val _ = assertloc (strnptr2uintptrmap_isnot_empty map)
    val _ = assertloc (isneqz map)
    val _ = assertloc (size map = i2sz 3)
    val _ = assertloc (strnptr2uintptrmap_size map = i2sz 3)

    val _ = assertloc (strnptr2uintptrmap_has_key (map, "one"))
    val- ~ Some_vt v = strnptr2uintptrmap_get_opt (map, "one",
                                                   value_copy_null (),
                                                   the_null_ptr)
    val _ = assertloc (v = up 1)

    val s = string0_copy "two"
    val _ = assertloc (strnptr2uintptrmap_has_key (map, s))
    val- ~ Some_vt v = strnptr2uintptrmap_get_opt (map, s,
                                                   value_copy_null (),
                                                   the_null_ptr)
    val _ = free s
    val _ = assertloc (v = up 2)

    val s = string1_copy "three"
    val _ = assertloc (strnptr2uintptrmap_has_key (map, s))
    val- ~ Some_vt v = strnptr2uintptrmap_get_opt (map, s,
                                                   value_copy_null (),
                                                   the_null_ptr)
    val _ = free s
    val _ = assertloc (v = up 3)

    val _ = assertloc (not (strnptr2uintptrmap_has_key (map, "four")))
    val- ~ None_vt () = strnptr2uintptrmap_get_opt (map, "four",
                                                    value_copy_null (),
                                                    the_null_ptr)

    val pairs = strnptr2uintptrmap_pairs (map, value_copy_null (),
                                          the_null_ptr)
    val _ = assertloc (length pairs = 3)
    val- @ head :: tail = pairs
    val _ = assertloc (head = @("one", up 1) ||
                       head = @("two", up 2) ||
                       head = @("three", up 3))
    val- @ second :: tail2 = tail
    val _ = assertloc (second = @("one", up 1) ||
                       second = @("two", up 2) ||
                       second = @("three", up 3))
    val- @ third :: tail3 = tail2
    val _ = assertloc (third = @("one", up 1) ||
                       third = @("two", up 2) ||
                       third = @("three", up 3))
    val- @ NIL = tail3
    prval _ = fold@ tail3
    prval _ = fold@ tail2
    prval _ = fold@ tail
    prval _ = fold@ pairs
    val _ = strnptr2uintptrmap_pairs_free (pairs, value_free_null (),
                                           the_null_ptr)

    val keys = strnptr2uintptrmap_keys (map)
    val _ = assertloc (length keys = 3)
    val- @ head :: tail = keys
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
    prval _ = fold@ keys
    val _ = strnptr2uintptrmap_keys_free keys

    val values = strnptr2uintptrmap_values (map, value_copy_null (),
                                            the_null_ptr)
    val _ = assertloc (length values = 3)
    val- @ head :: tail = values
    val _ = assertloc (head = up 1 ||
                       head = up 2 ||
                       head = up 3)
    val- @ second :: tail2 = tail
    val _ = assertloc (second = up 1 ||
                       second = up 2 ||
                       second = up 3)
    val- @ third :: tail3 = tail2
    val _ = assertloc (third = up 1 ||
                       third = up 2 ||
                       third = up 3)
    val- @ NIL = tail3
    prval _ = fold@ tail3
    prval _ = fold@ tail2
    prval _ = fold@ tail
    prval _ = fold@ values
    val _ = strnptr2uintptrmap_values_free (values,
                                            value_free_null (),
                                            the_null_ptr)

    val map = strnptr2uintptrmap_del (map, "two",
                                      value_free_null (),
                                      the_null_ptr)

    val pairs = strnptr2uintptrmap_pairs (map, value_copy_null (),
                                          the_null_ptr)
    val _ = assertloc (length pairs = 2)
    val- @ head :: tail = pairs
    val _ = assertloc (head = @("one", up 1) ||
                       head = @("three", up 3))
    val- @ second :: tail2 = tail
    val _ = assertloc (second = @("one", up 1) ||
                       second = @("three", up 3))
    val- @ NIL = tail2
    prval _ = fold@ tail2
    prval _ = fold@ tail
    prval _ = fold@ pairs
    val _ = strnptr2uintptrmap_pairs_free (pairs, value_free_null (),
                                           the_null_ptr)

    val map = strnptr2uintptrmap_set (map, "two", up 2,
                                      value_free_null (),
                                      the_null_ptr)
    val s = string0_copy "two"
    val map = strnptr2uintptrmap_del (map, s,
                                      value_free_null (),
                                      the_null_ptr)

    val _ = free s

    val pairs = strnptr2uintptrmap_pairs (map, value_copy_null (),
                                          the_null_ptr)
    val _ = assertloc (length pairs = 2)
    val- @ head :: tail = pairs
    val _ = assertloc (head = @("one", up 1) ||
                       head = @("three", up 3))
    val- @ second :: tail2 = tail
    val _ = assertloc (second = @("one", up 1) ||
                       second = @("three", up 3))
    val- @ NIL = tail2
    prval _ = fold@ tail2
    prval _ = fold@ tail
    prval _ = fold@ pairs
    val _ = strnptr2uintptrmap_pairs_free (pairs, value_free_null (),
                                           the_null_ptr)

    val map = strnptr2uintptrmap_set (map, "two", up 2,
                                      value_free_null (),
                                      the_null_ptr)
    val s = string1_copy "two"
    val map = strnptr2uintptrmap_del (map, s,
                                      value_free_null (),
                                      the_null_ptr)
    val _ = free s

    val pairs = strnptr2uintptrmap_pairs (map, value_copy_null (),
                                          the_null_ptr)
    val _ = assertloc (length pairs = 2)
    val- @ head :: tail = pairs
    val _ = assertloc (head = @("one", up 1) ||
                       head = @("three", up 3))
    val- @ second :: tail2 = tail
    val _ = assertloc (second = @("one", up 1) ||
                       second = @("three", up 3))
    val- @ NIL = tail2
    prval _ = fold@ tail2
    prval _ = fold@ tail
    prval _ = fold@ pairs
    val _ = strnptr2uintptrmap_pairs_free (pairs, value_free_null (),
                                           the_null_ptr)

    val _ = strnptr2uintptrmap_free (map, value_free_null (),
                                     the_null_ptr)
  }

implement
main0 () =
  {
    val _ = test1 ()
  }
