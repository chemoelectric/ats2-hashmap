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

(********************************************************************)

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

staload "hashmap/SATS/bits_source-parameters.sats"
staload "hashmap/SATS/bits_source.sats"
staload "hashmap/SATS/population_map.sats"

(********************************************************************)

%{#
#undef ats2_hashmap_population_map_lshift
#define ats2_hashmap_population_map_lshift(u, i) ((u) << (i))

#undef ats2_hashmap_population_map_eq
#define ats2_hashmap_population_map_eq(u, v) ((u) == (v))

#undef ats2_hashmap_population_map_neq
#define ats2_hashmap_population_map_neq(u, v) ((u) != (v))

#undef ats2_hashmap_population_map_land
#define ats2_hashmap_population_map_land(u, v) ((u) & (v))

#undef ats2_hashmap_population_map_lor
#define ats2_hashmap_population_map_lor(u, v) ((u) | (v))

#undef ats2_hashmap_population_map_lxor
#define ats2_hashmap_population_map_lxor(u, v) ((u) ^ (v))
%}

(********************************************************************)

implement {}
bits_to_population_map (bits) =
  let
    extern fun
    lshift {u, i : int | bits_source_valid_bits (i)}
           (u    : population_map_t u,
            i    : uint i) :<>
        [v : int]
        population_map_t v = "mac#ats2_hashmap_population_map_lshift"
  in
    ($UNSAFE.cast{population_map_t} 1) \lshift (i2u bits)
  end

implement {}
population_map_eq (map1, map2) =
  let
    extern fun
    eq {map1, map2 : int}
       (map1 : population_map_t map1,
        map2 : population_map_t map2) :<>
        bool (map1 == map2) = "mac#ats2_hashmap_population_map_eq"
  in
    map1 \eq map2
  end

implement {}
population_map_neq (map1, map2) =
  let
    extern fun
    neq {map1, map2 : int}
        (map1 : population_map_t map1,
         map2 : population_map_t map2) :<>
        bool (map1 != map2) = "mac#ats2_hashmap_population_map_neq"
  in
    map1 \neq map2
  end

implement {}
population_map_lnot (map) =
  let
    extern fun
    lnot {map : int}
         (map : population_map_t map) :<>
        population_map_t = "mac#ats2_hashmap_population_map_lnot"
  in
    lnot map
  end

implement {}
population_map_land (map1, map2) =
  let
    extern fun
    land {map1, map2 : int}
         (map1 : population_map_t map1,
          map2 : population_map_t map2) :<>
        population_map_t = "mac#ats2_hashmap_population_map_land"
  in
    map1 land map2
  end

implement {}
population_map_lor (map1, map2) =
  let
    extern fun
    lor {map1, map2 : int}
        (map1 : population_map_t map1,
         map2 : population_map_t map2) :<>
        population_map_t = "mac#ats2_hashmap_population_map_lor"
  in
    map1 lor map2
  end

implement {}
population_map_lxor (map1, map2) =
  let
    extern fun
    lxor {map1, map2 : int}
         (map1 : population_map_t map1,
          map2 : population_map_t map2) :<>
        population_map_t = "mac#ats2_hashmap_population_map_lxor"
  in
    map1 lxor map2
  end

(********************************************************************)
