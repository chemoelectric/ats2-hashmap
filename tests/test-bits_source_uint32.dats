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

macdef cast32 = $UNSAFE.cast{uint32}

fn
test_num_bits_eq_6 () : void =
  {
    var hash : uint32 = cast32 0x12345678U
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint32 = cast32 0
        var factor : uint32 = cast32 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits : uint32 = cast32 (bits_source<uint32> (hash, i))
          in
            u := u + (bits * factor);
            factor := factor * (cast32 64U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc (bits_source<uint32> (hash, 0U) = 0x38)
    val _ = assertloc (bits_source<uint32> (hash, 1U) = 0x19)
    val _ = assertloc (bits_source<uint32> (hash, 2U) = 0x05)
    val _ = assertloc (bits_source<uint32> (hash, 3U) = 0x0D)
    val _ = assertloc (bits_source<uint32> (hash, 4U) = 0x12)
    val _ = assertloc (bits_source<uint32> (hash, 5U) = 0x00)
    val _ = assertloc (bits_source<uint32> (hash, 6U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint32> (hash, 7U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint32> (hash, 8U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint32> (hash, 9U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint32> (hash, 10U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint32> (hash, 11U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint32> (hash, 100U) = BITS_SOURCE_EXHAUSTED)

    var hash : uint32 = cast32 0xDEADBEEFU
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint32 = cast32 0
        var factor : uint32 = cast32 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits : uint32 = cast32 (bits_source<uint32> (hash, i))
          in
            u := u + (bits * factor);
            factor := factor * (cast32 64U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc (bits_source<uint32> (hash, 0U) = 0x2F)
    val _ = assertloc (bits_source<uint32> (hash, 1U) = 0x3B)
    val _ = assertloc (bits_source<uint32> (hash, 2U) = 0x1B)
    val _ = assertloc (bits_source<uint32> (hash, 3U) = 0x2B)
    val _ = assertloc (bits_source<uint32> (hash, 4U) = 0x1E)
    val _ = assertloc (bits_source<uint32> (hash, 5U) = 0x03)
    val _ = assertloc (bits_source<uint32> (hash, 6U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint32> (hash, 7U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint32> (hash, 8U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint32> (hash, 9U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint32> (hash, 10U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint32> (hash, 11U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint32> (hash, 100U) = BITS_SOURCE_EXHAUSTED)
  }

implement
main0 () =
  {
    val _ = test_num_bits_eq_6 ()
  }
