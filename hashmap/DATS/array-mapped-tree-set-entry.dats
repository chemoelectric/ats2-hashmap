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
staload "hashmap/SATS/uptr.sats"

staload _ = "hashmap/DATS/array-mapped-tree-templates.dats"
staload _ = "hashmap/DATS/count-one-bits.dats"
staload _ = "hashmap/DATS/memory.dats"
staload _ = "hashmap/DATS/uptr.dats"

implement
array_mapped_tree_set_entry (node_p_ref, bits_source_p, hash_func_p,
                             hash_storage1_p, hash_storage2_p,
                             key_test_p, key_value, is_new_slot) =
  let
    fn {}
    set_entry {node_p          : addr}
              {bits_source_p   : addr}
              {hash_func_p     : addr}
              {hash_storage1_p : addr}
              {hash_storage2_p : addr}
              {key_test_p      : addr}
              {key_value       : int}
              {hash_vt         : vt@ype}
              (node_p_ref      : &(ptr node_p) >> Ptr,
               bits_source_p   : ptr bits_source_p,
               hash_func_p     : ptr hash_func_p,
               hash_storage1_p : ptr hash_storage1_p,
               hash_storage2_p : ptr hash_storage2_p,
               key_test_p      : ptr key_test_p,
               key_value       : uintptr key_value,
               is_new_slot     : &bool? >> Bool) : void =
      {
        (* Convert the !node_p_ref pointer to a node object
           in a variable. *)
        val node_p = node_p_ref (* Dereference. *)
        var node : node_vt node_p = uptr2node (ptr2uptr node_p)

        (* Create linear types from pointers. *)
        val bits_source =
          $UN.castvwtp0 {bits_source_cloptr (hash_vt, NUM_BITS)}
                         bits_source_p
        val hash_func =
          $UN.castvwtp0 {hash_function_vt (hash_vt)} hash_func_p
        val hash_storage1 =
          $UN.castvwtp0 {@(hash_vt? @ hash_storage1_p |
                           ptr hash_storage1_p)}
                        hash_storage1_p
        val hash_storage2 =
          $UN.castvwtp0 {@(hash_vt? @ hash_storage2_p |
                           ptr hash_storage2_p)}
                        hash_storage2_p
        val key_test = $UN.castvwtp0 {key_test_vt} key_test_p

        (* Update the tree, setting a new value of node, and also
           setting the value of is_new_slot. *)
        prval _ = lemma_node_vt_param node
        val _ =
          set_subtree_entry<hash_vt>
            (node, bits_source, hash_func,
             !(hash_storage1.1), !(hash_storage2.1),
             key_test, key_value, 0U, is_new_slot)

        (* Convert the !node object to a pointer. *)
        val node_val = node     (* Dereference. *)
        val _ = node_p_ref := uptr2ptr (node2uptr node_val)

        (* Consume linear types. *)
        prval _ = $UN.castvwtp0{void} bits_source
        prval _ = $UN.castvwtp0{void} hash_func
        prval _ = $UN.castvwtp0{void} hash_storage1
        prval _ = $UN.castvwtp0{void} hash_storage2
        prval _ = $UN.castvwtp0{void} key_test
      }
  in
    set_entry<> (node_p_ref,
                 g1ofg0 bits_source_p,
                 g1ofg0 hash_func_p,
                 g1ofg0 hash_storage1_p,
                 g1ofg0 hash_storage2_p,
                 g1ofg0 key_test_p,
                 g1ofg0 key_value,
                 is_new_slot)
  end
