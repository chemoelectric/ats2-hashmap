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
staload "hashmap/SATS/bits_source.sats"

(********************************************************************)

(* bits_to_population_map:
   Make a popcount=1 mask from hash bits. *)
fun {}
bits_to_population_map
        {bits : int | bits_source_valid_bits (bits)}
        (bits : int bits) :<>
    population_map_t

(* Equality. *)
fun {}
population_map_eq
        {map1, map2 : int}
        (map1 : population_map_t map1,
         map2 : population_map_t map2) :<>
    bool (map1 == map2)
overload = with population_map_eq of 100

(* Inequality. *)
fun {}
population_map_neq
        {map1, map2 : int}
        (map1 : population_map_t map1,
         map2 : population_map_t map2) :<>
    bool (map1 != map2)
overload <> with population_map_neq of 100
overload != with population_map_neq of 100

(* Bitwise NOT. *)
fun {}
population_map_lnot
        {map : int}
        (map : population_map_t map) :<>
    population_map_t

(* Bitwise AND. *)
fun {}
population_map_land
        {map1, map2 : int}
        (map1 : population_map_t map1,
         map2 : population_map_t map2) :<>
    population_map_t

(* Bitwise inclusive OR. *)
fun {}
population_map_lor
        {map1, map2 : int}
        (map1 : population_map_t map1,
         map2 : population_map_t map2) :<>
    population_map_t

(* Bitwise XOR. *)
fun {}
population_map_lxor
        {map1, map2 : int}
        (map1 : population_map_t map1,
         map2 : population_map_t map2) :<>
    population_map_t

(********************************************************************)
