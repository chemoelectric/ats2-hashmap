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

implement
array_mapped_tree_create {bits_source_p} {hash_data_p}
                         (bits_source_p, hash_data_p, value) =
  let
    fn {}
    make_node {bits_source_p : addr}
              {hash_data_p   : addr}
              {hash_vt       : vt@ype}
              (bits_source_p : ptr bits_source_p,
               hash_data_p   : ptr hash_data_p,
               value         : uintptr) :
        [node_p : addr | null < node_p]
        ptr node_p =
      let
        (* Create linear types from the pointers. *)
        val bits_source =
          $UN.castvwtp0 {bits_source_cloptr (hash_vt, NUM_BITS)}
                         bits_source_p
        val hash_data =
          $UN.castvwtp0 {@(hash_vt @ hash_data_p | ptr hash_data_p)}
                        hash_data_p

        val node = start_new_tree (bits_source, !(hash_data.1), value)

        (* Consume the linear types. *)
        prval _ = $UN.castvwtp0{Ptr} bits_source
        prval _ = $UN.castvwtp0{Ptr} hash_data
      in
        $UN.castvwtp0 node
      end
  in
    make_node<> {bits_source_p} {hash_data_p} {..}
                (bits_source_p, hash_data_p, value)
  end
