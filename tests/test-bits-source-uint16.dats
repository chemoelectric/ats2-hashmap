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

macdef cast16 = $UNSAFE.cast{uint16}

fn
test_num_bits_eq_4 () : void =
  {
    val hash = cast16 0x1234U
    val bits_source = make_bits_source_uint16 (4U)
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint16 = cast16 0
        var factor : uint16 = cast16 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast16 (bits_source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast16 16U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc ((bits_source (hash, 0U)).1 = 4)
    val _ = assertloc ((bits_source (hash, 1U)).1 = 3)
    val _ = assertloc ((bits_source (hash, 2U)).1 = 2)
    val _ = assertloc ((bits_source (hash, 3U)).1 = 1)
    val _ = assertloc ((bits_source (hash, 4U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 5U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 6U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 7U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 100U)).1 = ~1)
    val _ = free (bits_source)

    val hash = cast16 0xDEADU
    val bits_source = make_bits_source_uint16 (4U)
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint16 = cast16 0
        var factor : uint16 = cast16 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast16 (bits_source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast16 16U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc ((bits_source (hash, 0U)).1 = 0xD)
    val _ = assertloc ((bits_source (hash, 1U)).1 = 0xA)
    val _ = assertloc ((bits_source (hash, 2U)).1 = 0xE)
    val _ = assertloc ((bits_source (hash, 3U)).1 = 0xD)
    val _ = assertloc ((bits_source (hash, 4U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 5U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 6U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 7U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 100U)).1 = ~1)
    val _ = free (bits_source)
  }

fn
test_num_bits_eq_5 () : void =
  {
    val hash = cast16 0x1234U
    val bits_source = make_bits_source_uint16 (5U)
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint16 = cast16 0
        var factor : uint16 = cast16 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast16 (bits_source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast16 32U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc ((bits_source (hash, 0U)).1 = 20)
    val _ = assertloc ((bits_source (hash, 1U)).1 = 17)
    val _ = assertloc ((bits_source (hash, 2U)).1 = 4)
    val _ = assertloc ((bits_source (hash, 3U)).1 = 0)
    val _ = assertloc ((bits_source (hash, 4U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 5U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 6U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 7U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 8U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 9U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 10U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 11U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 100U)).1 = ~1)
    val _ = free (bits_source)

    val hash = cast16 0xDEADU
    val bits_source = make_bits_source_uint16 (5U)
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint16 = cast16 0
        var factor : uint16 = cast16 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast16 (bits_source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast16 32U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc ((bits_source (hash, 0U)).1 = 13)
    val _ = assertloc ((bits_source (hash, 1U)).1 = 21)
    val _ = assertloc ((bits_source (hash, 2U)).1 = 23)
    val _ = assertloc ((bits_source (hash, 3U)).1 = 1)
    val _ = assertloc ((bits_source (hash, 4U)).1 = ~1)
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
test_num_bits_eq_6 () : void =
  {
    val hash = cast16 0x1234U
    val bits_source = make_bits_source_uint16 (6U)
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint16 = cast16 0
        var factor : uint16 = cast16 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast16 (bits_source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast16 64U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc ((bits_source (hash, 0U)).1 = 52)
    val _ = assertloc ((bits_source (hash, 1U)).1 = 8)
    val _ = assertloc ((bits_source (hash, 2U)).1 = 1)
    val _ = assertloc ((bits_source (hash, 3U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 4U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 5U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 6U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 7U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 8U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 9U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 10U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 11U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 100U)).1 = ~1)
    val _ = free (bits_source)

    val hash = cast16 0xDEADU
    val bits_source = make_bits_source_uint16 (6U)
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint16 = cast16 0
        var factor : uint16 = cast16 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast16 (bits_source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast16 64U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc ((bits_source (hash, 0U)).1 = 45)
    val _ = assertloc ((bits_source (hash, 1U)).1 = 58)
    val _ = assertloc ((bits_source (hash, 2U)).1 = 13)
    val _ = assertloc ((bits_source (hash, 3U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 4U)).1 = ~1)
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
test_num_bits_eq_7 () : void =
  {
    val hash = cast16 0x1234U
    val bits_source = make_bits_source_uint16 (7U)
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint16 = cast16 0
        var factor : uint16 = cast16 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast16 (bits_source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast16 128U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc ((bits_source (hash, 0U)).1 = 52)
    val _ = assertloc ((bits_source (hash, 1U)).1 = 36)
    val _ = assertloc ((bits_source (hash, 2U)).1 = 0)
    val _ = assertloc ((bits_source (hash, 3U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 4U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 5U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 6U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 7U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 8U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 9U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 10U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 11U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 100U)).1 = ~1)
    val _ = free (bits_source)

    val hash = cast16 0xDEADU
    val bits_source = make_bits_source_uint16 (7U)
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint16 = cast16 0
        var factor : uint16 = cast16 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast16 (bits_source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast16 128U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc ((bits_source (hash, 0U)).1 = 45)
    val _ = assertloc ((bits_source (hash, 1U)).1 = 61)
    val _ = assertloc ((bits_source (hash, 2U)).1 = 3)
    val _ = assertloc ((bits_source (hash, 3U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 4U)).1 = ~1)
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
    val hash = cast16 0x1234U
    val bits_source = make_bits_source_uint16 (8U)
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint16 = cast16 0
        var factor : uint16 = cast16 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast16 (bits_source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast16 256U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc ((bits_source (hash, 0U)).1 = 0x34)
    val _ = assertloc ((bits_source (hash, 1U)).1 = 0x12)
    val _ = assertloc ((bits_source (hash, 2U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 3U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 4U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 5U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 6U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 7U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 8U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 9U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 10U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 100U)).1 = ~1)
    val _ = free (bits_source)

    val hash = cast16 0xDEADU
    val bits_source = make_bits_source_uint16 (8U)
    val _ =
      let
        var i : [i : nat] uint i
        var u : uint16 = cast16 0
        var factor : uint16 = cast16 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast16 (bits_source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast16 256U)
          end;
        assertloc (u = hash)
      end
    val _ = assertloc ((bits_source (hash, 0U)).1 = 0xAD)
    val _ = assertloc ((bits_source (hash, 1U)).1 = 0xDE)
    val _ = assertloc ((bits_source (hash, 2U)).1 = ~1)
    val _ = assertloc ((bits_source (hash, 3U)).1 = ~1)
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
