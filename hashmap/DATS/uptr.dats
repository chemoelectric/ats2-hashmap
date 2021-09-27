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

staload "hashmap/SATS/uptr.sats"

primplement
uptr_is_gtez {p} (p) =
  ptr1_is_gtez {p} (uptr2ptr {p} p)

implement
uptr_is_null {p} (p) =
  ptr_is_null {p} (uptr2ptr {p} p)

implement
uptr_isnot_null {p} (p) =
  ptr_isnot_null {p} (uptr2ptr {p} p)

implement {t}
uptr_succ {p} (p) =
  ptr2uptr (ptr_succ<t> {p} (uptr2ptr p))

implement {t}
uptr_pred {p} (p) =
  ptr2uptr (ptr_pred<t> {p} (uptr2ptr p))

implement {t} {tk}
uptr_add_g1int {p} {i} (p, i) =
  ptr2uptr (ptr_add {p} {i} (uptr2ptr p, i))

implement {t} {tk}
uptr_add_g1uint {p} {i} (p, i) =
  ptr2uptr (ptr_add {p} {i} (uptr2ptr p, i))

implement {t} {tk}
uptr_sub_g1int {p} {i} (p, i) =
  ptr2uptr (ptr_sub {p} {i} (uptr2ptr p, i))

implement {t} {tk}
uptr_sub_g1uint {p} {i} (p, i) =
  ptr2uptr (ptr_sub {p} {i} (uptr2ptr p, i))

implement {t}
uptr_get {p} (pf | p) =
  ptr_get<t> {p} (pf | uptr2ptr p)

implement {t}
uptr_set {p} (pf | p, x) =
  ptr_set<t> {p} (pf | uptr2ptr p, x)

implement {t}
uptr_exch {p} (pf | p, x) =
  ptr_exch<t> {p} (pf | uptr2ptr p, x)

implement {}
uintptr2ptr (i) =
  uptr2ptr (uintptr2uptr i)

implement {}
ptr2uintptr {p} (p) =
  (uptr2uintptr (ptr2uptr {p} p))
