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
#include <hashmap/CATS/bits_source.cats>
%}

(********************************************************************)

stadef bits_source_bits_maxval (num_bits : int, bits : int) : bool =
  (num_bits == 4 && bits <= 15) ||
  (num_bits == 5 && bits <= 31) ||
  (num_bits == 6 && bits <= 63) ||
  (num_bits == 7 && bits <= 127) ||
  (num_bits == 8 && bits <= 255)

(********************************************************************)

(*

  A bits source returns ~1 == BITS_SOURCE_EXHAUSTED, if the index is
  past the last available bit.

*)

#define BITS_SOURCE_EXHAUSTED (~1)

absprop BITS_SOURCE_BITS (num_bits : int, bits : int)

praxi
bits_source_bits_make :
  {num_bits : int}
  {bits     : int | (~1) <= bits &&
                    bits_source_bits_maxval (num_bits, bits)}
  () -<prf> BITS_SOURCE_BITS (num_bits, bits)

praxi
bits_source_bits_bounds :
  {num_bits : int}
  {bits     : int}
  BITS_SOURCE_BITS (num_bits, bits) -<prf>
    [(~1) <= bits && bits_source_bits_maxval (num_bits, bits)]
    void

vtypedef
bits_source_vt (hash_vt  : vt@ype+,
                num_bits : int) =
  (* It is convenient to make a bits source a closure. *)
  [depth : int]
  (&hash_vt >> _, uint depth) -<cloptr1>
    [bits : int]
    @(BITS_SOURCE_BITS (num_bits, bits) | int bits)

(********************************************************************)
