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
  [size : int]
  hashmap_vt (key_vt, value_vt, size)

prfun
lemma_hashmap_vt_param :
  {key_vt, value_vt : vt@ype}
  {size : int}
  (!hashmap_vt (key_vt, value_vt, size) >> _) -<prf>
    [0 <= size] void

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

(* Start a new hashmap. (In the C code, this will be
   a NULL pointer. *)
fun {}
hashmap {key_vt, value_vt : vt@ype}
        () :
    hashmap_vt (key_vt, value_vt, 0)

(* Return the number of elements in a hashmap. *)
fun {}
hashmap_size
        {size : int}
        {key_vt, value_vt : vt@ype}
        (map  : !RD(hashmap_vt (key_vt, value_vt, size)) >> _) :
    size_t size
overload size with hashmap_size of 0

(* Is a hashmap's size equal to zero? *)
fun {}
hashmap_is_empty
        {size : int}
        {key_vt, value_vt : vt@ype}
        (map  : !RD(hashmap_vt (key_vt, value_vt, size)) >> _) :
    bool (size == 0)
overload iseqz with hashmap_is_empty of 0

(* Is a hashmap's size not equal to zero? *)
fun {}
hashmap_isnot_empty
        {size : int}
        {key_vt, value_vt : vt@ype}
        (map  : !RD(hashmap_vt (key_vt, value_vt, size)) >> _) :
    bool (size != 0)
overload isneqz with hashmap_isnot_empty of 0

(* Set the value corresponding to a given a key. This action
   either installs a new key-value pair (increasing the hashmap's
   size by one) or replaces a key-value pair (leaving the hashmap's
   size unchanged). *)
fun {hash_vt : vt@ype}
    {key_vt, value_vt : vt@ype}
hashmap_set
        {size  : int}
        (map   : hashmap_vt (key_vt, value_vt, size),
         key   : key_vt,
         value : value_vt) :
    [new_size : int | new_size == size || new_size == size + 1]
    hashmap_vt (key_vt, value_vt, new_size)

(* If the given key is present in the hashmap, remove the
   corresponding key-value pair (reducing the hashmap's size
   by one). If the key is not present, return a hashmap equivalent
   to the original (not necessarily the same memory blocks). *)
fun {hash_vt : vt@ype}
    {key_vt, value_vt : vt@ype}
hashmap_del
        {size : int}
        (map  : hashmap_vt (key_vt, value_vt, size),
         key  : !RD(key_vt) >> _) :
    [new_size : int | new_size == size || new_size == size - 1]
    hashmap_vt (key_vt, value_vt, new_size)

(* Return Some_vt(value) (where "value" is a COPY of the stored
   value), if the given key is in the hashmap. Otherwise return
   None_vt(). *)
fun {hash_vt : vt@ype}
    {key_vt, value_vt : vt@ype}
hashmap_get_opt
        {size : int}
        (map  : !RD(hashmap_vt (key_vt, value_vt, size)) >> _,
         key  : !RD(key_vt) >> _) :
    Option_vt (value_vt)

(* Is the given key present in the hashmap? *)
fun {hash_vt : vt@ype}
    {key_vt, value_vt : vt@ype}
hashmap_has_key
        {size : int}
        (map  : !RD(hashmap_vt (key_vt, value_vt, size)) >> _,
         key  : !RD(key_vt) >> _) :
    bool

(* Return a list of COPIES of the key-value pairs stored in the
   hashmap. The order in which the pairs are returned is
   unspecified. *)
fun {key_vt, value_vt : vt@ype}
hashmap_pairs
        {size : int}
        (map  : !RD(hashmap_vt (key_vt, value_vt, size)) >> _) :
    list_vt (@(key_vt, value_vt), size)

(* Return a list of COPIES of the keys stored in the
   hashmap. The order in which the keys are returned is
   unspecified. *)
fun {key_vt, value_vt : vt@ype}
hashmap_keys
        {size     : int}
        (map      : !RD(hashmap_vt (key_vt, value_vt, size)) >> _) :
    list_vt (key_vt, size)

(* Return a list of COPIES of the values stored in the
   hashmap. The order in which the values are returned is
   unspecified. *)
fun {key_vt, value_vt : vt@ype}
hashmap_values
        {size   : int}
        (map    : !RD(hashmap_vt (key_vt, value_vt, size)) >> _) :
    list_vt (value_vt, size)

(* Free a hashmap. Every hashmap must be freed. *)
fun {key_vt, value_vt : vt@ype}
hashmap_free
        {size : int}
        (map  : hashmap_vt (key_vt, value_vt, size)) :
    void

(* Print the structure of a given hashmap. The key_fprint and
   and value_fprint closures are called to print keys and values,
   respectively. *)
fun {key_vt, value_vt : vt@ype}
hashmap_fprint
        {size         : int}
        (f            : FILEref,
         map          : !RD(hashmap_vt (key_vt, value_vt, size)) >> _,
         key_fprint   : !((FILEref, !key_vt >> _)
                            -<cloptr1> void) >> _,
         value_fprint : !((FILEref, !value_vt >> _)
                            -<cloptr1> void) >> _) :
    void

(********************************************************************)
