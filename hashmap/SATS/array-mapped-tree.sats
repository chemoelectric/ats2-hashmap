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

fun
array_mapped_tree_create
        {bits_source_p : addr}
        {hash_data_p   : addr}
        (bits_source_p : ptr bits_source_p,
         hash_data_p   : ptr hash_data_p,
         value         : uintptr) :
    [node_p : addr | null < node_p]
    ptr node_p

fun
array_mapped_tree_set_entry
        {node_p        : addr | null < node_p}
        {bits_source_p : addr}
        {hash_data_p   : addr}
        {key_test_p    : addr}
        {key_data_p    : addr}
        (node_p        : &(ptr node_p) >> ptr new_node_p,
         bits_source_p : ptr bits_source_p,
         hash_data_p   : ptr hash_data_p,
         key_test_p    : ptr key_test_p,
         key_data_p    : ptr key_data_p,
         value         : uintptr,
         is_new_slot   : &bool? >> bool is_new_slot) :
    #[new_node_p  : addr]
    #[is_new_slot : bool]
    void

fun
array_mapped_tree_get_entry
        {node_p        : addr}
        {bits_source_p : addr}
        {hash_data_p   : addr}
        {key_test_p    : addr}
        {key_data_p    : addr}
        (node_p        : ptr node_p,
         bits_source_p : ptr bits_source_p,
         hash_data_p   : ptr hash_data_p,
         key_test_p    : ptr key_test_p,
         key_data_p    : ptr key_data_p,
         is_stored     : &bool? >> bool is_stored,
         value         : &uintptr? >>
                            [u : int | is_stored || u == 0]
                            uintptr u) :
    #[is_stored : bool]
    void

(********************************************************************)
