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

#include "hashmap/HATS/config.hats"
#include "hashmap/HATS/array-mapped-tree-helpers.hats"

staload "hashmap/SATS/nth-bit-index.sats"

implement
nth_bit_index (population_map, n) =
  let
    prval _ = lemma_g1uint_param n

    fun
    loop_m {m : int | 0 <= m}
           {j : int | 0 <= j; j <= BITSIZEOF_UINTPTR}
           .<m>.
           (m   : size_t m,
            j   : int j) :<>
        [i : int | 0 <= i; i < BITSIZEOF_UINTPTR]
        int i =
      let
        fun
        loop_j {j : int | 0 <= j; j <= BITSIZEOF_UINTPTR}
               .<BITSIZEOF_UINTPTR - j>.
               (j   : int j) :<>
            [k : int | 0 <= k; k < BITSIZEOF_UINTPTR]
            int k =
          if bit_is_set<> (population_map, (one << j)) then
            let
              val _ = 
                $effmask_exn (assertloc (j < BITSIZEOF_UINTPTR))
            in
              j
            end
          else
            let
              val _ =
                $effmask_exn (assertloc (j + 1 < BITSIZEOF_UINTPTR))
            in
              loop_j (succ j)
            end
        val j = loop_j (j)
        val _ =
          $effmask_exn (assertloc (j + 1 < BITSIZEOF_UINTPTR))
      in
        if m = i2sz 0 then
          j
        else
          loop_m (pred m, succ j)
      end
  in
    loop_m (n, 0)
  end
