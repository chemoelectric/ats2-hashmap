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

macdef castb = $UNSAFE.cast{byte}

fn
test_num_bits_eq_6 () : void =
  {
    var hash = @[byte][16] (castb 0x0D,
                            castb 0xF0,
                            castb 0xCE,
                            castb 0xFA,
                            castb 0x11,
                            castb 0xBA,
                            castb 0x5E,
                            castb 0xBA,
                            castb 0x78,
                            castb 0x56,
                            castb 0x34,
                            castb 0x12,
                            castb 0xEF,
                            castb 0xBE,
                            castb 0xAD,
                            castb 0xDE)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 0U) = 0x0D)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 1U) = 0x00)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 2U) = 0x2F)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 3U) = 0x33)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 4U) = 0x3A)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 5U) = 0x07)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 6U) = 0x21)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 7U) = 0x2E)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 8U) = 0x1E)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 9U) = 0x29)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 10U) = 0x0B)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 11U) = 0x1E)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 12U) = 0x16)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 13U) = 0x11)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 14U) = 0x23)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 15U) = 0x04)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 16U) = 0x2F)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 17U) = 0x3B)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 18U) = 0x1B)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 19U) = 0x2B)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 20U) = 0x1E)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 21U) = 0x03)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 22U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 23U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 24U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 25U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 26U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 27U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 28U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 29U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 30U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 31U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 32U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 33U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 34U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 35U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<@[byte][16]> (hash, 100U) = BITS_SOURCE_EXHAUSTED)
  }

implement
main0 () =
  {
    val _ = test_num_bits_eq_6 ()
  }
