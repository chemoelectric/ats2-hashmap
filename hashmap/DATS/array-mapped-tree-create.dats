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
staload _ = "hashmap/DATS/uptr.dats"

implement
array_mapped_tree_create (bits_source_p, hash_func_p,
                          hash_storage_p, key_value) =
  let
    fn {}
    make_node {bits_source_p  : addr}
              {hash_func_p    : addr}
              {hash_storage_p : addr}
              {key_value      : int}
              {hash_vt        : vt@ype}
              (bits_source_p  : ptr bits_source_p,
               hash_func_p    : ptr hash_func_p,
               hash_storage_p : ptr hash_storage_p,
               key_value      : uintptr key_value) :
        [node_p : addr]
        ptr node_p =
      let
        (* Create linear types from the pointers. *)
        val bits_source =
          $UN.castvwtp0 {bits_source_cloptr (hash_vt, NUM_BITS)}
                        bits_source_p
        val hash_func =
          $UN.castvwtp0 {hash_function_vt (hash_vt)} hash_func_p
        val hash_storage =
          $UN.castvwtp0 {@(hash_vt? @ hash_storage_p |
                           ptr hash_storage_p)}
                         hash_storage_p

        (* Create the tree. *)
        val node = start_new_tree<hash_vt> (bits_source, hash_func,
                                            !(hash_storage.1),
                                            key_value)

        (* Consume the linear types. *)
        prval _ = $UN.castvwtp0{void} bits_source
        prval _ = $UN.castvwtp0{void} hash_func
        prval _ = $UN.castvwtp0{void} hash_storage
      in
        uptr2ptr (node2uptr node)
      end
  in
    make_node<> (g1ofg0 bits_source_p,
                 g1ofg0 hash_func_p,
                 g1ofg0 hash_storage_p,
                 g1ofg0 key_value)
  end
