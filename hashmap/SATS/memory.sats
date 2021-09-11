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
#include "hashmap/CATS/memory.cats"
%}

(* An interface to memcpy or __builtin_memcpy. *)
fun
memcpy {n   : int}
       (dst : &(@[byte?][n]) >> @[byte][n],
        src : &RD(@[byte][n]),
        n   : size_t n) :<!refwrt> void = "mac#%"

(* An interface to memset or __builtin_memset. *)
fun
memset {n     : int}
       (dst   : &(@[byte?][n]) >> @[byte][n],
        value : byte,
        n     : size_t n) :<!refwrt> void = "mac#%"

(* Move the elements of one array to another array.
   This is equivalent to the prelude's "array_copy"
   template; for a nonlinear type, it is a copy. For
   a linear type, it is a "move" that leaves the old
   array filled with the equivalent nonlinear data. *)
fun {vt : vt@ype}
array_move {length : int}
           (dst    : &(@[vt?][length]) >> @[vt][length],
            src    : &RD(@[INV(vt)][length]) >> @[vt?!][length],
            length : size_t length) :<!refwrt> void

(* Copy "length" elements from one initialized nonlinear
   array into another. *)
fun {t : t@ype}
array_copy_elements
        {n1, n2 : int}
        {i1, i2 : int}
        {length : int | i1 + length <= n1; i2 + length <= n2}
        (dst    : &(@[t][n1]),
         i1     : size_t i1,
         src    : &RD(@[INV(t)][n2]),
         i2     : size_t i2,
         length : size_t length) :<!refwrt> void
