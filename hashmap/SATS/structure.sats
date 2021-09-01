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

typedef node_entry_t (left : int, right : addr) =
  @(uintptr left, ptr right)
typedef node_entry_t =
  [left : int] [right : addr] node_entry_t (left, right)

viewdef node_v (length : int, p : addr) =
  @[node_entry_t][length] @ p

vtypedef node_vt (length : int, p : addr) =
  @(node_v (length, p) | ptr p)
