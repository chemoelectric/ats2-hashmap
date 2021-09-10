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

%{#
#include "hashmap/CATS/count-one-bits.cats"
%}

(********************************************************************)

(* "popcount" is the number of 1-bits set in x. *)
absprop POPCOUNT (x : int, popcount : int)

(* "popcount" is the number of 1-bits set in x,
   ignoring all bits of index i or higher. *)
absprop POPCOUNT_LOW_BITS (x : int, i : int, popcount : int)

praxi
popcount_isfun :
  {x : int}
  {popcount1, popcount2 : int}
  (POPCOUNT (x, popcount1),
   POPCOUNT (x, popcount2)) -<prf>
    [popcount1 == popcount2] void

praxi
popcount_low_bits_isfun :
  {x : int}
  {i : int}
  {popcount1, popcount2 : int}
  (POPCOUNT_LOW_BITS (x, i, popcount1),
   POPCOUNT_LOW_BITS (x, i, popcount2)) -<prf>
    [popcount1 == popcount2] void

praxi
popcount_is_nonnegative :
  {x : int}
  {popcount : int}
  POPCOUNT (x, popcount) -<prf>
    [0 <= popcount] void

praxi
popcount_low_bits_is_nonnegative :
  {x : int}
  {i : int}
  {popcount : int}
  POPCOUNT_LOW_BITS (x, i, popcount) -<prf>
    [0 <= popcount] void

praxi
popcount_low_bits_bound :
  {x : int}
  {i : int}
  {popcount : int}
  POPCOUNT_LOW_BITS (x, i, popcount) -<prf>
    [popcount <= i] void

praxi
popcount_fewer_bits_1 :
  {x : int}
  {i : int}
  {popcount1, popcount2 : int}
  (POPCOUNT (x, popcount1),
   POPCOUNT_LOW_BITS (x, i, popcount2)) -<prf>
    [popcount2 <= popcount1] void

praxi
popcount_fewer_bits_2 :
  {x : int}
  {i1, i2 : int | i2 <= i1}
  {popcount1, popcount2 : int}
  (POPCOUNT_LOW_BITS (x, i1, popcount1),
   POPCOUNT_LOW_BITS (x, i2, popcount2)) -<prf>
    [popcount2 <= popcount1] void

(********************************************************************)
(* Compute and return the number of 1-bits set in x. *)

fun {tk : tkind}
count_one_bits :
  {x : int}
  g1uint (tk, x) -<>
    [popcount : int]
    @(POPCOUNT (x, popcount) | int popcount)

symintr popcount
overload popcount with count_one_bits

fun
count_one_bits_usint :
  {x : int}
  usint x -<>
    [popcount : int]
    @(POPCOUNT (x, popcount) | int popcount) = "mac#%"

fun
count_one_bits_uint :
  {x : int}
  uint x -<>
    [popcount : int]
    @(POPCOUNT (x, popcount) | int popcount) = "mac#%"

fun
count_one_bits_ulint :
  {x : int}
  ulint x -<>
    [popcount : int]
    @(POPCOUNT (x, popcount) | int popcount) = "mac#%"

fun
count_one_bits_ullint :
  {x : int}
  ullint x -<>
    [popcount : int]
    @(POPCOUNT (x, popcount) | int popcount) = "mac#%"

fun
count_one_bits_size :
  {x : int}
  size_t x -<>
    [popcount : int]
    @(POPCOUNT (x, popcount) | int popcount) = "mac#%"

fun
count_one_bits_uintptr :
  {x : int}
  uintptr x -<>
    [popcount : int]
    @(POPCOUNT (x, popcount) | int popcount) = "mac#%"

fun
count_one_bits_uint8 :
  {x : int}
  uint8 x -<>
    [popcount : int]
    @(POPCOUNT (x, popcount) | int popcount) = "mac#%"

fun
count_one_bits_uint16 :
  {x : int}
  uint16 x -<>
    [popcount : int]
    @(POPCOUNT (x, popcount) | int popcount) = "mac#%"

fun
count_one_bits_uint32 :
  {x : int}
  uint32 x -<>
    [popcount : int]
    @(POPCOUNT (x, popcount) | int popcount) = "mac#%"

fun
count_one_bits_uint64 :
  {x : int}
  uint64 x -<>
    [popcount : int]
    @(POPCOUNT (x, popcount) | int popcount) = "mac#%"

(********************************************************************)
(* Compute and return the number of 1-bits set in x,
   ignoring all bits of index i or higher. *)

fun {tk : tkind}
count_low_one_bits :
  {x : int}
  {i : int | i < 8 * sizeof (g1uint (tk, x))}
  (g1uint (tk, x), uint i) -<>
    [popcount : int]
    @(POPCOUNT_LOW_BITS (x, i, popcount) | int popcount)

symintr popcount_low_bits
overload popcount_low_bits with count_low_one_bits

fun
count_low_one_bits_usint :
  {x : int}
  {i : int | i < 8 * sizeof (usint)}
  (usint x, uint i) -<>
    [popcount : int]
    @(POPCOUNT_LOW_BITS (x, i, popcount) | int popcount) = "mac#%"

fun
count_low_one_bits_uint :
  {x : int}
  {i : int | i < 8 * sizeof (uint)}
  (uint x, uint i) -<>
    [popcount : int]
    @(POPCOUNT_LOW_BITS (x, i, popcount) | int popcount) = "mac#%"

fun
count_low_one_bits_ulint :
  {x : int}
  {i : int | i < 8 * sizeof (ulint)}
  (ulint x, uint i) -<>
    [popcount : int]
    @(POPCOUNT_LOW_BITS (x, i, popcount) | int popcount) = "mac#%"

fun
count_low_one_bits_ullint :
  {x : int}
  {i : int | i < 8 * sizeof (ullint)}
  (ullint x, uint i) -<>
    [popcount : int]
    @(POPCOUNT_LOW_BITS (x, i, popcount) | int popcount) = "mac#%"

fun
count_low_one_bits_size :
  {x : int}
  {i : int | i < 8 * sizeof (size_t)}
  (size_t x, uint i) -<>
    [popcount : int]
    @(POPCOUNT_LOW_BITS (x, i, popcount) | int popcount) = "mac#%"

fun
count_low_one_bits_uintptr :
  {x : int}
  {i : int | i < 8 * sizeof (uintptr)}
  (uintptr x, uint i) -<>
    [popcount : int]
    @(POPCOUNT_LOW_BITS (x, i, popcount) | int popcount) = "mac#%"

fun
count_low_one_bits_uint8 :
  {x : int}
  {i : int | i < 8 * sizeof (uint8)}
  (uint8 x, uint i) -<>
    [popcount : int]
    @(POPCOUNT_LOW_BITS (x, i, popcount) | int popcount) = "mac#%"

fun
count_low_one_bits_uint16 :
  {x : int}
  {i : int | i < 8 * sizeof (uint16)}
  (uint16 x, uint i) -<>
    [popcount : int]
    @(POPCOUNT_LOW_BITS (x, i, popcount) | int popcount) = "mac#%"

fun
count_low_one_bits_uint32 :
  {x : int}
  {i : int | i < 8 * sizeof (uint32)}
  (uint32 x, uint i) -<>
    [popcount : int]
    @(POPCOUNT_LOW_BITS (x, i, popcount) | int popcount) = "mac#%"

fun
count_low_one_bits_uint64 :
  {x : int}
  {i : int | i < 8 * sizeof (uint64)}
  (uint64 x, uint i) -<>
    [popcount : int]
    @(POPCOUNT_LOW_BITS (x, i, popcount) | int popcount) = "mac#%"

(********************************************************************)
