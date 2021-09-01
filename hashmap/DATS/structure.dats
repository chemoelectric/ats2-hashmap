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

implement {}
node_entry_right2value_ptr (right) =
  (* Clear the "This is a value pointer" bit. *)
  $UNSAFE.cast (pred ($UNSAFE.cast{uintptr} right))

implement {}
value_ptr2node_entry_right (p) =
  (* Set the "This is a value pointer" bit. The least
     significant bit of the actual pointer will be clear,
     due to alignment of the node. *)
  $UNSAFE.cast (succ ($UNSAFE.cast{uintptr} p))
