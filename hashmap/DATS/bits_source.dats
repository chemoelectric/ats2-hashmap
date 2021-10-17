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

staload "hashmap/SATS/bits_source.sats"

implement bits_source<uint8> = bits_source_uint8
implement bits_source<uint16> = bits_source_uint16
implement bits_source<uint32> = bits_source_uint32
implement bits_source<uint64> = bits_source_uint64
implement bits_source<@(uint64, uint64)> = bits_source_uint64_uint64

implement bits_source<@[byte][1]> = bits_source_1byte
implement bits_source<@[byte][2]> = bits_source_2bytes
implement bits_source<@[byte][3]> = bits_source_3bytes
implement bits_source<@[byte][4]> = bits_source_4bytes
implement bits_source<@[byte][5]> = bits_source_5bytes
implement bits_source<@[byte][6]> = bits_source_6bytes
implement bits_source<@[byte][7]> = bits_source_7bytes
implement bits_source<@[byte][8]> = bits_source_8bytes
implement bits_source<@[byte][9]> = bits_source_9bytes
implement bits_source<@[byte][10]> = bits_source_10bytes
implement bits_source<@[byte][11]> = bits_source_11bytes
implement bits_source<@[byte][12]> = bits_source_12bytes
implement bits_source<@[byte][13]> = bits_source_13bytes
implement bits_source<@[byte][14]> = bits_source_14bytes
implement bits_source<@[byte][15]> = bits_source_15bytes
implement bits_source<@[byte][16]> = bits_source_16bytes
implement bits_source<@[byte][17]> = bits_source_17bytes
implement bits_source<@[byte][18]> = bits_source_18bytes
implement bits_source<@[byte][19]> = bits_source_19bytes
implement bits_source<@[byte][20]> = bits_source_20bytes
implement bits_source<@[byte][21]> = bits_source_21bytes
implement bits_source<@[byte][22]> = bits_source_22bytes
implement bits_source<@[byte][23]> = bits_source_23bytes
implement bits_source<@[byte][24]> = bits_source_24bytes
implement bits_source<@[byte][25]> = bits_source_25bytes
implement bits_source<@[byte][26]> = bits_source_26bytes
implement bits_source<@[byte][27]> = bits_source_27bytes
implement bits_source<@[byte][28]> = bits_source_28bytes
implement bits_source<@[byte][29]> = bits_source_29bytes
implement bits_source<@[byte][30]> = bits_source_30bytes
implement bits_source<@[byte][31]> = bits_source_31bytes
implement bits_source<@[byte][32]> = bits_source_32bytes
