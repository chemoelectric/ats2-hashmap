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

  (* A bits source returns ~1 if the index is past the last
     available bit.
     FIXME: Say more about what a bits source does. *)
  vtypedef bits_source_cloptr (num_bits : int) =
    uint -<cloptr1>
      [bits : int | (~1) <= bits; bits_maxval (num_bits, bits)]
      int bits

  (* Make a bits source from a uint32. *)
  fun
  make_bits_source_uint32 :
    {num_bits : int | valid_num_bits (num_bits)}
    (uint num_bits, uint32) -> bits_source_cloptr (num_bits)

  (* You can put a call to bits_source_check_mask in an assertloc
     to avoid proving that your mask is small enough. *)
  fun
  bits_source_check_mask {num_bits : int | valid_num_bits (num_bits)}
                         {mask     : int}
                         (num_bits : uint num_bits,
                          mask     : uint mask) :<>
      bool (bits_maxval (num_bits, mask))

end
