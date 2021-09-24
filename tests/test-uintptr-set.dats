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

staload "hashmap/SATS/uintptr-set.sats"
staload _ = "hashmap/DATS/uintptr-set.dats"

macdef zero = $UN.cast{[i : int] uintptr i} 0
prval _ = lemma_g1uint_param zero

macdef reasonably_big_number =
  $UN.cast{[i : int] uintptr i} 0x1000000U
prval _ = lemma_g1uint_param reasonably_big_number

implement
g1uint_succ<uintptrknd> (x) =
  $UN.cast (succ ($UN.cast{uintptr} x))

implement
g1uint_eq<uintptrknd> (x, y) =
  $UN.cast (($UN.cast{uintptr} x) = ($UN.cast{uintptr} y))

implement
g1uint_lte<uintptrknd> (x, y) =
  $UN.cast (($UN.cast{uintptr} x) <= ($UN.cast{uintptr} y))

fn
println_uintptr (x : uintptr) : void =
  {
    val _ = $extfcall (int, "printf", "%08llX\n", $UN.cast{ullint} x)
  }

fn
test_empty () : void =
  {
    val set = uintptr_set ()
    val _ = assertloc (size set = i2sz 0)
    val _ = assertloc (iseqz set)
    val _ = assertloc (not (isneqz set))
    val _ =
      let
        var i : [i : int] uintptr i
      in
        for (i := zero; i <= reasonably_big_number; i := succ i)
          assertloc (not (has_element (set, $UN.cast i)))
      end
    val _ = free set
  }

fn
test_size_one () : void =
  {
    val entry_value = $UN.cast{[i : int] uintptr i} 0x10U

    val set = uintptr_set ()

    val set = add_element (set, entry_value)
    val _ = assertloc (size set = i2sz 1)
    val _ = assertloc (not (iseqz set))
    val _ = assertloc (isneqz set)
    val _ = assertloc (has_element (set, entry_value))
    val _ =
      let
        var i : [i : int] uintptr i
      in
        for (i := zero; i <= reasonably_big_number; i := succ i)
          begin
            //println_uintptr (i);
            if i = entry_value then
              assertloc (has_element (set, i))
            else
              assertloc (not (has_element (set, i)))
          end
      end

    (* Add the same entry. Also, use different notations for
       the same operations. *)
    val set = set + entry_value
    val _ = assertloc (size set = i2sz 1)
    val _ = assertloc (not (iseqz set))
    val _ = assertloc (isneqz set)
    val _ =
      let
        var i : [i : int] uintptr i
      in
        for (i := zero; i <= reasonably_big_number; i := succ i)
          begin
            //println_uintptr (i);
            if i = entry_value then
              assertloc (set \contains i)
            else
              assertloc (not (set \contains i))
          end
      end

    val _ = free set
  }

fn
test_root_node_expansion () : void =
  {
    val entry1 = $UN.cast{[i : int] uintptr i} 0x01U
    val entry2 = $UN.cast{[i : int] uintptr i} 0x02U

    val set = uintptr_set () + entry1 + entry2

    val _ = assertloc (size set = i2sz 2)
    val _ = assertloc (not (iseqz set))
    val _ = assertloc (isneqz set)

    val _ =
      let
        var i : [i : int] uintptr i
      in
        for (i := zero; i <= reasonably_big_number; i := succ i)
          begin
            //println_uintptr (i);
            if i = entry1 || i = entry2 then
              assertloc (set \contains i)
            else
              assertloc (not (set \contains i))
          end
      end

    val _ = free set
  }

implement
main0 () =
  {
    val _ = test_empty ()
    val _ = test_size_one ()
    val _ = test_root_node_expansion ()
  }
