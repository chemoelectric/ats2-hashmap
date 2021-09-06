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

local

  #include "hashmap/HATS/bits-source-include.hats"

in
  (******************************************************************)
  (* A bits source returns ~1 if the index is past the last
     available bit.
     FIXME: Say more about what a bits source does. *)

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
    (data_vt, uint) -<cloptr1>
      [bits : int]
      (BITS_SOURCE_BITS (num_bits, bits) | int bits)

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

  (******************************************************************)
  (* You can put a call to bits_source_check_mask in an assertloc
     to avoid actually *proving* that your bitmask is small enough. *)

  fun
  bits_source_check_mask {num_bits : int | valid_num_bits (num_bits)}
                         {mask     : int}
                         (num_bits : uint num_bits,
                          mask     : uint mask) :<>
      bool (bits_maxval (num_bits, mask))

end
