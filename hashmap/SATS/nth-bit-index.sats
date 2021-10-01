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

#include "hashmap/HATS/config.hats"

(* nth-bit-index --
   Return the bit index of one of the zeroth, first, second,
   third, fourth, etc., entry in a node. *)
fun
nth_bit_index {n              : int}
              (population_map : uintptr,
               n              : size_t n) :<>
    [i : int | 0 <= i; i < BITSIZEOF_UINTPTR]
    int i
