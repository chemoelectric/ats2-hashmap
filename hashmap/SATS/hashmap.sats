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

absvtype hashmap_vt (key_vt   : vt@ype+,
                     value_vt : vt@ype+,
                     size     : int)
vtypedef hashmap_vt (key_vt   : vt@ype+,
                     value_vt : vt@ype+) =
  [size : int] hashmap_vt (key_vt, value_vt, size)
vtypedef hashmap_vt (size : int) =
  [key_vt, value_vt : vt@ype]
  hashmap_vt (key_vt, value_vt, size)
vtypedef hashmap_vt (key_vt : vt@ype, value_vt : vt@ype) =
  [size : int]
  hashmap_vt (key_vt, value_vt, size)
vtypedef hashmap_vt =
  [key_vt, value_vt : vt@ype]
  [size : int]
  hashmap_vt (key_vt, value_vt, size)

prfn
lemma_hashmap_vt_param :
  {size : int}
  (!hashmap_vt (size) >> _) -<prf> [0 <= size] void

(********************************************************************)

(* The hash value is accessed by reference, so that (for example) the
   hash value can be an array. See also hashmap$hash_vt_free. *)
fun {hash_vt : vt@ype}
    {key_vt  : vt@ype}
hashmap$hash_function : (!key_vt >> _, &hash_vt? >> hash_vt) -> void
fun {hash_vt : vt@ype}
hashmap$hash_vt_free : (&hash_vt >> hash_vt?) -> void

(* A function that returns bits from a hash. *)
fun {hash_vt : vt@ype}
hashmap$bits_source : bits_source_vt (hash_vt)

fun {key_vt : vt@ype}
hashmap$key_vt_free : key_vt -> void
fun {value_vt : vt@ype}
hashmap$value_vt_free : value_vt -> void

(* Keys and values need to be copied sometimes. *)
fun {key_vt : vt@ype}
hashmap$key_vt_copy : (!key_vt >> _) -> key_vt
fun {value_vt : vt@ype}
hashmap$value_vt_copy : (!value_vt >> _) -> value_vt

(* Keys, of course, have to be tested for equality. *)
fun {key_vt : vt@ype}
hashmap$key_vt_eq (key_arg    : !key_vt >> _,
                   key_stored : !key_vt >> _) : bool

(********************************************************************)

fun {}
hashmap {key_vt, value_vt : vt@ype}
        () :
    hashmap_vt (key_vt, value_vt, 0)

fun {}
hashmap_size
        {size : int}
        {key_vt, value_vt : vt@ype}
        (map  : !hashmap_vt (key_vt, value_vt, size) >> _) :
    size_t size
overload size with hashmap_size of 0

fun {}
hashmap_is_empty
        {size : int}
        {key_vt, value_vt : vt@ype}
        (map  : !hashmap_vt (key_vt, value_vt, size) >> _) :
    bool (size == 0)
overload iseqz with hashmap_is_empty of 0

fun {}
hashmap_isnot_empty
        {size : int}
        {key_vt, value_vt : vt@ype}
        (map  : !hashmap_vt (key_vt, value_vt, size) >> _) :
    bool (size != 0)
overload isneqz with hashmap_isnot_empty of 0

fun {hash_vt : vt@ype}
    {key_vt, value_vt : vt@ype}
hashmap_set
        {size  : int}
        (map   : hashmap_vt (key_vt, value_vt, size),
         key   : key_vt,
         value : value_vt) :
    [new_size : int | new_size == size || new_size == size + 1]
    hashmap_vt (key_vt, value_vt, new_size)

fun {hash_vt : vt@ype}
    {key_vt, value_vt : vt@ype}
hashmap_del
        {size : int}
        (map  : hashmap_vt (key_vt, value_vt, size),
         key  : !key_vt >> _) :
    [new_size : int | new_size == size || new_size == size - 1]
    hashmap_vt (key_vt, value_vt, new_size)

fun {hash_vt : vt@ype}
    {key_vt, value_vt : vt@ype}
hashmap_get_opt
        {size : int}
        (map  : !hashmap_vt (key_vt, value_vt, size) >> _,
         key  : !key_vt >> _) :
    Option_vt (value_vt)

fun {key_vt, value_vt : vt@ype}
hashmap_pairs
        {size : int}
        (map  : !hashmap_vt (key_vt, value_vt, size) >> _) :
    list_vt (@(key_vt, value_vt), size)

fun {key_vt, value_vt : vt@ype}
hashmap_keys
        {size     : int}
        (map      : !hashmap_vt (key_vt, value_vt, size) >> _) :
    list_vt (key_vt, size)

fun {key_vt, value_vt : vt@ype}
hashmap_values
        {size   : int}
        (map    : !hashmap_vt (key_vt, value_vt, size) >> _) :
    list_vt (value_vt, size)

fun {key_vt, value_vt : vt@ype}
hashmap_free {size : int}
             (map  : hashmap_vt (key_vt, value_vt, size)) : void

(********************************************************************)
