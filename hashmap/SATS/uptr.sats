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

%{#
#include "hashmap/CATS/uptr.cats"
%}

(********************************************************************)
(* uptr -- a uintptr treated as a pointer. *)

abst@ype uptr (p : addr) = uintptr
typedef uptr = [p : addr] uptr p

castfn
uintptr2uptr : uintptr -<> uptr

castfn
uptr2uintptr : uptr -<> uintptr

fn
ptr2uptr : {p : addr} ptr p -<> uptr p = "mac#%"

fn
uptr2ptr : {p : addr} uptr p -<> ptr p = "mac#%"

fun {t : vt@ype}
uptr_succ {p : addr} (p : uptr p) :<>
    uptr (p + sizeof (t))

fun {t : vt@ype}
uptr_pred {p : addr} (p : uptr p) :<>
    uptr (p - sizeof (t))

fun {t  : vt@ype}
    {tk : tkind}
uptr_add_g1int {p : addr}
               {i : int}
               (p : uptr p,
                i : g1int (tk, i)) :<>
    uptr (p + i * sizeof (t))

fun {t  : vt@ype}
    {tk : tkind}
uptr_add_g1uint {p : addr}
                {i : int}
                (p : uptr p,
                 i : g1uint (tk, i)) :<>
    uptr (p + i * sizeof (t))

overload uptr_add with uptr_add_g1int
overload uptr_add with uptr_add_g1uint

fun {t  : vt@ype}
    {tk : tkind}
uptr_sub_g1int {p : addr}
               {i : int}
               (p : uptr p,
                i : g1int (tk, i)) :<>
    uptr (p - i * sizeof (t))

fun {t  : vt@ype}
    {tk : tkind}
uptr_sub_g1uint {p : addr}
                {i : int}
                (p : uptr p,
                 i : g1uint (tk, i)) :<>
    uptr (p - i * sizeof (t))

overload uptr_sub with uptr_sub_g1int
overload uptr_sub with uptr_sub_g1uint

fun {t : vt@ype}
uptr_get {p  : addr}
         (pf : !INV(t) @ p >> t?! @ p |
          p  : uptr p) :<> t

fun {t : vt@ype}
uptr_set {p  : addr}
         (pf : !t? @ p >> t @ p |
          p  : uptr p,
          x  : INV(t)) :<!wrt> void

fun {t : vt@ype}
uptr_exch {p : addr}
          (pf: !INV(t) @ p |
           p : uptr p,
           x : &t >> t) :<!wrt> void

(********************************************************************)
