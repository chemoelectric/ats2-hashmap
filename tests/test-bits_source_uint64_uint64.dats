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
    typedef hash128_t = @(uint64, uint64)
    var hash : hash128_t = @(cast64 0xBA5EBA11FACEF00DULL,
                             cast64 0xDEADBEEF12345678ULL)
    val _ = assertloc (bits_source<hash128_t> (hash, 0U) = 0x0D)
    val _ = assertloc (bits_source<hash128_t> (hash, 1U) = 0x00)
    val _ = assertloc (bits_source<hash128_t> (hash, 2U) = 0x2F)
    val _ = assertloc (bits_source<hash128_t> (hash, 3U) = 0x33)
    val _ = assertloc (bits_source<hash128_t> (hash, 4U) = 0x3A)
    val _ = assertloc (bits_source<hash128_t> (hash, 5U) = 0x07)
    val _ = assertloc (bits_source<hash128_t> (hash, 6U) = 0x21)
    val _ = assertloc (bits_source<hash128_t> (hash, 7U) = 0x2E)
    val _ = assertloc (bits_source<hash128_t> (hash, 8U) = 0x1E)
    val _ = assertloc (bits_source<hash128_t> (hash, 9U) = 0x29)
    val _ = assertloc (bits_source<hash128_t> (hash, 10U) = 0x0B)
    val _ = assertloc (bits_source<hash128_t> (hash, 11U) = 0x1E)
    val _ = assertloc (bits_source<hash128_t> (hash, 12U) = 0x16)
    val _ = assertloc (bits_source<hash128_t> (hash, 13U) = 0x11)
    val _ = assertloc (bits_source<hash128_t> (hash, 14U) = 0x23)
    val _ = assertloc (bits_source<hash128_t> (hash, 15U) = 0x04)
    val _ = assertloc (bits_source<hash128_t> (hash, 16U) = 0x2F)
    val _ = assertloc (bits_source<hash128_t> (hash, 17U) = 0x3B)
    val _ = assertloc (bits_source<hash128_t> (hash, 18U) = 0x1B)
    val _ = assertloc (bits_source<hash128_t> (hash, 19U) = 0x2B)
    val _ = assertloc (bits_source<hash128_t> (hash, 20U) = 0x1E)
    val _ = assertloc (bits_source<hash128_t> (hash, 21U) = 0x03)
    val _ = assertloc (bits_source<hash128_t> (hash, 22U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<hash128_t> (hash, 23U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<hash128_t> (hash, 24U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<hash128_t> (hash, 25U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<hash128_t> (hash, 26U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<hash128_t> (hash, 27U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<hash128_t> (hash, 28U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<hash128_t> (hash, 29U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<hash128_t> (hash, 30U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<hash128_t> (hash, 31U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<hash128_t> (hash, 32U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<hash128_t> (hash, 33U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<hash128_t> (hash, 34U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<hash128_t> (hash, 35U) = BITS_SOURCE_EXHAUSTED)
    val _ = assertloc (bits_source<hash128_t> (hash, 100U) = BITS_SOURCE_EXHAUSTED)
  }

implement
main0 () =
  {
    val _ = test_num_bits_eq_6 ()
  }
