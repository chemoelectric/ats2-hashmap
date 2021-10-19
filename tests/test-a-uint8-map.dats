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

staload "hashmap/SATS/hashmap.sats"
staload "hashmap/SATS/bits_source.sats"

staload _ = "hashmap/DATS/hashmap.dats"
staload _ = "hashmap/DATS/bits_source.dats"
staload _ = "hashmap/DATS/population_map.dats"
staload _ = "popcount/DATS/popcount.dats"

typedef hash_vt = uint8
typedef key_vt = uint8
typedef value_vt = int

implement
hashmap$hash_function<hash_vt><key_vt> (key, hash) =
  hash := key

implement
hashmap$hash_vt_free<hash_vt> (hash) =
  ()

implement
hashmap$bits_source<hash_vt> (hash, depth) =
  bits_source_uint8 (hash, depth)

implement
hashmap$key_vt_free<key_vt> (key) =
  ()

implement
hashmap$value_vt_free<value_vt> (value) =
  ()

implement
hashmap$key_vt_copy<key_vt> (key) =
  key

implement
hashmap$value_vt_copy<value_vt> (value) =
  value

implement
hashmap$key_vt_eq<key_vt> (key_arg, key_stored) =
  key_arg = key_stored

implement
main0 () =
  {
    val map = hashmap ()
    val map =
      hashmap_include<hash_vt><key_vt, value_vt>
        (map, $UNSAFE.cast{uint8} 2, 36)

    val result =
      hashmap_find<hash_vt><key_vt, value_vt>
        (map, $UNSAFE.cast{uint8} 2)
    val _ =
      case+ result of
      | ~ None_vt () => println! ("None_vt ()")
      | ~ Some_vt value => println! ("Some_vt (", value : int, ")")

    val result =
      hashmap_find<hash_vt><key_vt, value_vt>
        (map, $UNSAFE.cast{uint8} 3)
    val _ =
      case+ result of
      | ~ None_vt () => println! ("None_vt ()")
      | ~ Some_vt value => println! ("Some_vt (", value : int, ")")

(* FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
    val _ = free map // FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME: ****** NOT YET IMPLEMENTED ******
*)  prval _ = $UNSAFE.castvwtp0{void} map // FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
  }
