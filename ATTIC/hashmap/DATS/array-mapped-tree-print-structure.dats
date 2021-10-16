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

staload "hashmap/SATS/array-mapped-tree.sats"
staload "hashmap/SATS/array-mapped-tree-templates.sats"
staload "hashmap/SATS/array-mapped-tree-print-subtree-structure.sats"
staload "hashmap/SATS/uptr.sats"

staload _ = "hashmap/DATS/array-mapped-tree-templates.dats"
staload _ = "hashmap/DATS/uptr.dats"

implement
array_mapped_tree_print_structure (out, node_p, print_key_value) =
  {
    (* Create a linear type from the pointer. *)
    val node = uptr2node (ptr2uptr (g1ofg0 node_p))

    (* Print the tree structure. *)
    prval _ = lemma_node_vt_param node
    val _ = print_subtree_structure (out, node, 0U, print_key_value)

    (* Consume the linear type. *)
    prval _ = $UNSAFE.castvwtp0{void} node
  }

