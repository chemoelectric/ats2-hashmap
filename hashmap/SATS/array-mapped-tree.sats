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

absvtype array_mapped_tree_vt (size : int)

(********************************************************************)

prfun
lemma_array_mapped_tree_vt_param
        {size : int}
        (tree : !array_mapped_tree_vt (size) >> _) :<prf>
    [0 <= size]
    void

fun
array_mapped_tree_is_empty
        {size : int}
        (tree : !array_mapped_tree_vt (size) >> _) :<>
    [is_empty : bool | is_empty == (size == 0)]
    bool is_empty

fun
array_mapped_tree_is_nonempty
        {size : int}
        (tree : !array_mapped_tree_vt (size) >> _) :<>
    [is_nonempty : bool | is_nonempty == (size <> 0)]
    bool is_nonempty

fun
array_mapped_tree_size
        {size : int}
        (tree : !array_mapped_tree_vt (size) >> _) :<>
    size_t size

(********************************************************************)
