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
staload "hashmap/SATS/bits_source.sats"

staload _ = "hashmap/DATS/bits_source.dats"

#include "tests/INCLUDE/runtime-support.dats"

prval _ = prop_verify {BITS_SOURCE_NUM_BITS == 6} ()

macdef cast64 = $UNSAFE.cast{uint64}

fn
test_num_bits_eq_6 () : void =
  {
    var hash : uint64 = cast64 0xBA5EBA11FACEF00DULL
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint64 = cast64 0
        var factor : uint64 = cast64 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits : uint64 = cast64 (bits_source<uint64> (hash, i))
          in
            u := u + (bits * factor);
            factor := factor * (cast64 64U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc (bits_source<uint64> (hash, 0U) = 13)
    val _ = assertloc (bits_source<uint64> (hash, 1U) = 0)
    val _ = assertloc (bits_source<uint64> (hash, 2U) = 47)
    val _ = assertloc (bits_source<uint64> (hash, 3U) = 51)
    val _ = assertloc (bits_source<uint64> (hash, 4U) = 58)
    val _ = assertloc (bits_source<uint64> (hash, 5U) = 7)
    val _ = assertloc (bits_source<uint64> (hash, 6U) = 33)
    val _ = assertloc (bits_source<uint64> (hash, 7U) = 46)
    val _ = assertloc (bits_source<uint64> (hash, 8U) = 30)
    val _ = assertloc (bits_source<uint64> (hash, 9U) = 41)
    val _ = assertloc (bits_source<uint64> (hash, 10U) = 11)
    val _ = assertloc (bits_source<uint64> (hash, 11U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint64> (hash, 12U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint64> (hash, 13U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint64> (hash, 14U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint64> (hash, 100U) = BITS_SOURCE_EXHAUSTED)
  }

implement
main0 () =
  {
    val _ = test_num_bits_eq_6 ()
  }
