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

#include "hashmap/HATS/bits-source-include.hats"

staload "hashmap/SATS/bits-source.sats"

implement
bits_source_check_mask (num_bits, mask) =
  case- num_bits of
  | 4U => (mask <= MAXVALOF_BITINDEX_4)
  | 5U => (mask <= MAXVALOF_BITINDEX_5)
  | 6U => (mask <= MAXVALOF_BITINDEX_6)
  | 7U => (mask <= MAXVALOF_BITINDEX_7)
  | 8U => (mask <= MAXVALOF_BITINDEX_8)
