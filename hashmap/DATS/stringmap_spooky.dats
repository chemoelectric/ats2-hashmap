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

staload UN = "prelude/SATS/unsafe.sats"

staload "hashmap/SATS/stringmap_spooky.sats"

staload "hashmap/SATS/bits_source.sats"
staload "hashmap/SATS/bits_source-parameters.sats"
staload "hashmap/SATS/hashmap.sats"
staload "spookyhash/SATS/spookyhash.sats"

staload _ = "hashmap/DATS/bits_source.dats"

(*
staload "hashmap/SATS/array-proofs.sats"
staload "hashmap/SATS/memory.sats"
staload "hashmap/SATS/population_map.sats"
staload "popcount/SATS/popcount.sats"

staload _ = "hashmap/DATS/population_map.dats"
staload _ = "hashmap/DATS/memory.dats"
staload _ = "popcount/DATS/popcount.dats"

#define NIL list_vt_nil ()
#define :: list_vt_cons

#define CHAR_BIT 8              (* The size of a byte, in bits. *)

prval _ = lemma_sizeof {population_map_t} ()

prval _ =
  $UN.prop_assert
    {BITS_SOURCE_MAXVAL == CHAR_BIT * sizeof (population_map_t) - 1}
    ()
*)

local

  typedef hash_t = @(uint64, uint64)
  vtypedef key_vt = Strnptr1

  (* seed1 and seeds may be any numbers that please the programmer. *)
  macdef seed1 = $UN.cast{uint64} 0xBA5EBA11BACEBA11ULL
  macdef seed2 = $UN.cast{uint64} 0x0123456789012345ULL

  implement
  hashmap$hash_function<hash_t><key_vt> (key, hash) =
    {
      val [n : int] s = g1ofg0 ($UN.strnptr2string key)
      val n = strlen s
      val p = string2ptr s
      val (pf_bytes, consume_pf | p) = $UN.ptr_vtake {@[byte][n]} p
      val _ = hash := spookyhash_hash128 (!p, n, seed1, seed2)
      prval () = consume_pf pf_bytes
    }

  implement
  hashmap$hash_vt_free<hash_t> (hash) =
    ()

  implement
  hashmap$bits_source<hash_t> (hash, depth) =
    bits_source_uint64_uint64 (hash, depth)

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

  primplement
  lemma_stringmap_vt_param (map) =
    lemma_hashmap_vt_param (map)

  implement {}
  stringmap () =
    hashmap ()

end
