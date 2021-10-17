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

(* The following code assumes bytes are 8 bits. *)

(********************************************************************)

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

staload "hashmap/SATS/bits_source-parameters.sats"
staload "hashmap/SATS/bits_source.sats"

(********************************************************************)

%{^
#include <limits.h>

#undef ats2_hashmap_bits_source_lshift
#define ats2_hashmap_bits_source_lshift(u, i) ((u) << (i))

#undef ats2_hashmap_bits_source_rshift
#define ats2_hashmap_bits_source_rshift(u, i) ((u) >> (i))

#undef ats2_hashmap_bits_source_land
#define ats2_hashmap_bits_source_land(u, v) ((u) & (v))
%}

(* CHAR_BIT will equal 8. *)
macdef CHAR_BIT = $extval (size_t, "CHAR_BIT")

extern fn
lshift_uint {u, i : int}
            (u    : uint u,
             i    : uint i) :<>
    [v : int] uint v = "mac#ats2_hashmap_bits_source_lshift"
infix <<
overload << with lshift_uint of 1000

extern fn
rshift_uint {u, i : int}
            (u    : uint u,
             i    : uint i) :<>
    [v : int] uint v = "mac#ats2_hashmap_bits_source_rshift"
infix >>
overload >> with rshift_uint of 1000

extern fn
land_uint {u, v : int}
          (u    : uint u,
           v    : uint v) :<>
    [w : int | w <= u; w <= v]
    uint w = "mac#ats2_hashmap_bits_source_land"
infix &
overload & with land_uint of 1000

(********************************************************************)

implement
bits_source_nbytes {n} {depth} (n, hash, depth) =
  let
    stadef num_bits = BITS_SOURCE_NUM_BITS
    macdef num_bits = (i2sz BITS_SOURCE_NUM_BITS) : size_t num_bits

    stadef mask = BITS_SOURCE_MASK
    macdef mask = (i2u BITS_SOURCE_MASK) : uint mask

    prval _ = lemma_g1uint_param n
    prval _ = lemma_g1uint_param depth

    val [char_bit : int] char_bit = g1ofg0 CHAR_BIT
    val _ = $effmask_exn assertloc (i2sz 0 < char_bit)
    val _ = $effmask_exn assertloc (num_bits <= char_bit)

    prval _ = mul_gte_gte_gte {char_bit, n} ()
    stadef total_num_bits = char_bit * n
    val total_num_bits : size_t total_num_bits = char_bit * n

    prval _ = mul_gte_gte_gte {num_bits, depth} ()
    stadef start = num_bits * depth
    val start : size_t start = num_bits * (g1u2u depth)
  in
    if total_num_bits <= start then
      BITS_SOURCE_EXHAUSTED
    else
      let
        stadef i = ndiv_int_int (start, char_bit)
        val i : size_t i = g1uint_div (start, char_bit)
        prval _ = prop_verify {0 <= i} ()

        (* FIXME: Prove this. *)
        val _ = $effmask_exn assertloc (i < n)

        val u0 : [u0 : int] uint u0 = $UNSAFE.cast (hash[i])

        (* FIXME: Prove this. *)
        val _ = $effmask_exn assertloc (char_bit * i <= start)

        val rshift_amount = start - (char_bit * i)
      in
        if rshift_amount + num_bits <= char_bit then
          (* All the bits are in one byte. *)
          u2i ((u0 >> (g1u2u rshift_amount)) & mask)
        else if total_num_bits - start <= char_bit then
          (* Return the last few bits. *)
          u2i ((u0 >> (g1u2u rshift_amount)) & mask)
        else
          let
            (* FIXME: Prove this. *)
            val _ = $effmask_exn assertloc (i + 1 < n)

            val u1 = $UNSAFE.cast (hash[succ i])

            (* FIXME: Prove this. *)
            val _ = $effmask_exn assertloc (rshift_amount <= char_bit)

            val lshift_amount = char_bit - rshift_amount
          in
            u2i (mask & (((u0 >> (g1u2u rshift_amount)) & mask) +
                         ((u1 << (g1u2u lshift_amount)))))
          end
      end
  end

(********************************************************************)
