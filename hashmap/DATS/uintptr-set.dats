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

extern fun
uintptr_set_hash_func () :
    (uintptr, &uintptr? >> uintptr) -<cloref> void = "mac#%"

extern fun
uintptr_set_key_test () :
    (uintptr, uintptr) -<cloref1> bool = "mac#%"

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
      val hash_func =
        lam (key  : uintptr,
             hash : &uintptr? >> uintptr) : void =<cloptr1>
          hash := key
      val _ = storage := $UNSAFE.castvwtp0{ptr} hash_func
    }

  extern fun
  ats2_hashmap_uintptr_set_hash_func_cloref_p () : ptr = "ext#"

  implement
  ats2_hashmap_uintptr_set_hash_func_cloref_p () =
    initialize_once<ptr> (addr@ init, addr@ storage, make_closure)
end

local
  var init = initialize_once_nil ()
  var storage : ptr
in
  fn
  make_closure (storage : &ptr? >> ptr) : void =
    {
      val key_test =
        lam (key   : uintptr,
             entry : uintptr) : bool =<cloptr1>
          key = entry
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
  let
    val bits_source = bits_source_uintptr ()
    val bits_source_p = $UNSAFE.castvwtp0{ptr} bits_source

    val hash_func = uintptr_set_hash_func ()
    val hash_func_p = $UNSAFE.castvwtp0{ptr} hash_func

    var hash_storage1 : uintptr
    val hash_storage1_p = addr@ hash_storage1
  in
    case+ set of
    | ~ set_vt_nil () =>
      let
        val tree =
          array_mapped_tree_create
            (bits_source_p, hash_func_p, hash_storage1_p, element)
      in
        set_vt_tree (i2sz 1, tree)
      end
    | ~ set_vt_tree (size, tree) =>
      let
        var node_p_ref = $UNSAFE.castvwtp0{Ptr} tree

        var hash_storage2 : uintptr
        val hash_storage2_p = addr@ hash_storage2

        val key_test = uintptr_set_key_test ()
        val key_test_p = $UNSAFE.castvwtp1{ptr} key_test

        var is_new_slot : bool

        val () =
          array_mapped_tree_set_entry
            (node_p_ref, bits_source_p, hash_func_p,
             hash_storage1_p, hash_storage2_p,
             key_test_p, element, is_new_slot)

        (* Dereference the result. *)
        val node_p = node_p_ref
      in
        if is_new_slot then
          set_vt_tree (succ size, $UNSAFE.castvwtp0 node_p)
        else
          set_vt_tree (size, $UNSAFE.castvwtp0 node_p)
      end
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
      val node_p = $UNSAFE.cast{ptr} tree

      val bits_source = bits_source_uintptr ()
      val bits_source_p = $UNSAFE.cast{ptr} bits_source

      val hash_func = uintptr_set_hash_func ()
      val hash_func_p = $UNSAFE.castvwtp0{ptr} hash_func

      var hash_storage : uintptr
      val hash_storage_p = addr@ hash_storage

      val key_test = uintptr_set_key_test ()
      val key_test_p = $UNSAFE.castvwtp1{ptr} key_test

      var is_stored : bool
      var key_value : uintptr

      val _ =
        array_mapped_tree_get_entry
          (node_p, bits_source_p, hash_func_p, hash_storage_p,
           key_test_p, element, is_stored, key_value)
    in
      is_stored
    end

implement
uintptr_set_print_structure (out, set, print_key_value) =
  case+ set of
  | set_vt_nil () => fprintln! (out, "size: 0")
  | @set_vt_tree (size, tree) =>
    {
      val _ = fprintln! (out, "size: ", size);
      val _ =
        array_mapped_tree_print_structure
          (out, $UNSAFE.cast{ptr} tree, print_key_value)
      prval _ = fold@ set
    }
