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

staload "hashmap/SATS/popcount.sats"
staload _ = "hashmap/DATS/popcount.dats"

typedef uintmax = $extype"uintmax_t"

%{^

static int
brute_force_popcount_low_bits_uintmax (uintmax_t u, unsigned int i)
{
  int count = 0;
  while (i != 0)
    {
      count += ((u & 1) != 0);
      u >>= 1;
      i -= 1;
    }
  return count;
}

%}

macdef brute_force_popcount_low_bits (u, i) =
  $extfcall (int, "brute_force_popcount_low_bits_uintmax", ,(u), ,(i))

fn {tk : tkind}
test_popcount (u : g0uint (tk)) : bool =
  let
    val b1 =
      brute_force_popcount_low_bits
        (u, (i2sz 8) * sizeof<g0uint (tk)>)
    val (_ | b2) = popcount<tk> (g1ofg0 u)
    val b3 = popcount<tk> (u)
  in
    ((g1ofg0 b1) = b2) && (b1 = b3)
  end

fn {tk : tkind}
test_popcount_low_bits (u : g0uint (tk)) : bool =
  let
    var result : bool = true
    var j : [j : int | 0 <= j] int j
    val n = 8 * (sz2i sizeof<g0uint (tk)>)
  in
    for (j := 0; j < n; j := succ j)
      let
        val j1 = min (n, j)
        val b1 = brute_force_popcount_low_bits (u, j1)
        val (_ | b2) = popcount_low_bits<tk> (g1ofg0 u, i2u j)
        val b3 = popcount_low_bits<tk> (u, g0ofg1 (i2u j))
      in
        result := result && ((g1ofg0 b1) = b2) && (b1 = b3)
      end;
    result
  end

implement
main0 () =
  {
    var test_numbers : @[uint64][100] =
      (* A list of randomly chosen numbers. *)
      @[uint64][100] ($UNSAFE.cast 0xBA0A47B98D803A39,
                      $UNSAFE.cast 0x4F15E0617975FCE2,
                      $UNSAFE.cast 0x1D3BFB0532987994,
                      $UNSAFE.cast 0xD6936BC4CC7AF63D,
                      $UNSAFE.cast 0x3A3B14B93F484C69,
                      $UNSAFE.cast 0x224CF13020CACF75,
                      $UNSAFE.cast 0x362C2BC7749EC143,
                      $UNSAFE.cast 0x5C3F8670D10D76AA,
                      $UNSAFE.cast 0x7DF6A1F8E0B83879,
                      $UNSAFE.cast 0x28DED311ACEF3E56,
                      $UNSAFE.cast 0xD405F2E0F8267A44,
                      $UNSAFE.cast 0x4A0BB18229388BF6,
                      $UNSAFE.cast 0xF3B3D0A4AF3CBF9D,
                      $UNSAFE.cast 0xB5475883330529E4,
                      $UNSAFE.cast 0x67E3E5066F88FB90,
                      $UNSAFE.cast 0xA676DE4AC2F8420B,
                      $UNSAFE.cast 0xFEDF419C68B328AD,
                      $UNSAFE.cast 0x56FDF2C5BC7311D8,
                      $UNSAFE.cast 0x35E183F30E2BB175,
                      $UNSAFE.cast 0xD86F184137273749,
                      $UNSAFE.cast 0xB8DF2572130C48A,
                      $UNSAFE.cast 0xB518E7DE7894EF33,
                      $UNSAFE.cast 0x69CCEBC9D12D1B3A,
                      $UNSAFE.cast 0xBF0813BC9351C266,
                      $UNSAFE.cast 0xBB8F800236566AAE,
                      $UNSAFE.cast 0x38E0D9F27250CC4E,
                      $UNSAFE.cast 0x3F17707381EC8F1D,
                      $UNSAFE.cast 0xE84AD9D11F7144BA,
                      $UNSAFE.cast 0xB2AD3D0ADE07789A,
                      $UNSAFE.cast 0xEA328CD56E56CC74,
                      $UNSAFE.cast 0x350823150E6CD3E1,
                      $UNSAFE.cast 0x4B759D1556096162,
                      $UNSAFE.cast 0x5488C415A5F92FD6,
                      $UNSAFE.cast 0xC2CBA02D8B07AE54,
                      $UNSAFE.cast 0xECC2E5547959FDFC,
                      $UNSAFE.cast 0x1962266DA0807D59,
                      $UNSAFE.cast 0x59FA6706A3DF1593,
                      $UNSAFE.cast 0x39250E991D1372B4,
                      $UNSAFE.cast 0x3FA8B8A06858BC02,
                      $UNSAFE.cast 0xF1EDE553DCB48C03,
                      $UNSAFE.cast 0x1BD77D8CD412F2B,
                      $UNSAFE.cast 0x84E58F9DE2495FF1,
                      $UNSAFE.cast 0xA010C0BA85ACE75B,
                      $UNSAFE.cast 0x471D3AAE2054D454,
                      $UNSAFE.cast 0x3DEBCA54212E5F32,
                      $UNSAFE.cast 0xB8C71CA417FAC5CB,
                      $UNSAFE.cast 0x6918CD755D9D1C15,
                      $UNSAFE.cast 0x16444C4C336731F6,
                      $UNSAFE.cast 0x95A396845BDAF7C0,
                      $UNSAFE.cast 0xAE26A5CFBA90C52C,
                      $UNSAFE.cast 0x815B595121E2D7A1,
                      $UNSAFE.cast 0x8CA6704D7C3854AF,
                      $UNSAFE.cast 0x311BE7D7221964EE,
                      $UNSAFE.cast 0x3770231646B280C,
                      $UNSAFE.cast 0x5ED5F5CF8A5995E0,
                      $UNSAFE.cast 0x1A81F42896277578,
                      $UNSAFE.cast 0x66C2AB8B652B67A8,
                      $UNSAFE.cast 0xEF0A8CF0DA4833D7,
                      $UNSAFE.cast 0xFAA57ACBCBA6B863,
                      $UNSAFE.cast 0x1DC3DEFB8971F8F7,
                      $UNSAFE.cast 0xA6796849D3538BA2,
                      $UNSAFE.cast 0x112C601245BA11FC,
                      $UNSAFE.cast 0xBDD4ABE4BCB0441A,
                      $UNSAFE.cast 0xE4C2FEDBA50F44FC,
                      $UNSAFE.cast 0x1EF06459980B9ABC,
                      $UNSAFE.cast 0xD2FC79A8B633D063,
                      $UNSAFE.cast 0x9EC4261D2DDD796,
                      $UNSAFE.cast 0xE515E6B9163E61C,
                      $UNSAFE.cast 0xF00375CBDFA008BD,
                      $UNSAFE.cast 0xC5C19D6999DD6FA0,
                      $UNSAFE.cast 0x2A3C07D99F66ACE,
                      $UNSAFE.cast 0x13C95EDADE1AC541,
                      $UNSAFE.cast 0x161FF4F8BC5B25E5,
                      $UNSAFE.cast 0x3CB08C11488E37AA,
                      $UNSAFE.cast 0x7F47A5F3D0737D52,
                      $UNSAFE.cast 0x8B25D096A87F10F0,
                      $UNSAFE.cast 0x27506C7D1C3B9BD,
                      $UNSAFE.cast 0x603B6C9309E44F2A,
                      $UNSAFE.cast 0x8CB8975C2944833E,
                      $UNSAFE.cast 0x2041BFDAC8892DD,
                      $UNSAFE.cast 0x68A3F63BDB2A11FE,
                      $UNSAFE.cast 0x31515E2DD30CF0A1,
                      $UNSAFE.cast 0xC45201486234239E,
                      $UNSAFE.cast 0x2EA50B3EDD00613,
                      $UNSAFE.cast 0xA95469D777302DB7,
                      $UNSAFE.cast 0x5116F82BF55D1859,
                      $UNSAFE.cast 0x146A0F2C9E585DA3,
                      $UNSAFE.cast 0xD775A83FF502A470,
                      $UNSAFE.cast 0xB42A7FD7992C4985,
                      $UNSAFE.cast 0x66B8CA23CDC20055,
                      $UNSAFE.cast 0x803A8F491EAA972C,
                      $UNSAFE.cast 0xEFB008AC23E52EE6,
                      $UNSAFE.cast 0x8E178365ECC9E93F,
                      $UNSAFE.cast 0x608AAC2B3F9C9954,
                      $UNSAFE.cast 0x1EB6289488CDBA7B,
                      $UNSAFE.cast 0xA10B04815E3FA15A,
                      $UNSAFE.cast 0xC4C6BF1E500409A9,
                      $UNSAFE.cast 0x36D8681C224F588E,
                      $UNSAFE.cast 0xBE42D9C89583950,
                      $UNSAFE.cast 0x245843F08774E2A1)
    var i : [i : nat | i <= 100] int i

    (* Test popcount() *)
    val _ =
      for (i := 0; i < 100; i := succ i)
        assertloc (test_popcount<usintknd> ($UNSAFE.cast{usint} (test_numbers[i])))
    val _ =
      for (i := 0; i < 100; i := succ i)
        assertloc (test_popcount<uintknd> ($UNSAFE.cast{uint} (test_numbers[i])))
    val _ =
      for (i := 0; i < 100; i := succ i)
        assertloc (test_popcount<ulintknd> ($UNSAFE.cast{ulint} (test_numbers[i])))
    val _ =
      for (i := 0; i < 100; i := succ i)
        assertloc (test_popcount<ullintknd> ($UNSAFE.cast{ullint} (test_numbers[i])))
    val _ =
      for (i := 0; i < 100; i := succ i)
        assertloc (test_popcount<sizeknd> ($UNSAFE.cast{size_t} (test_numbers[i])))
    val _ =
      for (i := 0; i < 100; i := succ i)
        assertloc (test_popcount<uintptrknd> ($UNSAFE.cast{uintptr} (test_numbers[i])))
    val _ =
      for (i := 0; i < 100; i := succ i)
        assertloc (test_popcount<uint8knd> ($UNSAFE.cast{uint8} (test_numbers[i])))
    val _ =
      for (i := 0; i < 100; i := succ i)
        assertloc (test_popcount<uint16knd> ($UNSAFE.cast{uint16} (test_numbers[i])))
    val _ =
      for (i := 0; i < 100; i := succ i)
        assertloc (test_popcount<uint32knd> ($UNSAFE.cast{uint32} (test_numbers[i])))
    val _ =
      for (i := 0; i < 100; i := succ i)
        assertloc (test_popcount<uint64knd> ($UNSAFE.cast{uint64} (test_numbers[i])))

    (* Test popcount_low_bits() *)
    val _ =
      for (i := 0; i < 100; i := succ i)
        assertloc (test_popcount_low_bits<usintknd> ($UNSAFE.cast{usint} (test_numbers[i])))
    val _ =
      for (i := 0; i < 100; i := succ i)
        assertloc (test_popcount_low_bits<uintknd> ($UNSAFE.cast{uint} (test_numbers[i])))
    val _ =
      for (i := 0; i < 100; i := succ i)
        assertloc (test_popcount_low_bits<ulintknd> ($UNSAFE.cast{ulint} (test_numbers[i])))
    val _ =
      for (i := 0; i < 100; i := succ i)
        assertloc (test_popcount_low_bits<ullintknd> ($UNSAFE.cast{ullint} (test_numbers[i])))
    val _ =
      for (i := 0; i < 100; i := succ i)
        assertloc (test_popcount_low_bits<sizeknd> ($UNSAFE.cast{size_t} (test_numbers[i])))
    val _ =
      for (i := 0; i < 100; i := succ i)
        assertloc (test_popcount_low_bits<uintptrknd> ($UNSAFE.cast{uintptr} (test_numbers[i])))
    val _ =
      for (i := 0; i < 100; i := succ i)
        assertloc (test_popcount_low_bits<uint8knd> ($UNSAFE.cast{uint8} (test_numbers[i])))
    val _ =
      for (i := 0; i < 100; i := succ i)
        assertloc (test_popcount_low_bits<uint16knd> ($UNSAFE.cast{uint16} (test_numbers[i])))
    val _ =
      for (i := 0; i < 100; i := succ i)
        assertloc (test_popcount_low_bits<uint32knd> ($UNSAFE.cast{uint32} (test_numbers[i])))
    val _ =
      for (i := 0; i < 100; i := succ i)
        assertloc (test_popcount_low_bits<uint64knd> ($UNSAFE.cast{uint64} (test_numbers[i])))
  }
