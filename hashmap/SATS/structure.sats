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

(********************************************************************)

absprop IS_VALUE_PTR (b : bool)
propdef IS_VALUE_PTR = IS_VALUE_PTR (true)
propdef IS_BASE_PTR (b : bool) = IS_VALUE_PTR (~b)
propdef IS_BASE_PTR = IS_VALUE_PTR (false)

abst@ype node_entry_left_t = uintptr

#ifdef ENABLE_ODD_ALIGNMENT #then
  abst@ype node_entry_right_t = @(ptr, uint8)
#else
  abst@ype node_entry_right_t = uintptr
#endif

typedef node_entry_t = @(node_entry_left_t, node_entry_right_t)

fun {}
node_entry_right_is_value_ptr :
  node_entry_right_t -<> [b : bool] @(IS_VALUE_PTR (b) | bool b)

fun {}
node_entry_right_is_base_ptr :
  node_entry_right_t -<> [b : bool] @(IS_BASE_PTR (b) | bool b)

(********************************************************************)
(* Key-value pairs. (That is, leaf nodes.) *)

abstype key_ptr_t (p : addr) = ptr p
typedef key_ptr_t = [p : addr] key_ptr_t p

abstype value_ptr_t (p : addr) = ptr p
typedef value_ptr_t = [p : addr] value_ptr_t p

fun {}
node_entry_left2key_ptr : node_entry_left_t -<> key_ptr_t

fun {}
key_ptr2node_entry_left : key_ptr_t -<> node_entry_left_t

fun {}
node_entry_right2value_ptr :
  (IS_VALUE_PTR | node_entry_right_t) -<> value_ptr_t

fun {}
value_ptr2node_entry_right :
  value_ptr_t -<> @(IS_VALUE_PTR | node_entry_right_t)

(********************************************************************)
(* Map-base pairs. (That is, internal nodes.) *)

typedef entry_map_t (i : int) = uintptr i
typedef entry_map_t = [i : int] uintptr i

viewdef node_v (length : int, p : addr) =
  @[node_entry_t][length] @ p

vtypedef node_vt (length : int, p : addr) =
  @(node_v (length, p) | ptr p)
vtypedef node_vt (length : int) =
  [p : addr] node_vt (length, p)
vtypedef node_vt =
  [length : int] node_vt (length)

fun {}
node_entry_left2entry_map : node_entry_left_t -<> entry_map_t

fun {}
entry_map2node_entry_left : entry_map_t -<> node_entry_left_t

fun {}
node_entry_right2node_vt :
  {length : int}
  (IS_BASE_PTR | node_entry_right_t) -<> node_vt (length)

fun {}
node_vt2node_entry_right :
  {length : int}
  node_vt (length) -<> @(IS_BASE_PTR | node_entry_right_t)

(********************************************************************)
