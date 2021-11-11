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

macdef cast8 = $UNSAFE.cast{uint8}

fn
test_num_bits_eq_6 () : void =
  {
    var hash : uint8 = cast8 0x96U
    val _ = assertloc (bits_source<uint8> (hash, 0U) = 0x16)
    val _ = assertloc (bits_source<uint8> (hash, 1U) = 0x02)
    val _ = assertloc (bits_source<uint8> (hash, 2U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint8> (hash, 3U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint8> (hash, 4U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint8> (hash, 5U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<uint8> (hash, 100U) = BITS_SOURCE_EXHAUSTED)
  }

implement
main0 () =
  {
    val _ = test_num_bits_eq_6 ()
  }
