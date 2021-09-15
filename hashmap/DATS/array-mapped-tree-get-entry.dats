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

#include "share/atspre_staload.hats"

staload UN = "prelude/SATS/unsafe.sats"

staload "hashmap/SATS/array-mapped-tree.sats"
staload "hashmap/SATS/array-mapped-tree-templates.sats"
staload "hashmap/SATS/bits-source.sats"

staload _ = "hashmap/DATS/array-mapped-tree-templates.dats"
staload _ = "hashmap/DATS/count-one-bits.dats"

implement
array_mapped_tree_get_entry {node_p} {bits_source_p} {index_data_p}
                            (node_p, bits_source_p, index_data_p,
                             is_stored, value) =
  let
    fn {}
    get_result {node_p        : addr}
               {bits_source_p : addr}
               {index_data_p  : addr}
               {vt            : vtype}
               {hash_vt       : vt@ype}
               (node_p        : ptr node_p,
                bits_source_p : ptr bits_source_p,
                index_data_p  : ptr index_data_p,
                is_stored     : &bool? >> bool is_stored,
                value         : &uintptr? >>
                                    [u : int | is_stored || u == 0]
                                    uintptr u) :
        #[is_stored : bool] void =
      {
        (* Create linear types from the pointers. *)
        val node = $UN.castvwtp0{node_vt} node_p
        val bits_source =
          $UN.castvwtp0 {bits_source_cloptr (hash_vt, NUM_BITS)}
                         bits_source_p
        val index_data =
          $UN.castvwtp0 {@(hash_vt @ index_data_p | ptr index_data_p)}
                        index_data_p

        (* Search in the tree. *)
        prval _ = lemma_node_vt_param node
        val () =
          get_subtree_entry<vt><hash_vt> (node, bits_source,
                                          !(index_data.1), 0U,
                                          is_stored, value)

        (* Consume the linear types. *)
        prval _ = $UN.castvwtp0{Ptr} node
        prval _ = $UN.castvwtp0{Ptr} bits_source
        prval _ = $UN.castvwtp0{Ptr} index_data
      }
  in
    get_result<> {node_p} {bits_source_p} {index_data_p}
                 (node_p, bits_source_p, index_data_p,
                 is_stored, value)
  end
