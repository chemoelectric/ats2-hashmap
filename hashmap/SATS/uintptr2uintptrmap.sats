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

(********************************************************************)
(*                                                                  *)
(* Maps from uintptr to uintptr                                     *)
(*                                                                  *)
(* These are useful for making maps in C, because uintptr           *)
(* can represent all C pointers and most integer values.            *)
(*                                                                  *)
(********************************************************************)

#define ATS_PACKNAME "ats2-hashmap"
#define ATS_EXTERN_PREFIX "ats2_hashmap_"

staload "hashmap/SATS/hashmap.sats"
staload "hashmap/SATS/bits_source.sats"

(********************************************************************)

vtypedef uintptr2uintptrmap_vt (size : int) =
  hashmap_vt (uintptr, uintptr, size)
vtypedef strnptr2uintptrmap_vt =
  [size : int]
  uintptr2uintptrmap_vt (size)

prfun
lemma_uintptr2uintptrmap_vt_param :
  {size : int}
  (!uintptr2uintptrmap_vt (size) >> _) -<prf>
    [0 <= size] void

(********************************************************************)

(*
  The hash is assumed to be anything up to 64 bytes long --
  "unsafely" accessed, probably by C code.
   
  The following says that the type is unspecified, except
  insofar as it needs as much space as does a 64-tuple of bytes.
  Thus hashmap routines will allocate that much space for hashes
  it generates.

  (Using an array instead of a tuple to specify the 64-byte size
  would run into difficulties with the ATS2 implementation.)
*)
abst@ype uintptr2uintptrmap_hash_t =
  @(byte, byte, byte, byte, byte, byte, byte, byte,
    byte, byte, byte, byte, byte, byte, byte, byte,
    byte, byte, byte, byte, byte, byte, byte, byte,
    byte, byte, byte, byte, byte, byte, byte, byte,
    byte, byte, byte, byte, byte, byte, byte, byte,
    byte, byte, byte, byte, byte, byte, byte, byte,
    byte, byte, byte, byte, byte, byte, byte, byte,
    byte, byte, byte, byte, byte, byte, byte, byte)

vtypedef uintptr2uintptrmap_bits_source_vt =
  bits_source_vt (uintptr2uintptrmap_hash_t)

typedef uintptr2uintptrmap_hash_function_t =
  (* The "ptr" argument is for "closure" environment. *)
  (uintptr,
   &uintptr2uintptrmap_hash_t? >> uintptr2uintptrmap_hash_t,
   ptr) -> void

typedef uintptr2uintptrmap_hash_free_t =
  (* The "ptr" argument is for "closure" environment. *)
  (&uintptr2uintptrmap_hash_t >> uintptr2uintptrmap_hash_t?,
   ptr) -> void

typedef uintptr2uintptrmap_uintptr_free_t =
  (* The "ptr" argument is for "closure" environment. *)
  (uintptr, ptr) -> void

typedef uintptr2uintptrmap_uintptr_copy_t =
  (* The "ptr" argument is for "closure" environment. *)
  (uintptr, ptr) -> uintptr

typedef uintptr2uintptrmap_key_eq_t =
  (* The "ptr" argument is for "closure" environment. *)
  (uintptr, uintptr, ptr) -> bool

(********************************************************************)

fun {}
uintptr2uintptrmap () :
  uintptr2uintptrmap_vt (0)

fun
uintptr2uintptrmap_size
        {size : int}
        (map  : !uintptr2uintptrmap_vt (size) >> _) :
    size_t size

fun {}
uintptr2uintptrmap_is_empty
        {size : int}
        (map  : !uintptr2uintptrmap_vt (size) >> _) :
    bool (size == 0)

fun {}
uintptr2uintptrmap_isnot_empty
        {size : int}
        (map  : !uintptr2uintptrmap_vt (size) >> _) :
    bool (size != 0)

fun
uintptr2uintptrmap_set
        {size          : int}
        (map           : uintptr2uintptrmap_vt (size),
         key           : uintptr,
         value         : uintptr,
         bits_source   : uintptr2uintptrmap_bits_source_vt,
         hash_function : uintptr2uintptrmap_hash_function_t,
         hash_free     : uintptr2uintptrmap_hash_free_t,
         key_free      : uintptr2uintptrmap_uintptr_free_t,
         value_free    : uintptr2uintptrmap_uintptr_free_t,
         key_eq        : uintptr2uintptrmap_key_eq_t,
         environment   : ptr) :
    [new_size : int | new_size == size || new_size == size + 1]
    uintptr2uintptrmap_vt (new_size)

(*
fun
uintptr2uintptrmap_del
        {size        : int}
        (map         : uintptr2uintptrmap_vt (size),
         key         : uintptr,
         key_free    : uintptr2uintptrmap_uintptr_free_t,
         value_free  : uintptr2uintptrmap_uintptr_free_t,
         environment : ptr) :
    [new_size : int | new_size == size || new_size == size - 1]
    uintptr2uintptrmap_vt (new_size)

fun
uintptr2uintptrmap_get_opt
        {size        : int}
        (map         : !RD(uintptr2uintptrmap_vt (size)) >> _,
         key         : uintptr,
         value_copy  : uintptr2uintptrmap_uintptr_copy_t,
         environment : ptr) :
    Option_vt (uintptr)

fun
uintptr2uintptrmap_get
  (* Sets "value" to zero if "has_key" is false. *)
        {size        : int}
        (map         : !RD(uintptr2uintptrmap_vt (size)) >> _,
         key         : uintptr,
         value_copy  : uintptr2uintptrmap_uintptr_copy_t,
         environment : ptr,
         has_key     : &bool? -> bool,
         value       : &uintptr? -> uintptr) :
    void

fun
uintptr2uintptrmap_has_key
        {size : int}
        (map  : !RD(uintptr2uintptrmap_vt (size)) >> _,
         key  : uintptr) :
    bool

fun
uintptr2uintptrmap_pairs
        {size        : int}
        (map         : !RD(uintptr2uintptrmap_vt (size)) >> _,
         key_copy    : uintptr2uintptrmap_uintptr_copy_t,
         value_copy  : uintptr2uintptrmap_uintptr_copy_t,
         environment : ptr) :
    list_vt (@(uintptr, uintptr), size)

fun
uintptr2uintptrmap_pairs_free
        {size        : int}
        (pairs       : list_vt (@(uintptr, uintptr), size),
         key_free    : uintptr2uintptrmap_uintptr_free_t,
         value_free  : uintptr2uintptrmap_uintptr_free_t,
         environment : ptr) :
    void

fun
uintptr2uintptrmap_keys
        {size        : int}
        (map         : !RD(uintptr2uintptrmap_vt (size)) >> _,
         key_copy    : uintptr2uintptrmap_uintptr_copy_t,
         environment : ptr) :
    list_vt (uintptr, size)

fun
uintptr2uintptrmap_keys_free
        {size        : int}
        (keys        : list_vt (uintptr, size),
         key_free    : uintptr2uintptrmap_uintptr_free_t,
         environment : ptr) :
    void

fun
uintptr2uintptrmap_values
        {size        : int}
        (map         : !RD(uintptr2uintptrmap_vt (size)) >> _,
         value_copy  : uintptr2uintptrmap_uintptr_copy_t,
         environment : ptr) :
    list_vt (uintptr, size)

fun
uintptr2uintptrmap_values_free
        {size        : int}
        (values      : list_vt (uintptr, size),
         value_free  : uintptr2uintptrmap_uintptr_free_t,
         environment : ptr) :
    void

fun
uintptr2uintptrmap_free
        {size        : int}
        (map         : uintptr2uintptrmap_vt (size),
         key_free    : uintptr2uintptrmap_uintptr_free_t,
         value_free  : uintptr2uintptrmap_uintptr_free_t,
         environment : ptr) :
    void
*)

(********************************************************************)
