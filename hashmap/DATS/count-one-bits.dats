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

staload "hashmap/SATS/count-one-bits.sats"

implement
count_one_bits<uintknd> {x} (x) =
  count_one_bits_uint {x} (x)

implement
count_one_bits<ulintknd> {x} (x) =
  count_one_bits_ulint {x} (x)

implement
count_one_bits<ullintknd> {x} (x) =
  count_one_bits_ullint {x} (x)

implement
count_one_bits<uintptrknd> {x} (x) =
  count_one_bits_uintptr {x} (x)

implement
count_low_one_bits<uintknd> {x} {i} (x, i) =
  count_low_one_bits_uint {x} {i} (x, i)

implement
count_low_one_bits<ulintknd> {x} {i} (x, i) =
  count_low_one_bits_ulint {x} {i} (x, i)

implement
count_low_one_bits<ullintknd> {x} {i} (x, i) =
  count_low_one_bits_ullint {x} {i} (x, i)

implement
count_low_one_bits<uintptrknd> {x} {i} (x, i) =
  count_low_one_bits_uintptr {x} {i} (x, i)
