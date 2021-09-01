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

#define ATS_DYNLOADFLAG 0

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

staload "hashmap/SATS/structure.sats"

extern praxi
make_IS_VALUE_PTR :
  {i : int} () -<prf> IS_VALUE_PTR (i, i mod 2 == 1)

extern praxi
elim_IS_VALUE_PTR :
  {i : int} {b : bool}
  IS_VALUE_PTR (i, b) -<prf>
    [(b && i mod 2 == 1) || (~b && i mod 2 == 0)]
    void

implement {}
node_entry_right2value_ptr {i} (pf | right) =
  let
    prval _ = elim_IS_VALUE_PTR pf
    prval _ = prop_verify {i mod 2 == 1} ()
  in
    (* Clear the "This is a value pointer" bit. *)
    $UNSAFE.cast (pred ($UNSAFE.cast{uintptr} right))
  end

implement {}
value_ptr2node_entry_right (p) =
  let
    (* Set the "This is a value pointer" bit. The least
       significant bit of the actual pointer will be clear,
       due to alignment of the node. *)
    val i = succ ($UNSAFE.cast{uintptr} p)
    val [i : int] i = $UNSAFE.cast{[i : int] uintptr i} i
    prval _ = $UNSAFE.prop_assert {i mod 2 == 1} ()
  in
    (make_IS_VALUE_PTR {i} () | $UNSAFE.cast i)
  end
