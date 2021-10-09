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

(* FIXME: Put this comment in a more suitable place.

Quoting the C standard: "Within a structure object, the non-bit-field
members and the units in which bit-fields reside have addresses that
increase in the order in which they are declared. A pointer to a
structure object, suitably converted, points to its initial member (or
if that member is a bit-field, then to the unit in which it resides),
and vice versa. There may be unnamed padding within a structure
object, but not at its beginning."

*)

(********************************************************************)

absvtype hashmap_vt (hash_vt  : vt@ype+,
                     key_vt   : vt@ype+,
                     value_vt : vt@ype+,
                     size     : int)
vtypedef hashmap_vt (hash_vt  : vt@ype+,
                     key_vt   : vt@ype+,
                     value_vt : vt@ype+) =
  [size : int] hashmap_vt (hash_vt, key_vt, value_vt, size)

praxi
lemma_hashmap_vt_param :
  {size : int}
  {hash_vt, key_vt, value_vt : vt@ype}
  hashmap_vt (hash_vt, key_vt, value_vt, size) -<prf>
    [0 <= size] void

(********************************************************************)

fun {}
hashmap {hash_vt, key_vt, value_vt : vt@ype}
        () :
    hashmap_vt (hash_vt, key_vt, value_vt, 0)

(********************************************************************)

