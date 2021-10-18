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

staload "hashmap/SATS/bits_source.sats"

(********************************************************************)

absvtype hashmap_vt (key_vt   : vtype+,
                     value_vt : vtype+,
                     size     : int)
vtypedef hashmap_vt (key_vt   : vtype+,
                     value_vt : vtype+) =
  [size : int] hashmap_vt (key_vt, value_vt, size)
vtypedef hashmap_vt (size : int) =
  [key_vt, value_vt : vtype]
  hashmap_vt (key_vt, value_vt, size)
vtypedef hashmap_vt (key_vt : vtype, value_vt : vtype) =
  [size : int]
  hashmap_vt (key_vt, value_vt, size)
vtypedef hashmap_vt =
  [key_vt, value_vt : vtype]
  [size : int]
  hashmap_vt (key_vt, value_vt, size)

prfn
lemma_hashmap_vt_param :
  {size : int}
  (!hashmap_vt (size) >> _) -<prf> [0 <= size] void

(********************************************************************)

(* The hash function sets the hash value by reference, so that (for
   example) a C function can be used without the need for structure
   return, which has poorly regulated ABI; so the hash can be an
   array; and so on. See also hashmap$hash_vt_free. *)
fun {hash_vt : vt@ype}
    {key_vt  : vtype}
hashmap$hash_function : (!key_vt >> _, &hash_vt? >> hash_vt) -> void

(* This interface for the hash-free function is designed not to
   require passing a structure by value. See also
   hashmap$hash_function. *)
fun {hash_vt : vt@ype}
hashmap$hash_vt_free : (&hash_vt >> hash_vt?!) -> void

(* A function that returns bits from a hash. *)
fun {hash_vt : vt@ype}
hashmap$bits_source : bits_source_vt (hash_vt)

(* Key and value are assumed to be types that get translated to
   C pointers. They can be passed in the straightforward way. *)
fun {key_vt : vtype}
hashmap$key_vt_free : key_vt -> void
fun {value_vt : vtype}
hashmap$value_vt_free : value_vt -> void

fun {key_vt : vtype}
hashmap$key_eq (key_arg    : !key_vt >> _,
                key_stored : !key_vt >> _) : bool

(********************************************************************)

fun {}
hashmap () : hashmap_vt (0)

fun {hash_vt : vt@ype}
    {key_vt, value_vt : vtype}
hashmap_include
        {size  : int}
        (map   : hashmap_vt (key_vt, value_vt, size),
         key   : !key_vt >> _,
         value : !value_vt >> _) :
    [new_size : int | new_size == size || new_size == size + 1]
    hashmap_vt (key_vt, value_vt, new_size)
overload + with hashmap_include of 0

fun {hash_vt : vt@ype}
    {key_vt, value_vt : vtype}
hashmap_remove
        {size : int}
        (map  : hashmap_vt (key_vt, value_vt, size),
         key  : !key_vt >> _) :
    #[new_size : int | new_size == size || new_size == size - 1]
    hashmap_vt (key_vt, value_vt, new_size)
overload - with hashmap_remove of 0

fun {hash_vt : vt@ype}
    {key_vt, value_vt : vtype}
hashmap_find
        {size : int}
        (map  : !hashmap_vt (key_vt, value_vt, size) >> _,
         key  : !key_vt >> _) :
    Option_vt (value_vt)
overload [] with hashmap_find of 0

fun {key_vt, value_vt : vtype}
hashmap_pairs
        {size : int}
        (map  : !hashmap_vt (key_vt, value_vt, size) >> _) :
    list_vt (@(key_vt, value_vt), size)

fun {key_vt : vtype}
hashmap_keys
        {size     : int}
        {value_vt : vtype}
        (map      : !hashmap_vt (key_vt, value_vt, size) >> _) :
    list_vt (key_vt, size)

fun {value_vt : vtype}
hashmap_values
        {size   : int}
        {key_vt : vtype}
        (map    : !hashmap_vt (key_vt, value_vt, size) >> _) :
    list_vt (value_vt, size)

fun {}
hashmap_free (map : hashmap_vt) : void
overload free with hashmap_free of 0

(********************************************************************)
