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

staload "hashmap/SATS/bits-source.sats"

macdef cloptr_free_unsafe (func) =
  cloptr_free ($UNSAFE.castvwtp0{cloptr0} ,(func))

fn
test_num_bits_eq_4 () : void =
  {
    val hash : uint32 = $UNSAFE.cast 0x12345678U
    val bits_source = make_bits_source_uint32 (4U, hash)
    val _ = assertloc (bits_source (0U) = 8)
    val _ = assertloc (bits_source (1U) = 7)
    val _ = assertloc (bits_source (2U) = 6)
    val _ = assertloc (bits_source (3U) = 5)
    val _ = assertloc (bits_source (4U) = 4)
    val _ = assertloc (bits_source (5U) = 3)
    val _ = assertloc (bits_source (6U) = 2)
    val _ = assertloc (bits_source (7U) = 1)
    val _ = assertloc (bits_source (8U) = ~1)
    val _ = assertloc (bits_source (9U) = ~1)
    val _ = assertloc (bits_source (10U) = ~1)
    val _ = assertloc (bits_source (11U) = ~1)
    val _ = assertloc (bits_source (100U) = ~1)
    val _ = cloptr_free_unsafe (bits_source)

    val hash : uint32 = $UNSAFE.cast 0xDEADBEEFU
    val bits_source = make_bits_source_uint32 (4U, hash)
    val _ = assertloc (bits_source (0U) = 0xF)
    val _ = assertloc (bits_source (1U) = 0xE)
    val _ = assertloc (bits_source (2U) = 0xE)
    val _ = assertloc (bits_source (3U) = 0xB)
    val _ = assertloc (bits_source (4U) = 0xD)
    val _ = assertloc (bits_source (5U) = 0xA)
    val _ = assertloc (bits_source (6U) = 0xE)
    val _ = assertloc (bits_source (7U) = 0xD)
    val _ = assertloc (bits_source (8U) = ~1)
    val _ = assertloc (bits_source (9U) = ~1)
    val _ = assertloc (bits_source (10U) = ~1)
    val _ = assertloc (bits_source (11U) = ~1)
    val _ = assertloc (bits_source (100U) = ~1)
    val _ = cloptr_free_unsafe (bits_source)
  }

fn
test_num_bits_eq_5 () : void =
  {
    val hash : uint32 = $UNSAFE.cast 0x12345678U
    val bits_source = make_bits_source_uint32 (5U, hash)
    val _ = assertloc (bits_source (0U) = 0x18)
    val _ = assertloc (bits_source (1U) = 0x13)
    val _ = assertloc (bits_source (2U) = 0x15)
    val _ = assertloc (bits_source (3U) = 0x08)
    val _ = assertloc (bits_source (4U) = 0x03)
    val _ = assertloc (bits_source (5U) = 0x09)
    val _ = assertloc (bits_source (6U) = 0x00)
    val _ = assertloc (bits_source (7U) = ~1)
    val _ = assertloc (bits_source (8U) = ~1)
    val _ = assertloc (bits_source (9U) = ~1)
    val _ = assertloc (bits_source (10U) = ~1)
    val _ = assertloc (bits_source (100U) = ~1)
    val _ = cloptr_free_unsafe (bits_source)

    val hash : uint32 = $UNSAFE.cast 0xDEADBEEFU
    val bits_source = make_bits_source_uint32 (5U, hash)
    val _ = assertloc (bits_source (0U) = 0x0F)
    val _ = assertloc (bits_source (1U) = 0x17)
    val _ = assertloc (bits_source (2U) = 0x0F)
    val _ = assertloc (bits_source (3U) = 0x1B)
    val _ = assertloc (bits_source (4U) = 0x0A)
    val _ = assertloc (bits_source (5U) = 0x0F)
    val _ = assertloc (bits_source (6U) = 0x03)
    val _ = assertloc (bits_source (7U) = ~1)
    val _ = assertloc (bits_source (8U) = ~1)
    val _ = assertloc (bits_source (9U) = ~1)
    val _ = assertloc (bits_source (10U) = ~1)
    val _ = assertloc (bits_source (100U) = ~1)
    val _ = cloptr_free_unsafe (bits_source)
  }

fn
test_num_bits_eq_6 () : void =
  {
    val hash : uint32 = $UNSAFE.cast 0x12345678U
    val bits_source = make_bits_source_uint32 (6U, hash)
    val _ = assertloc (bits_source (0U) = 0x38)
    val _ = assertloc (bits_source (1U) = 0x19)
    val _ = assertloc (bits_source (2U) = 0x05)
    val _ = assertloc (bits_source (3U) = 0x0D)
    val _ = assertloc (bits_source (4U) = 0x12)
    val _ = assertloc (bits_source (5U) = 0x00)
    val _ = assertloc (bits_source (6U) = ~1)
    val _ = assertloc (bits_source (7U) = ~1)
    val _ = assertloc (bits_source (8U) = ~1)
    val _ = assertloc (bits_source (9U) = ~1)
    val _ = assertloc (bits_source (10U) = ~1)
    val _ = assertloc (bits_source (100U) = ~1)
    val _ = cloptr_free_unsafe (bits_source)

    val hash : uint32 = $UNSAFE.cast 0xDEADBEEFU
    val bits_source = make_bits_source_uint32 (6U, hash)
    val _ = assertloc (bits_source (0U) = 0x2F)
    val _ = assertloc (bits_source (1U) = 0x3B)
    val _ = assertloc (bits_source (2U) = 0x1B)
    val _ = assertloc (bits_source (3U) = 0x2B)
    val _ = assertloc (bits_source (4U) = 0x1E)
    val _ = assertloc (bits_source (5U) = 0x03)
    val _ = assertloc (bits_source (6U) = ~1)
    val _ = assertloc (bits_source (7U) = ~1)
    val _ = assertloc (bits_source (8U) = ~1)
    val _ = assertloc (bits_source (9U) = ~1)
    val _ = assertloc (bits_source (10U) = ~1)
    val _ = assertloc (bits_source (100U) = ~1)
    val _ = cloptr_free_unsafe (bits_source)
  }

implement
main0 () =
  {
    val _ = test_num_bits_eq_4 ()
    val _ = test_num_bits_eq_5 ()
    val _ = test_num_bits_eq_6 ()
  }
