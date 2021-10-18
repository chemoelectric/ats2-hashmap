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

staload "hashmap/SATS/bits_source-parameters.sats"
staload "hashmap/SATS/population_map.sats"

staload _ = "hashmap/DATS/population_map.dats"

macdef castpop = $UNSAFE.cast{population_map_t}
macdef bits2map = bits_to_population_map

fn
test_bits_to_population_map () : void =
  (* The following also tests "=" *)
  {
    val _ = assertloc (i2sz 8 <= sizeof<population_map_t>)
    val _ = assertloc (bits2map (0) = castpop 0x0000000000000001ULL)
    val _ = assertloc (bits2map (1) = castpop 0x0000000000000002ULL)
    val _ = assertloc (bits2map (2) = castpop 0x0000000000000004ULL)
    val _ = assertloc (bits2map (3) = castpop 0x0000000000000008ULL)
    val _ = assertloc (bits2map (4) = castpop 0x0000000000000010ULL)
    val _ = assertloc (bits2map (5) = castpop 0x0000000000000020ULL)
    val _ = assertloc (bits2map (6) = castpop 0x0000000000000040ULL)
    val _ = assertloc (bits2map (7) = castpop 0x0000000000000080ULL)
    val _ = assertloc (bits2map (8) = castpop 0x0000000000000100ULL)
    val _ = assertloc (bits2map (9) = castpop 0x0000000000000200ULL)
    val _ = assertloc (bits2map (10) = castpop 0x0000000000000400ULL)
    val _ = assertloc (bits2map (11) = castpop 0x0000000000000800ULL)
    val _ = assertloc (bits2map (12) = castpop 0x0000000000001000ULL)
    val _ = assertloc (bits2map (13) = castpop 0x0000000000002000ULL)
    val _ = assertloc (bits2map (14) = castpop 0x0000000000004000ULL)
    val _ = assertloc (bits2map (15) = castpop 0x0000000000008000ULL)
    val _ = assertloc (bits2map (16) = castpop 0x0000000000010000ULL)
    val _ = assertloc (bits2map (17) = castpop 0x0000000000020000ULL)
    val _ = assertloc (bits2map (18) = castpop 0x0000000000040000ULL)
    val _ = assertloc (bits2map (19) = castpop 0x0000000000080000ULL)
    val _ = assertloc (bits2map (20) = castpop 0x0000000000100000ULL)
    val _ = assertloc (bits2map (21) = castpop 0x0000000000200000ULL)
    val _ = assertloc (bits2map (22) = castpop 0x0000000000400000ULL)
    val _ = assertloc (bits2map (23) = castpop 0x0000000000800000ULL)
    val _ = assertloc (bits2map (24) = castpop 0x0000000001000000ULL)
    val _ = assertloc (bits2map (25) = castpop 0x0000000002000000ULL)
    val _ = assertloc (bits2map (26) = castpop 0x0000000004000000ULL)
    val _ = assertloc (bits2map (27) = castpop 0x0000000008000000ULL)
    val _ = assertloc (bits2map (28) = castpop 0x0000000010000000ULL)
    val _ = assertloc (bits2map (29) = castpop 0x0000000020000000ULL)
    val _ = assertloc (bits2map (30) = castpop 0x0000000040000000ULL)
    val _ = assertloc (bits2map (31) = castpop 0x0000000080000000ULL)
    val _ = assertloc (bits2map (32) = castpop 0x0000000100000000ULL)
    val _ = assertloc (bits2map (33) = castpop 0x0000000200000000ULL)
    val _ = assertloc (bits2map (34) = castpop 0x0000000400000000ULL)
    val _ = assertloc (bits2map (35) = castpop 0x0000000800000000ULL)
    val _ = assertloc (bits2map (36) = castpop 0x0000001000000000ULL)
    val _ = assertloc (bits2map (37) = castpop 0x0000002000000000ULL)
    val _ = assertloc (bits2map (38) = castpop 0x0000004000000000ULL)
    val _ = assertloc (bits2map (39) = castpop 0x0000008000000000ULL)
    val _ = assertloc (bits2map (40) = castpop 0x0000010000000000ULL)
    val _ = assertloc (bits2map (41) = castpop 0x0000020000000000ULL)
    val _ = assertloc (bits2map (42) = castpop 0x0000040000000000ULL)
    val _ = assertloc (bits2map (43) = castpop 0x0000080000000000ULL)
    val _ = assertloc (bits2map (44) = castpop 0x0000100000000000ULL)
    val _ = assertloc (bits2map (45) = castpop 0x0000200000000000ULL)
    val _ = assertloc (bits2map (46) = castpop 0x0000400000000000ULL)
    val _ = assertloc (bits2map (47) = castpop 0x0000800000000000ULL)
    val _ = assertloc (bits2map (48) = castpop 0x0001000000000000ULL)
    val _ = assertloc (bits2map (49) = castpop 0x0002000000000000ULL)
    val _ = assertloc (bits2map (50) = castpop 0x0004000000000000ULL)
    val _ = assertloc (bits2map (51) = castpop 0x0008000000000000ULL)
    val _ = assertloc (bits2map (52) = castpop 0x0010000000000000ULL)
    val _ = assertloc (bits2map (53) = castpop 0x0020000000000000ULL)
    val _ = assertloc (bits2map (54) = castpop 0x0040000000000000ULL)
    val _ = assertloc (bits2map (55) = castpop 0x0080000000000000ULL)
    val _ = assertloc (bits2map (56) = castpop 0x0100000000000000ULL)
    val _ = assertloc (bits2map (57) = castpop 0x0200000000000000ULL)
    val _ = assertloc (bits2map (58) = castpop 0x0400000000000000ULL)
    val _ = assertloc (bits2map (59) = castpop 0x0800000000000000ULL)
    val _ = assertloc (bits2map (60) = castpop 0x1000000000000000ULL)
    val _ = assertloc (bits2map (61) = castpop 0x2000000000000000ULL)
    val _ = assertloc (bits2map (62) = castpop 0x4000000000000000ULL)
    val _ = assertloc (bits2map (63) = castpop 0x8000000000000000ULL)
  }

fn
test_neq () : void =
  (* This also does some testing of "=" *)
  let
    var i : uint
  in
    for (i := 0U; i <= 10000U; i := succ i)
      let
        var j : uint
      in
        for (j := 0U; j <= 10000U; j := succ j)
          begin
            if i = j then
              assertloc (castpop i = castpop j)
            else
              begin
                assertloc (castpop i <> castpop j);
                assertloc (castpop i != castpop j)
              end
          end
      end
  end

fn
test_lnot () : void =
  (* This also does some checking of "land". *)
  let
    val mask = 0xFFFFU
    var i : uint
  in
    for (i := 0U; i <= 10000U; i := succ i)
      let
        val ii : population_map_t = castpop i
        val maskmask : population_map_t = castpop mask
      in
        assertloc (castpop ((lnot i) land mask)
                      = ((lnot ii) land maskmask))
      end
  end

fn
test_land () : void =
  let
    var i : uint
  in
    for (i := 0U; i <= 10000U; i := succ i)
      let
        var j : uint
      in
        for (j := 0U; j <= 10000U; j := succ j)
          let
            val ii : population_map_t = castpop i
            val jj : population_map_t = castpop j
          in
            assertloc (castpop (i land j) = (ii land jj))
          end
      end
  end

fn
test_lor () : void =
  let
    var i : uint
  in
    for (i := 0U; i <= 10000U; i := succ i)
      let
        var j : uint
      in
        for (j := 0U; j <= 10000U; j := succ j)
          let
            val ii : population_map_t = castpop i
            val jj : population_map_t = castpop j
          in
            assertloc (castpop (i lor j) = (ii lor jj))
          end
      end
  end

fn
test_lxor () : void =
  let
    var i : uint
  in
    for (i := 0U; i <= 10000U; i := succ i)
      let
        var j : uint
      in
        for (j := 0U; j <= 10000U; j := succ j)
          let
            val ii : population_map_t = castpop i
            val jj : population_map_t = castpop j
          in
            assertloc (castpop (i lxor j) = (ii lxor jj))
          end
      end
  end

implement
main0 () =
  {
    val _ = test_bits_to_population_map ()
    val _ = test_neq ()
    val _ = test_lnot ()
    val _ = test_land ()
    val _ = test_lor ()
    val _ = test_lxor ()
  }
