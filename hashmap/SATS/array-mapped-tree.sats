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

vtypedef array_mapped_tree_vt =
  [node_p : addr] ptr node_p

fun
free_array_mapped_tree
        {node_p       : addr}
        {free_entry_p : addr}
        (node_p       : ptr node_p,
         free_entry_p : ptr free_entry_p) :
    void

(********************************************************************)

typedef array_mapped_tree_get_entry_t =
  @{
    is_stored = bool,
    value = uintptr
  }

fun
array_mapped_tree_get_entry
        {node_p        : addr}
        {bits_source_p : addr}
        {index_data_p  : addr}
        (node_p        : ptr node_p,
         bits_source_p : ptr bits_source_p,
         index_data_p  : ptr index_data_p) :
    array_mapped_tree_get_entry_t

(********************************************************************)
