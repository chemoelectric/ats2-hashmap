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

typedef array_mapped_tree_vt (node_p : addr) =
  ptr node_p
typedef array_mapped_tree_vt =
  [node_p : addr] array_mapped_tree_vt node_p

(* If free_entry_p is NULL, then the stored entries are not freed
   and should be of a nonlinear type. *)
fun
array_mapped_tree_free
        {node_p       : addr}
        {free_entry_p : addr}   (* May be null. *)
        (node_p       : array_mapped_tree_vt node_p,
         free_entry_p : ptr free_entry_p) :
    void

(********************************************************************)

(* If key_test_p is null, then key_data_p is assumed to point to
   a uintptr. *)
fun
array_mapped_tree_get_entry
        {node_p        : addr}
        {bits_source_p : addr}
        {hash_data_p   : addr}
        {key_test_p    : addr}
        {key_data_p    : addr}
        (node_p        : array_mapped_tree_vt node_p,
         bits_source_p : ptr bits_source_p,
         hash_data_p   : ptr hash_data_p,
         key_test_p    : ptr key_test_p, (* May be null. *)
         key_data_p    : ptr key_data_p,
         is_stored     : &bool? >> bool is_stored,
         value         : &uintptr? >>
                            [u : int | is_stored || u == 0]
                            uintptr u) :
    #[is_stored : bool] void

(********************************************************************)

(*
vtypedef array_mapped_tree_create_entry_t (p : addr) =
  @{
    view = uintptr @ p |
    pointer = ptr p,
    is_new = bool
  }
vtypedef array_mapped_tree_create_entry_t =
  [p : addr]
  array_mapped_tree_create_entry_t (p)

fun
array_mapped_tree_create_entry
        {node_p        : addr}
        {bits_source_p : addr}
        {hash_data_p  : addr}
        (node_p        : array_mapped_tree_vt node_p,
         bits_source_p : ptr bits_source_p,
         hash_data_p  : ptr hash_data_p) :
  array_mapped_tree_get_entry_t
*)

(********************************************************************)
