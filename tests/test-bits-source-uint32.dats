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

macdef cast32 = $UNSAFE.cast{uint32}

fn
test_num_bits_eq_4 () : void =
  {
    val hash = cast32 0x12345678U
    val bits_source = make_bits_source_uint32 (4U)
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint32 = cast32 0
        var factor : uint32 = cast32 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast32 (bits_source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast32 16U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc ((bits_source (hash, 0U)).1 = 8)
    val _ = assertloc ((bits_source (hash, 1U)).1 = 7)
    val _ = assertloc ((bits_source (hash, 2U)).1 = 6)
    val _ = assertloc ((bits_source (hash, 3U)).1 = 5)
    val _ = assertloc ((bits_source (hash, 4U)).1 = 4)
    val _ = assertloc ((bits_source (hash, 5U)).1 = 3)
    val _ = assertloc ((bits_source (hash, 6U)).1 = 2)
    val _ = assertloc ((bits_source (hash, 7U)).1 = 1)
    val _ = assertloc ((bits_source (hash, 8U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 9U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 10U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 11U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 100U)).1 = ~1)
    val _ = free (bits_source)

    val hash = cast32 0xDEADBEEFU
    val bits_source = make_bits_source_uint32 (4U)
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint32 = cast32 0
        var factor : uint32 = cast32 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast32 (bits_source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast32 16U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc ((bits_source (hash, 0U)).1 = 0xF)
    val _ = assertloc ((bits_source (hash, 1U)).1 = 0xE)
    val _ = assertloc ((bits_source (hash, 2U)).1 = 0xE)
    val _ = assertloc ((bits_source (hash, 3U)).1 = 0xB)
    val _ = assertloc ((bits_source (hash, 4U)).1 = 0xD)
    val _ = assertloc ((bits_source (hash, 5U)).1 = 0xA)
    val _ = assertloc ((bits_source (hash, 6U)).1 = 0xE)
    val _ = assertloc ((bits_source (hash, 7U)).1 = 0xD)
    val _ = assertloc ((bits_source (hash, 8U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 9U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 10U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 11U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 100U)).1 = ~1)
    val _ = free (bits_source)
  }

fn
test_num_bits_eq_5 () : void =
  {
    val hash = cast32 0x12345678U
    val bits_source = make_bits_source_uint32 (5U)
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint32 = cast32 0
        var factor : uint32 = cast32 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast32 (bits_source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast32 32U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc ((bits_source (hash, 0U)).1 = 0x18)
    val _ = assertloc ((bits_source (hash, 1U)).1 = 0x13)
    val _ = assertloc ((bits_source (hash, 2U)).1 = 0x15)
    val _ = assertloc ((bits_source (hash, 3U)).1 = 0x08)
    val _ = assertloc ((bits_source (hash, 4U)).1 = 0x03)
    val _ = assertloc ((bits_source (hash, 5U)).1 = 0x09)
    val _ = assertloc ((bits_source (hash, 6U)).1 = 0x00)
    val _ = assertloc ((bits_source (hash, 7U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 8U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 9U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 10U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 11U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 100U)).1 = ~1)
    val _ = free (bits_source)

    val hash = cast32 0xDEADBEEFU
    val bits_source = make_bits_source_uint32 (5U)
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint32 = cast32 0
        var factor : uint32 = cast32 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast32 (bits_source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast32 32U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc ((bits_source (hash, 0U)).1 = 0x0F)
    val _ = assertloc ((bits_source (hash, 1U)).1 = 0x17)
    val _ = assertloc ((bits_source (hash, 2U)).1 = 0x0F)
    val _ = assertloc ((bits_source (hash, 3U)).1 = 0x1B)
    val _ = assertloc ((bits_source (hash, 4U)).1 = 0x0A)
    val _ = assertloc ((bits_source (hash, 5U)).1 = 0x0F)
    val _ = assertloc ((bits_source (hash, 6U)).1 = 0x03)
    val _ = assertloc ((bits_source (hash, 7U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 8U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 9U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 10U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 11U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 100U)).1 = ~1)
    val _ = free (bits_source)
  }

fn
test_num_bits_eq_6 () : void =
  {
    val hash = cast32 0x12345678U
    val bits_source = make_bits_source_uint32 (6U)
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint32 = cast32 0
        var factor : uint32 = cast32 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast32 (bits_source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast32 64U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc ((bits_source (hash, 0U)).1 = 0x38)
    val _ = assertloc ((bits_source (hash, 1U)).1 = 0x19)
    val _ = assertloc ((bits_source (hash, 2U)).1 = 0x05)
    val _ = assertloc ((bits_source (hash, 3U)).1 = 0x0D)
    val _ = assertloc ((bits_source (hash, 4U)).1 = 0x12)
    val _ = assertloc ((bits_source (hash, 5U)).1 = 0x00)
    val _ = assertloc ((bits_source (hash, 6U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 7U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 8U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 9U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 10U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 11U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 100U)).1 = ~1)
    val _ = free (bits_source)

    val hash = cast32 0xDEADBEEFU
    val bits_source = make_bits_source_uint32 (6U)
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint32 = cast32 0
        var factor : uint32 = cast32 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast32 (bits_source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast32 64U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc ((bits_source (hash, 0U)).1 = 0x2F)
    val _ = assertloc ((bits_source (hash, 1U)).1 = 0x3B)
    val _ = assertloc ((bits_source (hash, 2U)).1 = 0x1B)
    val _ = assertloc ((bits_source (hash, 3U)).1 = 0x2B)
    val _ = assertloc ((bits_source (hash, 4U)).1 = 0x1E)
    val _ = assertloc ((bits_source (hash, 5U)).1 = 0x03)
    val _ = assertloc ((bits_source (hash, 6U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 7U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 8U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 9U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 10U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 11U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 100U)).1 = ~1)
    val _ = free (bits_source)
  }

fn
test_num_bits_eq_7 () : void =
  {
    val hash = cast32 0x12345678U
    val bits_source = make_bits_source_uint32 (7U)
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint32 = cast32 0
        var factor : uint32 = cast32 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast32 (bits_source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast32 128U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc ((bits_source (hash, 0U)).1 = 0x78)
    val _ = assertloc ((bits_source (hash, 1U)).1 = 0x2C)
    val _ = assertloc ((bits_source (hash, 2U)).1 = 0x51)
    val _ = assertloc ((bits_source (hash, 3U)).1 = 0x11)
    val _ = assertloc ((bits_source (hash, 4U)).1 = 0x01)
    val _ = assertloc ((bits_source (hash, 5U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 6U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 7U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 8U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 9U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 10U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 11U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 100U)).1 = ~1)
    val _ = free (bits_source)

    val hash = cast32 0xDEADBEEFU
    val bits_source = make_bits_source_uint32 (7U)
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint32 = cast32 0
        var factor : uint32 = cast32 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast32 (bits_source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast32 128U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc ((bits_source (hash, 0U)).1 = 0x6F)
    val _ = assertloc ((bits_source (hash, 1U)).1 = 0x7D)
    val _ = assertloc ((bits_source (hash, 2U)).1 = 0x36)
    val _ = assertloc ((bits_source (hash, 3U)).1 = 0x75)
    val _ = assertloc ((bits_source (hash, 4U)).1 = 0x0D)
    val _ = assertloc ((bits_source (hash, 5U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 6U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 7U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 8U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 9U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 10U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 11U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 100U)).1 = ~1)
    val _ = free (bits_source)
  }

fn
test_num_bits_eq_8 () : void =
  {
    val hash = cast32 0x12345678U
    val bits_source = make_bits_source_uint32 (8U)
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint32 = cast32 0
        var factor : uint32 = cast32 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast32 (bits_source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast32 256U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc ((bits_source (hash, 0U)).1 = 0x78)
    val _ = assertloc ((bits_source (hash, 1U)).1 = 0x56)
    val _ = assertloc ((bits_source (hash, 2U)).1 = 0x34)
    val _ = assertloc ((bits_source (hash, 3U)).1 = 0x12)
    val _ = assertloc ((bits_source (hash, 4U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 5U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 6U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 7U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 8U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 9U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 10U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 100U)).1 = ~1)
    val _ = free (bits_source)

    val hash = cast32 0xDEADBEEFU
    val bits_source = make_bits_source_uint32 (8U)
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint32 = cast32 0
        var factor : uint32 = cast32 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast32 (bits_source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast32 256U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc ((bits_source (hash, 0U)).1 = 0xEF)
    val _ = assertloc ((bits_source (hash, 1U)).1 = 0xBE)
    val _ = assertloc ((bits_source (hash, 2U)).1 = 0xAD)
    val _ = assertloc ((bits_source (hash, 3U)).1 = 0xDE)
    val _ = assertloc ((bits_source (hash, 4U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 5U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 6U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 7U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 8U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 9U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 10U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 100U)).1 = ~1)
    val _ = free (bits_source)
  }

implement
main0 () =
  {
    val _ = test_num_bits_eq_4 ()
    val _ = test_num_bits_eq_5 ()
    val _ = test_num_bits_eq_6 ()
    val _ = test_num_bits_eq_7 ()
    val _ = test_num_bits_eq_8 ()
  }
