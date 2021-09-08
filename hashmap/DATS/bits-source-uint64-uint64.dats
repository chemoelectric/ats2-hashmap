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

#include "hashmap/HATS/config.hats"
#include "hashmap/HATS/bits-source-include.hats"

staload "hashmap/SATS/bits-source.sats"

%{^
#undef ats2_hashmap_bits_source_lshift
#define ats2_hashmap_bits_source_lshift(u, i) ((u) << (i))

#undef ats2_hashmap_bits_source_rshift
#define ats2_hashmap_bits_source_rshift(u, i) ((u) >> (i))

#undef ats2_hashmap_bits_source_lnot
#define ats2_hashmap_bits_source_lnot(u) (~(u))

#undef ats2_hashmap_bits_source_land
#define ats2_hashmap_bits_source_land(u, v) ((u) & (v))

#undef ats2_hashmap_bits_source_add
#define ats2_hashmap_bits_source_add(u, v) ((u) + (v))
%}

extern fn
lshift_uint {u, i : int}
            (u    : uint u,
             i    : uint i) :<>
    [v : int] uint v = "mac#ats2_hashmap_bits_source_lshift"

extern fn
lshift_uint64 {u, i : int}
              (u    : uint64 u,
               i    : uint i) :<>
    [v : int] uint64 v = "mac#ats2_hashmap_bits_source_lshift"

extern fn
rshift_uint64 {u, i : int}
              (u    : uint64 u,
               i    : uint i) :<>
    [v : int] uint64 v = "mac#ats2_hashmap_bits_source_rshift"

extern fn
lnot_uint {u : int}
          (u : uint u) :<>
    [v : int] uint v = "mac#ats2_hashmap_bits_source_lnot"

extern fn
land_uint {u, v : int}
          (u    : uint u,
           v    : uint v) :<>
    [w : int | w <= u; w <= v]
    uint w = "mac#ats2_hashmap_bits_source_land"

extern fn
add_uint64 {u, v : int}
           (u    : uint64 u,
            v    : uint64 v) :<>
    [w : int] uint64 w = "mac#ats2_hashmap_bits_source_add"

infix <<
infix >>
prefix ~
infix &
overload << with lshift_uint of 1000
overload << with lshift_uint64 of 1000
overload >> with rshift_uint64 of 1000
overload ~ with lnot_uint of 1000
overload & with land_uint of 1000
overload + with add_uint64 of 1000

extern castfn
int_of_uint : {u : int} uint u -<> int u

extern castfn
uint64_of_uint : {u : int} uint u -<> uint64 u

extern castfn
uint_of_uint64 : {u : int} uint64 u -<> uint u

fn {}
rshift_and_mask
        {i        : int}
        {num_bits, mask : int | bits_maxval (num_bits, mask)}
        (uu       : @(uint64, uint64),
         i        : uint i,
         num_bits : uint num_bits,
         mask     : uint mask) :<>
    [bits : int | bits_maxval (num_bits, bits)]
    uint bits =
  (* Shift and mask a pair of uint64, as if they were a
     128-bit number. *)
  let
    val shift_uu = num_bits * i
  in
    if shift_uu + num_bits <= 64U then
      (* All the bits are in uu.0 *)
      let
        val u_shifted = (g1ofg0 (uu.0)) >> shift_uu
      in
        (uint_of_uint64 u_shifted) & mask
      end
    else if shift_uu < 64U then
      (* The lower bits come from uu.0, and the higher
         bits from uu.1 *)
      let
        val u0_shifted = (g1ofg0 (uu.0)) >> shift_uu
        val u1_shifted = (g1ofg0 (uu.1)) << (64U - shift_uu)
        val u_shifted = u0_shifted + u1_shifted
      in
        (uint_of_uint64 (u_shifted)) & mask
      end
    else
      (* All the bits are in uu.1 *)
      let
        val u_shifted = (g1ofg0 (uu.1)) >> (shift_uu - 64U)
      in
        (uint_of_uint64 u_shifted) & mask
      end
  end

fn
make_mask {num_bits : int | valid_num_bits (num_bits)}
          (num_bits : uint num_bits) :<>
    [mask : int | bits_mask (num_bits, mask)]
    uint mask =
  case- num_bits of
  | 4U => g1i2u MAXVALOF_BITINDEX_4
  | 5U => g1i2u MAXVALOF_BITINDEX_5
  | 6U => g1i2u MAXVALOF_BITINDEX_6
  | 7U => g1i2u MAXVALOF_BITINDEX_7
  | 8U => g1i2u MAXVALOF_BITINDEX_8

implement
make_bits_source_uint64_uint64 {num_bits} (num_bits) =
  let
    val mask = make_mask (num_bits)
    val q = g1uint_div (128U, num_bits)
    val r = g1uint_mod (128U, num_bits)
    val index_bound = (if iseqz r then q else succ q) : uint
    val index_bound = g1ofg0 index_bound
  in
    lam (uu, i) =>
      let
        val i = g1ofg0 i
      in
        if i < index_bound then
          let
            val [bits : int] bits =
              rshift_and_mask<> (uu, i, num_bits, mask)
            prval _ = lemma_g1uint_param bits
          in
            (bits_source_bits_make {num_bits} {bits} () |
             int_of_uint (bits))
          end
        else
          (bits_source_bits_make {num_bits} {~1} () | (~1))
      end
  end

implement
free_bits_source_uint64_uint64 bits_source =
  cloptr_free ($UNSAFE.castvwtp0{cloptr0} bits_source)
