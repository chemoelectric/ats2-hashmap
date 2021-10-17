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

prval _ = prop_verify {BITS_SOURCE_NUM_BITS == 6} ()

macdef cast16 = $UNSAFE.cast{uint16}

fn
test_num_bits_eq_6 () : void =
  {
    var hash : uint16 = cast16 0x1234U
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint16 = cast16 0
        var factor : uint16 = cast16 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits : uint16 = cast16 (bits_source<uint16> (hash, i))
          in
            u := u + (bits * factor);
            factor := factor * (cast16 64U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc (bits_source<uint16> (hash, 0U) = 52)
    val _ = assertloc (bits_source<uint16> (hash, 1U) = 8)
    val _ = assertloc (bits_source<uint16> (hash, 2U) = 1)
    val _ = assertloc (bits_source<uint16> (hash, 3U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint16> (hash, 4U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint16> (hash, 5U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint16> (hash, 6U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint16> (hash, 7U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint16> (hash, 8U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint16> (hash, 9U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint16> (hash, 10U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint16> (hash, 11U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint16> (hash, 100U) = BITS_SOURCE_EXHAUSTED)

    var hash : uint16 = cast16 0xDEADU
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint16 = cast16 0
        var factor : uint16 = cast16 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits : uint16 = cast16 (bits_source<uint16> (hash, i))
          in
            u := u + (bits * factor);
            factor := factor * (cast16 64U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc (bits_source<uint16> (hash, 0U) = 45)
    val _ = assertloc (bits_source<uint16> (hash, 1U) = 58)
    val _ = assertloc (bits_source<uint16> (hash, 2U) = 13)
    val _ = assertloc (bits_source<uint16> (hash, 3U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint16> (hash, 4U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint16> (hash, 5U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint16> (hash, 6U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint16> (hash, 7U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint16> (hash, 8U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint16> (hash, 9U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint16> (hash, 10U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint16> (hash, 11U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint16> (hash, 100U) = BITS_SOURCE_EXHAUSTED)
  }

implement
main0 () =
  {
    val _ = test_num_bits_eq_6 ()
  }
