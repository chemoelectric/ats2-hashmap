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
fun bits_source_2bytes : bits_source_vt (@[byte][2])
fun bits_source_3bytes : bits_source_vt (@[byte][3])
fun bits_source_4bytes : bits_source_vt (@[byte][4])
fun bits_source_5bytes : bits_source_vt (@[byte][5])
fun bits_source_6bytes : bits_source_vt (@[byte][6])
fun bits_source_7bytes : bits_source_vt (@[byte][7])
fun bits_source_8bytes : bits_source_vt (@[byte][8])
fun bits_source_9bytes : bits_source_vt (@[byte][9])
fun bits_source_10bytes : bits_source_vt (@[byte][10])
fun bits_source_11bytes : bits_source_vt (@[byte][11])
fun bits_source_12bytes : bits_source_vt (@[byte][12])
fun bits_source_13bytes : bits_source_vt (@[byte][13])
fun bits_source_14bytes : bits_source_vt (@[byte][14])
fun bits_source_15bytes : bits_source_vt (@[byte][15])
fun bits_source_16bytes : bits_source_vt (@[byte][16])
fun bits_source_17bytes : bits_source_vt (@[byte][17])
fun bits_source_18bytes : bits_source_vt (@[byte][18])
fun bits_source_19bytes : bits_source_vt (@[byte][19])
fun bits_source_20bytes : bits_source_vt (@[byte][20])
fun bits_source_21bytes : bits_source_vt (@[byte][21])
fun bits_source_22bytes : bits_source_vt (@[byte][22])
fun bits_source_23bytes : bits_source_vt (@[byte][23])
fun bits_source_24bytes : bits_source_vt (@[byte][24])
fun bits_source_25bytes : bits_source_vt (@[byte][25])
fun bits_source_26bytes : bits_source_vt (@[byte][26])
fun bits_source_27bytes : bits_source_vt (@[byte][27])
fun bits_source_28bytes : bits_source_vt (@[byte][28])
fun bits_source_29bytes : bits_source_vt (@[byte][29])
fun bits_source_30bytes : bits_source_vt (@[byte][30])
fun bits_source_31bytes : bits_source_vt (@[byte][31])
fun bits_source_32bytes : bits_source_vt (@[byte][32])
fun bits_source_33bytes : bits_source_vt (@[byte][33])
fun bits_source_34bytes : bits_source_vt (@[byte][34])
fun bits_source_35bytes : bits_source_vt (@[byte][35])
fun bits_source_36bytes : bits_source_vt (@[byte][36])
fun bits_source_37bytes : bits_source_vt (@[byte][37])
fun bits_source_38bytes : bits_source_vt (@[byte][38])
fun bits_source_39bytes : bits_source_vt (@[byte][39])
fun bits_source_40bytes : bits_source_vt (@[byte][40])
fun bits_source_41bytes : bits_source_vt (@[byte][41])
fun bits_source_42bytes : bits_source_vt (@[byte][42])
fun bits_source_43bytes : bits_source_vt (@[byte][43])
fun bits_source_44bytes : bits_source_vt (@[byte][44])
fun bits_source_45bytes : bits_source_vt (@[byte][45])
fun bits_source_46bytes : bits_source_vt (@[byte][46])
fun bits_source_47bytes : bits_source_vt (@[byte][47])
fun bits_source_48bytes : bits_source_vt (@[byte][48])
fun bits_source_49bytes : bits_source_vt (@[byte][49])
fun bits_source_50bytes : bits_source_vt (@[byte][50])
fun bits_source_51bytes : bits_source_vt (@[byte][51])
fun bits_source_52bytes : bits_source_vt (@[byte][52])
fun bits_source_53bytes : bits_source_vt (@[byte][53])
fun bits_source_54bytes : bits_source_vt (@[byte][54])
fun bits_source_55bytes : bits_source_vt (@[byte][55])
fun bits_source_56bytes : bits_source_vt (@[byte][56])
fun bits_source_57bytes : bits_source_vt (@[byte][57])
fun bits_source_58bytes : bits_source_vt (@[byte][58])
fun bits_source_59bytes : bits_source_vt (@[byte][59])
fun bits_source_60bytes : bits_source_vt (@[byte][60])
fun bits_source_61bytes : bits_source_vt (@[byte][61])
fun bits_source_62bytes : bits_source_vt (@[byte][62])
fun bits_source_63bytes : bits_source_vt (@[byte][63])
fun bits_source_64bytes : bits_source_vt (@[byte][64])

(********************************************************************)
