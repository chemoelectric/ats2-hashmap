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

include(`common-macros.m4')dnl

#define ATS_PACKNAME "ats2-hashmap"
#define ATS_EXTERN_PREFIX "ats2_hashmap_"

staload "hashmap/SATS/bits_source-parameters.sats"

(********************************************************************)

(*

  A bits source returns ~1 == BITS_SOURCE_EXHAUSTED, if the index is
  past the last available bit.

*)

#define BITS_SOURCE_EXHAUSTED (~1)

stadef bits_source_valid_value (bits : int) : bool =
  BITS_SOURCE_EXHAUSTED <= bits && bits <= BITS_SOURCE_MAXVAL

stadef bits_source_valid_bits (bits : int) : bool =
  0 <= bits && bits <= BITS_SOURCE_MAXVAL

(********************************************************************)

vtypedef
bits_source_vt (hash_vt : vt@ype+) =
  {depth : int}
  (&hash_vt >> _, uint depth) ->
    [bits : int | bits_source_valid_value bits;
                  depth != 0 || bits != BITS_SOURCE_EXHAUSTED]
    int bits

fun {hash_vt : vt@ype}
bits_source : bits_source_vt (hash_vt)

(********************************************************************)
(* Bits sources that return least significant bits first, regardless
   of the platform's endianness. *)

fun bits_source_uint8 : bits_source_vt (uint8)
fun bits_source_uint16 : bits_source_vt (uint16)
fun bits_source_uint32 : bits_source_vt (uint32)
fun bits_source_uint64 : bits_source_vt (uint64)

(* A 128-bit number as a hash --
   The first uint64 represents the less significant 64 bits, and
   the second uint64 represents the more significant 64 bits. *)
fun bits_source_uint64_uint64 : bits_source_vt (@(uint64, uint64))

(********************************************************************)
(* Bits sources that return bits in memory order. *)

fun
bits_source_nbytes {n     : int | 1 <= n}
                   {depth : int}
                   (n     : size_t n,
                    hash  : &(@[byte][n]) >> _,
                    depth : uint depth) :
    [bits : int | bits_source_valid_value bits;
                  depth != 0 || bits != BITS_SOURCE_EXHAUSTED]
    int bits

fun bits_source_1byte : bits_source_vt (@[byte][1])
m4_forloop(`i',2,64,`fun bits_source_`'i`'bytes : bits_source_vt (@[byte][`'i`'])
')dnl

(********************************************************************)
