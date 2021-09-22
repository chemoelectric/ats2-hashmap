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

#include "hashmap/HATS/bits-source-include.hats"

staload "hashmap/SATS/uintptr-set.sats"
staload "hashmap/SATS/array-mapped-tree.sats"
staload "hashmap/SATS/bits-source.sats"

staload "hashmap/SATS/atomic.sats"
staload "hashmap/SATS/spinlock.sats"
staload "hashmap/SATS/initialize-once.sats"
staload _ = "hashmap/DATS/atomic.dats"
staload _ = "hashmap/DATS/spinlock.dats"
staload _ = "hashmap/DATS/initialize-once.dats"

%{#
#include "hashmap/CATS/uintptr-set-implementation.cats"
%}

typedef key_test_t (key_t : t@ype) =
  (&key_t, uintptr) -<cloref1> bool

extern fun
uintptr_set_key_test () : key_test_t (uintptr) = "mac#%"

datavtype set_vt (size : int) =
| set_vt_nil (0) of ()
| {n : int | 1 <= n}
  {node_p : addr}
  set_vt_tree (n) of
    (size_t n,
     array_mapped_tree_vt node_p)

assume uintptr_set_vt (size) = set_vt (size)

local
  var init = initialize_once_nil ()
  var storage : ptr
in
  fn
  make_closure (storage : &ptr? >> ptr) : void =
    {
      val key_test =
        lam (key_data : &uintptr, entry : uintptr) : bool =<cloptr1>
          key_data = entry
      val _ = storage := $UNSAFE.castvwtp0{ptr} key_test
    }

  extern fun
  ats2_hashmap_uintptr_set_key_test_cloref_p () : ptr = "ext#"

  implement
  ats2_hashmap_uintptr_set_key_test_cloref_p () =
    initialize_once<ptr> (addr@ init, addr@ storage, make_closure)
end

implement {}
uintptr_set () = set_vt_nil ()

implement
uintptr_set_free (set) =
  case+ set of
  | ~ set_vt_nil () => ()
  | ~ set_vt_tree (_, tree) =>
    array_mapped_tree_free ($UNSAFE.cast{Ptr} tree,
                            the_null_ptr)

implement {}
uintptr_set_size (set) =
  case+ set of
  | set_vt_nil () => i2sz 0
  | set_vt_tree (size, _) => size

implement {}
uintptr_set_is_empty (set) =
  case+ set of
  | set_vt_nil () => true
  | set_vt_tree _ => false

implement {}
uintptr_set_isnot_empty (set) =
  case+ set of
  | set_vt_nil () => false
  | set_vt_tree _ => true

implement
uintptr_set_add_element (set, element) =
  case+ set of
  | ~ set_vt_nil () =>
    let
      val bits_source = bits_source_uintptr ()
      val bits_source_p = $UNSAFE.cast{Ptr} bits_source

      var hash_data = element
      val hash_data_p = addr@ hash_data

      val tree =
        array_mapped_tree_create (bits_source_p, hash_data_p, element)
    in
      set_vt_tree (i2sz 1, tree)
    end
  | ~ set_vt_tree (size, tree) =>
    let
    in
      // FIXME: At the moment, this does not add anything to the tree.
      set_vt_tree (size, tree) // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME
    end

implement
uintptr_set_remove_element (set, element) =
  case+ set of
  | set_vt_nil () => set
  | set_vt_tree (size, tree) =>
    set // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME

implement
uintptr_set_has_element (set, element) =
  case+ set of
  | set_vt_nil () => false
  | set_vt_tree (_, tree) =>
    let
      val node_p = $UNSAFE.cast{Ptr} tree

      val bits_source = bits_source_uintptr ()
      val bits_source_p = $UNSAFE.cast{Ptr} bits_source

      var hash_data = element
      val hash_data_p = addr@ hash_data

      val key_test = uintptr_set_key_test ()
      val key_test_p = $UNSAFE.castvwtp1{Ptr} key_test

      var key_data = element
      val key_data_p = addr@ key_data

      var is_stored : bool
      var value : uintptr

      val _ =
        array_mapped_tree_get_entry
          (node_p, bits_source_p, hash_data_p,
           key_test_p, key_data_p, is_stored, value)
    in
      is_stored
    end
