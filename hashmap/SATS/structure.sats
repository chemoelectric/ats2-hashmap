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

%{

/* The implementation here assumes (a) that memory is allocated by
 * malloc(3) or a compatible equivalent (such as Boehm GC); (b) that
 * values entered in the tree are allocated with such a malloc;
 * (c) that malloc aligns the allocated memory on an even address. */

_Static_assert (_Alignof (long double) % 2 != 1,
                "malloc(3) might return odd addresses. "
                "We do not support such platforms.");

%}

(********************************************************************)

abst@ype node_entry_left_t (i : int) = uintptr i
typedef node_entry_left_t = [i : int] node_entry_left_t i

abst@ype node_entry_right_t (i : int) = uintptr i
typedef node_entry_right_t = [i : int] node_entry_right_t i

typedef node_entry_t (left : int, right : int) =
  @(node_entry_left_t left, node_entry_right_t right)
typedef node_entry_t =
  [left, right : int] node_entry_t (left, right)

abstype key_ptr_t (p : addr) = ptr p
typedef key_ptr_t = [p : addr] key_ptr_t p

abstype value_ptr_t (p : addr) = ptr p
typedef value_ptr_t = [p : addr] value_ptr_t p

castfn
node_entry_left2key_ptr : node_entry_left_t -<> key_ptr_t

castfn
key_ptr2node_entry_left : key_ptr_t -<> node_entry_left_t

fun {}
node_entry_right2value_ptr :
  {i : int | i mod 2 == 1}
  node_entry_right_t i -<> value_ptr_t

fun {}
value_ptr2node_entry_right :
  value_ptr_t -<>
    [i : int | i mod 2 == 1]
    node_entry_right_t i

(********************************************************************)

viewdef node_v (length : int, p : addr) =
  @[node_entry_t][length] @ p

vtypedef node_vt (length : int, p : addr) =
  @(node_v (length, p) | ptr p)
vtypedef node_vt (length : int) =
  [p : addr] node_vt (length, p)
vtypedef node_vt =
  [length : int] node_vt (length)

castfn
node_entry_right2node_vt :
  {length : int}
  {i      : int | i mod 2 == 0}
  node_entry_right_t i -<> node_vt (length)

castfn
node_vt2node_entry_right :
  {length : int}
  node_vt (length) -<>
    [i : int | i mod 2 == 0]
    node_entry_right_t i

(********************************************************************)
