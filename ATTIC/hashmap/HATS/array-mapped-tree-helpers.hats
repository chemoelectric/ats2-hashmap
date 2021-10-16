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

symintr <<
infixl ( * ) <<
overload << with g0uint_lsl_uintptr

symintr >>
infixl ( * ) >>
overload >> with g0uint_lsr_uintptr

symintr <*>
infixl ( * ) <*>
overload <*> with g0uint_land_uintptr

symintr <+>
infixl ( * ) <+>
overload <+> with g0uint_lor_uintptr

symintr <~>
prefix ( * ) <~>
overload <~> with g0uint_lnot_uintptr

extern castfn
g1int2uint_int_uintpr :
  {i : int | 0 <= i} int i -<> uintptr i

implement
g1int2uint<intknd,uintptrknd> = g1int2uint_int_uintptr

macdef zero = g1int2uint<intknd,uintptrknd> 0
macdef one = g1int2uint<intknd,uintptrknd> 1

fn {}
bit_is_set (bits               : uintptr,
            bit_selection_mask : uintptr) :<> bool =
  (bits <*> bit_selection_mask) <> zero

fn {}
set_bit (bits               : uintptr,
         bit_selection_mask : uintptr) :<> uintptr =
  (bits <+> bit_selection_mask)

fn {}
clear_bit (bits               : uintptr,
           bit_selection_mask : uintptr) :<> uintptr =
  (bits <*> (<~> bit_selection_mask))

#define NIL list_vt_nil ()
#define :: list_vt_cons

fn {}
orelse1 {x, y : bool}
        (x : bool x,
         y : bool y) :<>
    [z : bool | z == (x || y)]
    bool z =
  if x then
    true
  else
    y
infixl ( || ) |||
macdef ||| = orelse1
