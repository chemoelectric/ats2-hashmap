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
#include "share/atspre_staload.hats"

staload UN = "prelude/SATS/unsafe.sats"

staload "hashmap/SATS/array-mapped-tree.sats"
staload "hashmap/SATS/array-mapped-tree-templates.sats"
staload "hashmap/SATS/bits-source.sats"
staload "hashmap/SATS/uptr.sats"

staload _ = "hashmap/DATS/array-mapped-tree-templates.dats"
staload _ = "hashmap/DATS/count-one-bits.dats"
staload _ = "hashmap/DATS/uptr.dats"

implement
array_mapped_tree_get_entry (node_p, bits_source_p,
                             hash_func_p, hash_storage_p,
                             key_test_p, key,
                             is_stored, key_value) =
  {
    fn {}
    get_result {node_p         : addr}
               {bits_source_p  : addr}
               {hash_func_p    : addr}
               {hash_storage_p : addr}
               {key_test_p     : addr}
               {key            : int}
               {hash_vt        : vt@ype}
               (node_p         : ptr node_p,
                bits_source_p  : ptr bits_source_p,
                hash_func_p    : ptr hash_func_p,
                hash_storage_p : ptr hash_storage_p,
                key_test_p     : ptr key_test_p,
                key            : uintptr key,
                is_stored      : &bool? >> bool is_stored,
                key_value      : &uintptr? >> uintptr key_value) :
        #[is_stored : bool]
        #[key_value : int | is_stored || key_value == 0]
        void =
      {
        (* Create linear types from the pointers. *)
        val node : node_vt node_p =
          uptr2node {node_p} (ptr2uptr {node_p} node_p)
        val bits_source =
          $UN.castvwtp0 {bits_source_cloptr (hash_vt, NUM_BITS)}
                         bits_source_p
        val hash_func =
          $UN.castvwtp0 {hash_function_vt (hash_vt)} hash_func_p
        val hash_storage =
          $UN.castvwtp0 {@(hash_vt? @ hash_storage_p |
                           ptr hash_storage_p)}
                        hash_storage_p
        val key_test = $UN.castvwtp0 {key_test_vt} key_test_p

        (* Search in the tree. *)
        prval _ = lemma_node_vt_param node
        val () =
          get_subtree_entry<hash_vt>
            (node, bits_source, hash_func, !(hash_storage.1),
             key_test, key, 0U, is_stored, key_value)

        (* Consume the linear types. *)
        prval _ = $UN.castvwtp0{void} node
        prval _ = $UN.castvwtp0{void} bits_source
        prval _ = $UN.castvwtp0{void} hash_func
        prval _ = $UN.castvwtp0{void} hash_storage
        prval _ = $UN.castvwtp0{void} key_test
      }

    val _ =
      get_result<> (g1ofg0 node_p,
                    g1ofg0 bits_source_p,
                    g1ofg0 hash_func_p,
                    g1ofg0 hash_storage_p,
                    g1ofg0 key_test_p,
                    g1ofg0 key,
                    is_stored, key_value)
  }
