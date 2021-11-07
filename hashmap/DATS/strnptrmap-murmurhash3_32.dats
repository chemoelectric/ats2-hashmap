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
(* String maps by means of hashmap and ats2-murmurhash3             *)
(* (32-bit MurmurHash3)                                             *)
(*                                                                  *)
(********************************************************************)

#define ATS_PACKNAME "ats2-hashmap"
#define ATS_EXTERN_PREFIX "ats2_hashmap_"

#define ATS_DYNLOADFLAG 0

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

staload UN = "prelude/SATS/unsafe.sats"

staload "hashmap/SATS/strnptrmap.sats"

staload "hashmap/SATS/bits_source.sats"
staload "hashmap/SATS/bits_source-parameters.sats"
staload "hashmap/SATS/hashmap.sats"
staload "murmurhash3/SATS/murmurhash3_32.sats"

local

  typedef hash_t = uint32
  vtypedef key_vt = Strnptr1

  (* seed may be any number that please the programmer,
     although changing it may change what are the correct results
     of regression tests. *)
  macdef seed = $UN.cast{uint32} 0xDEADBEEFULL

  implement
  hashmap$hash_function<hash_t><key_vt> (key, hash) =
    {
      val [n : int] s = g1ofg0 ($UN.strnptr2string key)
      val n = strlen s
      val p = string2ptr s
      val (pf_bytes, consume_pf | p) = $UN.ptr_vtake {@[byte][n]} p
      val _ = hash := murmurhash3_32 (pf_bytes | p, n, seed)
      prval () = consume_pf pf_bytes
    }

  implement
  hashmap$hash_vt_free<hash_t> (hash) =
    ()

  implement
  hashmap$bits_source<hash_t> (hash, depth) =
    bits_source_uint32 (hash, depth)

  implement
  hashmap$key_vt_free<key_vt> (key) =
    free key

  implement
  hashmap$key_vt_copy<key_vt> (key) =
    string1_copy ($UN.strnptr2string key)

  implement
  hashmap$key_vt_eq<key_vt> (key_arg, key_stored) =
    ($UN.strnptr2string key_arg) = ($UN.strnptr2string key_stored)

in

  #include "hashmap/DATS/INCLUDE/strnptrmap-implementations.dats"

end
