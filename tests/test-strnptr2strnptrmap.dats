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

#include "hashmap/HATS/strnptr2strnptrmap.hats"
#include "tests/INCLUDE/runtime-support.dats"

#define NIL list_vt_nil ()
#define :: list_vt_cons

macdef str1 = $UNSAFE.castvwtp1{string}

fn
strnptr_eq_string (x : !Strnptr1,
                   y : string) :<>
    bool =
  (str1 x = y)
overload = with strnptr_eq_string of 1000

fn
pairs_equal_strnptrpair_stringpair
        (x : &(@(Strnptr1, Strnptr1)) >> _,
         y : @(string, string)) :<>
    bool =
  ((x.0) = (y.0)) && ((x.1) = (y.1))
overload = with pairs_equal_strnptrpair_stringpair of 1000

fn
test1 () : void =
  {
    val map = strnptr2strnptrmap ()

    val _ = assertloc (strnptr2strnptrmap_is_empty map)
    val _ = assertloc (iseqz map)
    val _ = assertloc (not (strnptr2strnptrmap_isnot_empty map))
    val _ = assertloc (not (isneqz map))
    val _ = assertloc (size map = i2sz 0)
    val _ = assertloc (strnptr2strnptrmap_size map = i2sz 0)

    val map = strnptr2strnptrmap_set (map, "one", "ett")
    val map = strnptr2strnptrmap_set (map, string0_copy "two", "två")
    val map = strnptr2strnptrmap_set (map, string1_copy "three", "tre")

    val _ = assertloc (not (strnptr2strnptrmap_is_empty map))
    val _ = assertloc (not (iseqz map))
    val _ = assertloc (strnptr2strnptrmap_isnot_empty map)
    val _ = assertloc (isneqz map)
    val _ = assertloc (size map = i2sz 3)
    val _ = assertloc (strnptr2strnptrmap_size map = i2sz 3)

    val _ = assertloc (strnptr2strnptrmap_has_key (map, "one"))
    val- ~ Some_vt v = strnptr2strnptrmap_get_opt (map, "one")
    val _ = assertloc (v = "ett")
    val _ = free v

    val s = string0_copy "two"
    val _ = assertloc (strnptr2strnptrmap_has_key (map, s))
    val- ~ Some_vt v = strnptr2strnptrmap_get_opt (map, s)
    val _ = free s
    val _ = assertloc (v = "två")
    val _ = free v

    val s = string1_copy "three"
    val _ = assertloc (strnptr2strnptrmap_has_key (map, s))
    val- ~ Some_vt v = strnptr2strnptrmap_get_opt (map, s)
    val _ = free s
    val _ = assertloc (v = "tre")
    val _ = free v

    val _ = assertloc (not (strnptr2strnptrmap_has_key (map, "four")))
    val- ~ None_vt () = strnptr2strnptrmap_get_opt (map, "four")

    val pairs = strnptr2strnptrmap_pairs (map)
    val _ = assertloc (length pairs = 3)
    val- @ head :: tail = pairs
    val _ = assertloc (head = @("one", "ett") ||
                       head = @("two", "två") ||
                       head = @("three", "tre"))
    val- @ second :: tail2 = tail
    val _ = assertloc (second = @("one", "ett") ||
                       second = @("two", "två") ||
                       second = @("three", "tre"))
    val- @ third :: tail3 = tail2
    val _ = assertloc (third = @("one", "ett") ||
                       third = @("two", "två") ||
                       third = @("three", "tre"))
    val- @ NIL = tail3
    prval _ = fold@ tail3
    prval _ = fold@ tail2
    prval _ = fold@ tail
    prval _ = fold@ pairs
    val _ = strnptr2strnptrmap_pairs_free (pairs)

    val keys = strnptr2strnptrmap_keys (map)
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
    val _ = strnptr2strnptrmap_keys_free keys

    val values = strnptr2strnptrmap_values (map)
    val _ = assertloc (length values = 3)
    val- @ head :: tail = values
    val _ = assertloc (head = "ett" ||
                       head = "två" ||
                       head = "tre")
    val- @ second :: tail2 = tail
    val _ = assertloc (second = "ett" ||
                       second = "två" ||
                       second = "tre")
    val- @ third :: tail3 = tail2
    val _ = assertloc (third = "ett" ||
                       third = "två" ||
                       third = "tre")
    val- @ NIL = tail3
    prval _ = fold@ tail3
    prval _ = fold@ tail2
    prval _ = fold@ tail
    prval _ = fold@ values
    val _ = strnptr2strnptrmap_values_free (values)

    val map = strnptr2strnptrmap_del (map, "two")

    val pairs = strnptr2strnptrmap_pairs (map)
    val _ = assertloc (length pairs = 2)
    val- @ head :: tail = pairs
    val _ = assertloc (head = @("one", "ett") ||
                       head = @("three", "tre"))
    val- @ second :: tail2 = tail
    val _ = assertloc (second = @("one", "ett") ||
                       second = @("three", "tre"))
    val- @ NIL = tail2
    prval _ = fold@ tail2
    prval _ = fold@ tail
    prval _ = fold@ pairs
    val _ = strnptr2strnptrmap_pairs_free (pairs)

    val map = strnptr2strnptrmap_set (map, "two", "två")
    val s = string0_copy "two"
    val map = strnptr2strnptrmap_del (map, s)
    val _ = free s

    val pairs = strnptr2strnptrmap_pairs (map)
    val _ = assertloc (length pairs = 2)
    val- @ head :: tail = pairs
    val _ = assertloc (head = @("one", "ett") ||
                       head = @("three", "tre"))
    val- @ second :: tail2 = tail
    val _ = assertloc (second = @("one", "ett") ||
                       second = @("three", "tre"))
    val- @ NIL = tail2
    prval _ = fold@ tail2
    prval _ = fold@ tail
    prval _ = fold@ pairs
    val _ = strnptr2strnptrmap_pairs_free (pairs)

    val map = strnptr2strnptrmap_set (map, "two", "två")
    val s = string1_copy "two"
    val map = strnptr2strnptrmap_del (map, s)
    val _ = free s

    val pairs = strnptr2strnptrmap_pairs (map)
    val _ = assertloc (length pairs = 2)
    val- @ head :: tail = pairs
    val _ = assertloc (head = @("one", "ett") ||
                       head = @("three", "tre"))
    val- @ second :: tail2 = tail
    val _ = assertloc (second = @("one", "ett") ||
                       second = @("three", "tre"))
    val- @ NIL = tail2
    prval _ = fold@ tail2
    prval _ = fold@ tail
    prval _ = fold@ pairs
    val _ = strnptr2strnptrmap_pairs_free (pairs)

    val map = strnptr2strnptrmap_del (map, "one")
    val map = strnptr2strnptrmap_del (map, "two")
    val map = strnptr2strnptrmap_del (map, "three")
    val map = strnptr2strnptrmap_set (map, "one", string0_copy "ett")
    val map = strnptr2strnptrmap_set (map, string0_copy "two", string0_copy "två")
    val map = strnptr2strnptrmap_set (map, string1_copy "three", string0_copy "tre")

    val _ = assertloc (not (strnptr2strnptrmap_is_empty map))
    val _ = assertloc (not (iseqz map))
    val _ = assertloc (strnptr2strnptrmap_isnot_empty map)
    val _ = assertloc (isneqz map)
    val _ = assertloc (size map = i2sz 3)
    val _ = assertloc (strnptr2strnptrmap_size map = i2sz 3)

    val map = strnptr2strnptrmap_del (map, "one")
    val map = strnptr2strnptrmap_del (map, "two")
    val map = strnptr2strnptrmap_del (map, "three")
    val map = strnptr2strnptrmap_set (map, "one", string1_copy "ett")
    val map = strnptr2strnptrmap_set (map, string0_copy "two", string1_copy "två")
    val map = strnptr2strnptrmap_set (map, string1_copy "three", string1_copy "tre")

    val _ = assertloc (not (strnptr2strnptrmap_is_empty map))
    val _ = assertloc (not (iseqz map))
    val _ = assertloc (strnptr2strnptrmap_isnot_empty map)
    val _ = assertloc (isneqz map)
    val _ = assertloc (size map = i2sz 3)
    val _ = assertloc (strnptr2strnptrmap_size map = i2sz 3)

    val _ = strnptr2strnptrmap_free (map)
  }

implement
main0 () =
  {
    val _ = test1 ()
  }
