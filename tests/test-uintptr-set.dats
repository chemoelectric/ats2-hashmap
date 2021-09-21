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

staload "hashmap/SATS/uintptr-set.sats"
staload _ = "hashmap/DATS/uintptr-set.dats"

fn
test_empty () : void =
  {
    val set = uintptr_set ()
    val _ = assertloc (size set = i2sz 0)
    val _ = assertloc (iseqz set)
    val _ = assertloc (not (isneqz set))
    val _ = assertloc (not (has_element (set, $UNSAFE.cast 1234)))
    val _ = assertloc (not (has_element (set, $UNSAFE.cast 12345)))
    val _ = free set
  }

fn
test_size_one () : void =
  {
    val set = uintptr_set ()
    val set = add_element (set, $UNSAFE.cast 1234)
    val _ = assertloc (size set = i2sz 1)
    val _ = assertloc (not (iseqz set))
    val _ = assertloc (isneqz set)
    val _ = assertloc (has_element (set, $UNSAFE.cast 1234))
    val _ = assertloc (not (has_element (set, $UNSAFE.cast 12345)))
    val _ = free set

    val set = uintptr_set ()
    val set = set + ($UNSAFE.cast 1234)
    val _ = assertloc (size set = i2sz 1)
    val _ = assertloc (not (iseqz set))
    val _ = assertloc (isneqz set)
    val _ = assertloc (set \contains ($UNSAFE.cast 1234))
    val _ = assertloc (not (set \contains ($UNSAFE.cast 12345)))
    val _ = free set
  }

implement
main0 () =
  {
    val _ = test_empty ()
    val _ = test_size_one ()
  }
