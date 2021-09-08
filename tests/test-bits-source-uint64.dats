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

macdef cast64 = $UNSAFE.cast{uint64}

fn
test_num_bits_eq_4 () : void =
  {
    val hash = cast64 0xBA5EBA11FACEF00DU
    val bits_source = make_bits_source_uint64 (4U)

    fn
    source_func (bits_source : !bits_source_cloptr (uint64, 4) >> _,
                 hash        : uint64,
                 depth       : uint) :
        [bits : int]
        (BITS_SOURCE_BITS (4, bits) | int bits) =
      let
        var h = hash
      in
        bits_source (h, depth)
      end
    macdef source (hash, depth) =
      source_func (bits_source, ,(hash), ,(depth))

    val _ =
      let
        var i : [i : nat] uint i
        var u : uint64 = cast64 0
        var factor : uint64 = cast64 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast64 (source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast64 16U)
          end;
        assertloc (u = hash)
      end

    val _ = assertloc ((source (hash, 0U)).1 = 0xD)
    val _ = assertloc ((source (hash, 1U)).1 = 0x0)
    val _ = assertloc ((source (hash, 2U)).1 = 0x0)
    val _ = assertloc ((source (hash, 3U)).1 = 0xF)
    val _ = assertloc ((source (hash, 4U)).1 = 0xE)
    val _ = assertloc ((source (hash, 5U)).1 = 0xC)
    val _ = assertloc ((source (hash, 6U)).1 = 0xA)
    val _ = assertloc ((source (hash, 7U)).1 = 0xF)
    val _ = assertloc ((source (hash, 8U)).1 = 0x1)
    val _ = assertloc ((source (hash, 9U)).1 = 0x1)
    val _ = assertloc ((source (hash, 10U)).1 = 0xA)
    val _ = assertloc ((source (hash, 11U)).1 = 0xB)
    val _ = assertloc ((source (hash, 12U)).1 = 0xE)
    val _ = assertloc ((source (hash, 13U)).1 = 0x5)
    val _ = assertloc ((source (hash, 14U)).1 = 0xA)
    val _ = assertloc ((source (hash, 15U)).1 = 0xB)
    val _ = assertloc ((source (hash, 16U)).1 = ~1)
    val _ = assertloc ((source (hash, 17U)).1 = ~1)
    val _ = assertloc ((source (hash, 18U)).1 = ~1)
    val _ = assertloc ((source (hash, 19U)).1 = ~1)
    val _ = assertloc ((source (hash, 20U)).1 = ~1)
    val _ = assertloc ((source (hash, 21U)).1 = ~1)
    val _ = assertloc ((source (hash, 22U)).1 = ~1)
    val _ = assertloc ((source (hash, 100U)).1 = ~1)

    val _ = free (bits_source)
  }

fn
test_num_bits_eq_5 () : void =
  {
    val hash = cast64 0xBA5EBA11FACEF00DU
    val bits_source = make_bits_source_uint64 (5U)

    fn
    source_func (bits_source : !bits_source_cloptr (uint64, 5) >> _,
                 hash        : uint64,
                 depth       : uint) :
        [bits : int]
        (BITS_SOURCE_BITS (5, bits) | int bits) =
      let
        var h = hash
      in
        bits_source (h, depth)
      end
    macdef source (hash, depth) =
      source_func (bits_source, ,(hash), ,(depth))

    val _ =
      let
        var i : [i : nat] uint i
        var u : uint64 = cast64 0
        var factor : uint64 = cast64 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast64 (source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast64 32U)
          end;
        assertloc (u = hash)
      end

    val _ = assertloc ((source (hash, 0U)).1 = 13)
    val _ = assertloc ((source (hash, 1U)).1 = 0)
    val _ = assertloc ((source (hash, 2U)).1 = 28)
    val _ = assertloc ((source (hash, 3U)).1 = 29)
    val _ = assertloc ((source (hash, 4U)).1 = 12)
    val _ = assertloc ((source (hash, 5U)).1 = 29)
    val _ = assertloc ((source (hash, 6U)).1 = 7)
    val _ = assertloc ((source (hash, 7U)).1 = 2)
    val _ = assertloc ((source (hash, 8U)).1 = 26)
    val _ = assertloc ((source (hash, 9U)).1 = 21)
    val _ = assertloc ((source (hash, 10U)).1 = 23)
    val _ = assertloc ((source (hash, 11U)).1 = 20)
    val _ = assertloc ((source (hash, 12U)).1 = 11)
    val _ = assertloc ((source (hash, 13U)).1 = ~1)
    val _ = assertloc ((source (hash, 14U)).1 = ~1)
    val _ = assertloc ((source (hash, 15U)).1 = ~1)
    val _ = assertloc ((source (hash, 100U)).1 = ~1)

    val _ = free (bits_source)
  }

fn
test_num_bits_eq_6 () : void =
  {
    val hash = cast64 0xBA5EBA11FACEF00DU
    val bits_source = make_bits_source_uint64 (6U)

    fn
    source_func (bits_source : !bits_source_cloptr (uint64, 6) >> _,
                 hash        : uint64,
                 depth       : uint) :
        [bits : int]
        (BITS_SOURCE_BITS (6, bits) | int bits) =
      let
        var h = hash
      in
        bits_source (h, depth)
      end
    macdef source (hash, depth) =
      source_func (bits_source, ,(hash), ,(depth))

    val _ =
      let
        var i : [i : nat] uint i
        var u : uint64 = cast64 0
        var factor : uint64 = cast64 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast64 (source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast64 64U)
          end;
        assertloc (u = hash)
      end

    val _ = assertloc ((source (hash, 0U)).1 = 13)
    val _ = assertloc ((source (hash, 1U)).1 = 0)
    val _ = assertloc ((source (hash, 2U)).1 = 47)
    val _ = assertloc ((source (hash, 3U)).1 = 51)
    val _ = assertloc ((source (hash, 4U)).1 = 58)
    val _ = assertloc ((source (hash, 5U)).1 = 7)
    val _ = assertloc ((source (hash, 6U)).1 = 33)
    val _ = assertloc ((source (hash, 7U)).1 = 46)
    val _ = assertloc ((source (hash, 8U)).1 = 30)
    val _ = assertloc ((source (hash, 9U)).1 = 41)
    val _ = assertloc ((source (hash, 10U)).1 = 11)
    val _ = assertloc ((source (hash, 11U)).1 = ~1)
    val _ = assertloc ((source (hash, 12U)).1 = ~1)
    val _ = assertloc ((source (hash, 13U)).1 = ~1)
    val _ = assertloc ((source (hash, 14U)).1 = ~1)
    val _ = assertloc ((source (hash, 100U)).1 = ~1)

    val _ = free (bits_source)
  }

fn
test_num_bits_eq_7 () : void =
  {
    val hash = cast64 0xBA5EBA11FACEF00DU
    val bits_source = make_bits_source_uint64 (7U)

    fn
    source_func (bits_source : !bits_source_cloptr (uint64, 7) >> _,
                 hash        : uint64,
                 depth       : uint) :
        [bits : int]
        (BITS_SOURCE_BITS (7, bits) | int bits) =
      let
        var h = hash
      in
        bits_source (h, depth)
      end
    macdef source (hash, depth) =
      source_func (bits_source, ,(hash), ,(depth))

    val _ =
      let
        var i : [i : nat] uint i
        var u : uint64 = cast64 0
        var factor : uint64 = cast64 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast64 (source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast64 128U)
          end;
        assertloc (u = hash)
      end

    val _ = assertloc ((source (hash, 0U)).1 = 13)
    val _ = assertloc ((source (hash, 1U)).1 = 96)
    val _ = assertloc ((source (hash, 2U)).1 = 59)
    val _ = assertloc ((source (hash, 3U)).1 = 86)
    val _ = assertloc ((source (hash, 4U)).1 = 31)
    val _ = assertloc ((source (hash, 5U)).1 = 66)
    val _ = assertloc ((source (hash, 6U)).1 = 46)
    val _ = assertloc ((source (hash, 7U)).1 = 47)
    val _ = assertloc ((source (hash, 8U)).1 = 58)
    val _ = assertloc ((source (hash, 9U)).1 = 1)
    val _ = assertloc ((source (hash, 10U)).1 = ~1)
    val _ = assertloc ((source (hash, 11U)).1 = ~1)
    val _ = assertloc ((source (hash, 12U)).1 = ~1)
    val _ = assertloc ((source (hash, 13U)).1 = ~1)
    val _ = assertloc ((source (hash, 14U)).1 = ~1)
    val _ = assertloc ((source (hash, 100U)).1 = ~1)

    val _ = free (bits_source)
  }

fn
test_num_bits_eq_8 () : void =
  {
    val hash = cast64 0xBA5EBA11FACEF00DU
    val bits_source = make_bits_source_uint64 (8U)

    fn
    source_func (bits_source : !bits_source_cloptr (uint64, 8) >> _,
                 hash        : uint64,
                 depth       : uint) :
        [bits : int]
        (BITS_SOURCE_BITS (8, bits) | int bits) =
      let
        var h = hash
      in
        bits_source (h, depth)
      end
    macdef source (hash, depth) =
      source_func (bits_source, ,(hash), ,(depth))

    val _ =
      let
        var i : [i : nat] uint i
        var u : uint64 = cast64 0
        var factor : uint64 = cast64 1
      in
        for (i := 0U; i < 35U; i := succ i)
          let
            val bits = cast64 (source (hash, i)).1
          in
            u := u + (bits * factor);
            factor := factor * (cast64 256U)
          end;
        assertloc (u = hash)
      end

    val _ = assertloc ((source (hash, 0U)).1 = 0x0D)
    val _ = assertloc ((source (hash, 1U)).1 = 0xF0)
    val _ = assertloc ((source (hash, 2U)).1 = 0xCE)
    val _ = assertloc ((source (hash, 3U)).1 = 0xFA)
    val _ = assertloc ((source (hash, 4U)).1 = 0x11)
    val _ = assertloc ((source (hash, 5U)).1 = 0xBA)
    val _ = assertloc ((source (hash, 6U)).1 = 0x5E)
    val _ = assertloc ((source (hash, 7U)).1 = 0xBA)
    val _ = assertloc ((source (hash, 8U)).1 = ~1)
    val _ = assertloc ((source (hash, 9U)).1 = ~1)
    val _ = assertloc ((source (hash, 10U)).1 = ~1)
    val _ = assertloc ((source (hash, 100U)).1 = ~1)

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
