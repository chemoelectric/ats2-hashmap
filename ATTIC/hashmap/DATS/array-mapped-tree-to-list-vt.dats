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

#define ATS_DYNLOADFLAG 0

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

staload UN = "prelude/SATS/unsafe.sats"

staload "hashmap/SATS/array-mapped-tree.sats"
staload "hashmap/SATS/array-mapped-tree-templates.sats"
staload "hashmap/SATS/array-mapped-tree-subtree-to-list-vt.sats"
staload "hashmap/SATS/uptr.sats"

staload _ = "hashmap/DATS/array-mapped-tree-templates.dats"
staload _ = "hashmap/DATS/uptr.dats"

#include "hashmap/HATS/array-mapped-tree-helpers.hats"

implement
array_mapped_tree_to_list_vt (node_p) =
  let
    (* Create a linear type from the pointer. *)
    val node = uptr2node (ptr2uptr (g1ofg0 node_p))

    (* Get the array-mapped tree contents, as a list. (Also
       get the list's length, so it can be checked against
       the size of the array-mapped tree.) *)
    prval _ = lemma_node_vt_param node
    val result_and_length =
      array_mapped_tree_subtree_to_list_vt (node)

    (* Consume the linear type. *)
    prval _ = $UNSAFE.castvwtp0{void} node
  in
    result_and_length
  end
