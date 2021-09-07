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
popcount_is_nonnegative :
  {x : int} {popcount : int}
  POPCOUNT (x, popcount) -<prf> [0 <= popcount] void

praxi
popcount_low_bits_is_nonnegative :
  {x : int} {i : int} {popcount : int}
  POPCOUNT_LOW_BITS (x, i, popcount) -<prf> [0 <= popcount] void

praxi
popcount_low_bits_bound :
  {x : int} {i : int} {popcount : int}
  POPCOUNT_LOW_BITS (x, i, popcount) -<prf> [popcount <= i] void

(********************************************************************)
(* Compute and return the number of 1-bits set in x. *)

fun
count_one_bits_uint :
  {x : int} uint x -<>
    [popcount : int]
    @(POPCOUNT (x, popcount) | int popcount) = "mac#%"

fun
count_one_bits_ulint :
  {x : int} ulint x -<>
    [popcount : int]
    @(POPCOUNT (x, popcount) | int popcount) = "mac#%"

fun
count_one_bits_ullint :
  {x : int} ullint x -<>
    [popcount : int]
    @(POPCOUNT (x, popcount) | int popcount) = "mac#%"

fun
count_one_bits_uintptr :
  {x : int} uintptr x -<>
    [popcount : int]
    @(POPCOUNT (x, popcount) | int popcount) = "mac#%"

(********************************************************************)
(* Compute and return the number of 1-bits set in x,
   ignoring all bits of index i or higher. *)

fun
count_low_one_bits_uint :
  {x : int} {i : int} (uint x, uint i) -<>
    [popcount : int]
    @(POPCOUNT_LOW_BITS (x, i, popcount) | int popcount) = "mac#%"

fun
count_low_one_bits_ulint :
  {x : int} {i : int} (ulint x, uint i) -<>
    [popcount : int]
    @(POPCOUNT_LOW_BITS (x, i, popcount) | int popcount) = "mac#%"

fun
count_low_one_bits_ullint :
  {x : int} {i : int} (ullint x, uint i) -<>
    [popcount : int]
    @(POPCOUNT_LOW_BITS (x, i, popcount) | int popcount) = "mac#%"

fun
count_low_one_bits_uintptr :
  {x : int} {i : int} (uintptr x, uint i) -<>
    [popcount : int]
    @(POPCOUNT_LOW_BITS (x, i, popcount) | int popcount) = "mac#%"

(********************************************************************)
(* For simplicity, use overloads rather than typekind templates.
   We really need only the uintptr implementations.

   For a general-use library, we would want to write typekind
   templates. *)

symintr count_one_bits
overload count_one_bits with count_one_bits_uint
overload count_one_bits with count_one_bits_ulint
overload count_one_bits with count_one_bits_ullint
overload count_one_bits with count_one_bits_uintptr

symintr popcount
overload popcount with count_one_bits

symintr count_low_one_bits
overload count_low_one_bits with count_low_one_bits_uint
overload count_low_one_bits with count_low_one_bits_ulint
overload count_low_one_bits with count_low_one_bits_ullint
overload count_low_one_bits with count_low_one_bits_uintptr

symintr popcount_low_bits
overload popcount_low_bits with count_low_one_bits

(********************************************************************)
