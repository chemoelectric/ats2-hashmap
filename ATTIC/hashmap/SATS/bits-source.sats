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
#include "hashmap/CATS/bits-source.cats"
%}

local

  #include "hashmap/HATS/bits-source-include.hats"

in
  (******************************************************************)
  (*
    A bits source returns ~1 == BITS_SOURCE_EXHAUSTED, if the index
    is past the last available bit.

    FIXME: Say more about what a bits source does.
  *)

  #define BITS_SOURCE_EXHAUSTED (~1)

  absprop BITS_SOURCE_BITS (num_bits : int, bits : int)

  praxi
  bits_source_bits_make :
    {num_bits : int}
    {bits     : int | (~1) <= bits && bits_maxval (num_bits, bits)}
    () -<prf> BITS_SOURCE_BITS (num_bits, bits)

  praxi
  bits_source_bits_bounds :
    {num_bits : int}
    {bits     : int}
    BITS_SOURCE_BITS (num_bits, bits) -<prf>
      [(~1) <= bits && bits_maxval (num_bits, bits)] void

  vtypedef bits_source_cloptr (data_vt : vt@ype, num_bits : int) =
    (&data_vt >> _, uint) -<cloptr1>
      [bits : int]
      @(BITS_SOURCE_BITS (num_bits, bits) | int bits)

  typedef bits_source_cloref (data_t : t@ype, num_bits : int) =
    (&data_t >> _, uint) -<cloref1>
      [bits : int]
      @(BITS_SOURCE_BITS (num_bits, bits) | int bits)

  (******************************************************************)
  (* Make a bits source of a uint8. *)

  fun
  make_bits_source_uint8 :
    {num_bits : int | valid_num_bits (num_bits)}
    (uint num_bits) -> bits_source_cloptr (uint8, num_bits)

  fun
  free_bits_source_uint8 :
    {num_bits : int}
    bits_source_cloptr (uint8, num_bits) -> void

  overload free with free_bits_source_uint8

  (* Make a one-time-initialized bits source that returns the
     correct number of bits for a hashmap (log2 of the bitsize
     of uintptr). *)
  fun
  bits_source_uint8 :
    () -> [num_bits : int | valid_num_bits (num_bits)]
          bits_source_cloref (uint8, num_bits) = "mac#%"

  (******************************************************************)
  (* Make a bits source of a uint16. *)

  fun
  make_bits_source_uint16 :
    {num_bits : int | valid_num_bits (num_bits)}
    (uint num_bits) -> bits_source_cloptr (uint16, num_bits)

  fun
  free_bits_source_uint16 :
    {num_bits : int}
    bits_source_cloptr (uint16, num_bits) -> void

  overload free with free_bits_source_uint16

  (* Make a one-time-initialized bits source that returns the
     correct number of bits for a hashmap (log2 of the bitsize
     of uintptr). *)
  fun
  bits_source_uint16 :
    () -> [num_bits : int | valid_num_bits (num_bits)]
          bits_source_cloref (uint16, num_bits) = "mac#%"

  (******************************************************************)
  (* Make a bits source of a uint32. *)

  fun
  make_bits_source_uint32 :
    {num_bits : int | valid_num_bits (num_bits)}
    (uint num_bits) -> bits_source_cloptr (uint32, num_bits)

  fun
  free_bits_source_uint32 :
    {num_bits : int}
    bits_source_cloptr (uint32, num_bits) -> void

  overload free with free_bits_source_uint32

  (* Make a one-time-initialized bits source that returns the
     correct number of bits for a hashmap (log2 of the bitsize
     of uintptr). *)
  fun
  bits_source_uint32 :
    () -> [num_bits : int | valid_num_bits (num_bits)]
          bits_source_cloref (uint32, num_bits) = "mac#%"

  (******************************************************************)
  (* Make a bits source of a uint64. *)

  fun
  make_bits_source_uint64 :
    {num_bits : int | valid_num_bits (num_bits)}
    (uint num_bits) -> bits_source_cloptr (uint64, num_bits)

  fun
  free_bits_source_uint64 :
    {num_bits : int}
    bits_source_cloptr (uint64, num_bits) -> void

  overload free with free_bits_source_uint64

  (* Make a one-time-initialized bits source that returns the
     correct number of bits for a hashmap (log2 of the bitsize
     of uintptr). *)
  fun
  bits_source_uint64 :
    () -> [num_bits : int | valid_num_bits (num_bits)]
          bits_source_cloref (uint64, num_bits) = "mac#%"

  (******************************************************************)
  (* Make a bits source of a pair of uint64. *)

  fun
  make_bits_source_uint64_uint64 :
    {num_bits : int | valid_num_bits (num_bits)}
    (uint num_bits) ->
      bits_source_cloptr (@(uint64, uint64), num_bits)

  fun
  free_bits_source_uint64_uint64 :
    {num_bits : int}
    bits_source_cloptr (@(uint64, uint64), num_bits) -> void

  overload free with free_bits_source_uint64_uint64

  (* Make a one-time-initialized bits source that returns the
     correct number of bits for a hashmap (log2 of the bitsize
     of uintptr). *)
  fun
  bits_source_uint64_uint64 :
    () -> [num_bits : int | valid_num_bits (num_bits)]
          bits_source_cloref (@(uint64, uint64), num_bits) = "mac#%"

  (******************************************************************)
  (* Make a bits source of a uintptr. (One possible use is addresses
     of objects as their hashes.) *)

  fun
  make_bits_source_uintptr :
    {num_bits : int | valid_num_bits (num_bits)}
    (uint num_bits) -> bits_source_cloptr (uintptr, num_bits)

  fun
  free_bits_source_uintptr :
    {num_bits : int}
    bits_source_cloptr (uintptr, num_bits) -> void

  overload free with free_bits_source_uintptr

  (* Make a one-time-initialized bits source that returns the
     correct number of bits for a hashmap (log2 of the bitsize
     of uintptr). *)
  fun
  bits_source_uintptr :
    () -> [num_bits : int | valid_num_bits (num_bits)]
          bits_source_cloref (uintptr, num_bits) = "mac#%"

  (******************************************************************)
  (* Make a bits source of a size_t. *)

  fun
  make_bits_source_size :
    {num_bits : int | valid_num_bits (num_bits)}
    (uint num_bits) -> bits_source_cloptr (size_t, num_bits)

  fun
  free_bits_source_size :
    {num_bits : int}
    bits_source_cloptr (size_t, num_bits) -> void

  overload free with free_bits_source_size

  (* Make a one-time-initialized bits source that returns the
     correct number of bits for a hashmap (log2 of the bitsize
     of uintptr). *)
  fun
  bits_source_size :
    () -> [num_bits : int | valid_num_bits (num_bits)]
          bits_source_cloref (size_t, num_bits) = "mac#%"

  (******************************************************************)
  (* Make a bits source of a usint. *)

  fun
  make_bits_source_usint :
    {num_bits : int | valid_num_bits (num_bits)}
    (uint num_bits) -> bits_source_cloptr (usint, num_bits)

  fun
  free_bits_source_usint :
    {num_bits : int}
    bits_source_cloptr (usint, num_bits) -> void

  overload free with free_bits_source_usint

  (* Make a one-time-initialized bits source that returns the
     correct number of bits for a hashmap (log2 of the bitsize
     of uintptr). *)
  fun
  bits_source_usint :
    () -> [num_bits : int | valid_num_bits (num_bits)]
          bits_source_cloref (usint, num_bits) = "mac#%"

  (******************************************************************)
  (* Make a bits source of a uint. *)

  fun
  make_bits_source_uint :
    {num_bits : int | valid_num_bits (num_bits)}
    (uint num_bits) -> bits_source_cloptr (uint, num_bits)

  fun
  free_bits_source_uint :
    {num_bits : int}
    bits_source_cloptr (uint, num_bits) -> void

  overload free with free_bits_source_uint

  (* Make a one-time-initialized bits source that returns the
     correct number of bits for a hashmap (log2 of the bitsize
     of uintptr). *)
  fun
  bits_source_uint :
    () -> [num_bits : int | valid_num_bits (num_bits)]
          bits_source_cloref (uint, num_bits) = "mac#%"

  (******************************************************************)
  (* Make a bits source of a ulint. *)

  fun
  make_bits_source_ulint :
    {num_bits : int | valid_num_bits (num_bits)}
    (uint num_bits) -> bits_source_cloptr (ulint, num_bits)

  fun
  free_bits_source_ulint :
    {num_bits : int}
    bits_source_cloptr (ulint, num_bits) -> void

  overload free with free_bits_source_ulint

  (* Make a one-time-initialized bits source that returns the
     correct number of bits for a hashmap (log2 of the bitsize
     of uintptr). *)
  fun
  bits_source_ulint :
    () -> [num_bits : int | valid_num_bits (num_bits)]
          bits_source_cloref (ulint, num_bits) = "mac#%"

  (******************************************************************)
  (* Make a bits source of a ullint. *)

  fun
  make_bits_source_ullint :
    {num_bits : int | valid_num_bits (num_bits)}
    (uint num_bits) -> bits_source_cloptr (ullint, num_bits)

  fun
  free_bits_source_ullint :
    {num_bits : int}
    bits_source_cloptr (ullint, num_bits) -> void

  overload free with free_bits_source_ullint

  (* Make a one-time-initialized bits source that returns the
     correct number of bits for a hashmap (log2 of the bitsize
     of uintptr). *)
  fun
  bits_source_ullint :
    () -> [num_bits : int | valid_num_bits (num_bits)]
          bits_source_cloref (ullint, num_bits) = "mac#%"

  (******************************************************************)
  (* Make a bits source of a GCC "unsigned __int128" type. *)

  typedef hashmap_uint128 = $extype"unsigned __int128"

  fun
  make_bits_source_uint128 :
    {num_bits : int | valid_num_bits (num_bits)}
    (uint num_bits) ->
      bits_source_cloptr (hashmap_uint128, num_bits)

  fun
  free_bits_source_uint128 :
    {num_bits : int}
    bits_source_cloptr (hashmap_uint128, num_bits) -> void

  overload free with free_bits_source_uint128

  (* Make a one-time-initialized bits source that returns the
     correct number of bits for a hashmap (log2 of the bitsize
     of uintptr). *)
  fun
  bits_source_uint128 :
    () -> [num_bits : int | valid_num_bits (num_bits)]
          bits_source_cloref (hashmap_uint128, num_bits) = "mac#%"

  (******************************************************************)
end
