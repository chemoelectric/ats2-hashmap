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

staload UN = "prelude/SATS/unsafe.sats"

#include "hashmap/HATS/config.hats"

staload "hashmap/SATS/memory.sats"
staload _ = "hashmap/DATS/memory.dats"

%{^
#ifdef __BIG_ENDIAN__
#define my_apple_bigendian() (atsbool_true)
#else
#define my_apple_bigendian() (atsbool_false)
#endif
%}

extern fn
apple_bigendian () : bool = "mac#my_apple_bigendian"

fn {tk : tkind}
test_big_endian () : bool =
  let
    typedef t = g0uint (tk)
  in
    if (ENDIANNESS = BIGENDIAN ||
        (ENDIANNESS = UNIVERSALENDIAN && apple_bigendian ())) then
      begin
        if sizeof<t> = i2sz 1 then
          big_endian<tk> ($UN.cast{t} 0x12ULL) = $UN.cast{t} 0x12ULL
        else if sizeof<t> = i2sz 2 then
          big_endian<tk> ($UN.cast{t} 0x1234ULL) = $UN.cast{t} 0x1234ULL
        else if sizeof<t> = i2sz 3 then
          big_endian<tk> ($UN.cast{t} 0x123456ULL) = $UN.cast{t} 0x123456ULL
        else if sizeof<t> = i2sz 4 then
          big_endian<tk> ($UN.cast{t} 0x12345678ULL) = $UN.cast{t} 0x12345678ULL
        else if sizeof<t> = i2sz 5 then
          big_endian<tk> ($UN.cast{t} 0x123456789AULL) = $UN.cast{t} 0x123456789AULL
        else if sizeof<t> = i2sz 6 then
          big_endian<tk> ($UN.cast{t} 0x123456789ABCULL) = $UN.cast{t} 0x123456789ABCULL
        else if sizeof<t> = i2sz 7 then
          big_endian<tk> ($UN.cast{t} 0x123456789ABCDEULL) = $UN.cast{t} 0x123456789ABCDEULL
        else if sizeof<t> = i2sz 8 then
          big_endian<tk> ($UN.cast{t} 0x123456789ABCDEF0ULL) = $UN.cast{t} 0x123456789ABCDEF0ULL
        else
          false
      end
    else if (ENDIANNESS = LITTLEENDIAN ||
             (ENDIANNESS = UNIVERSALENDIAN && not (apple_bigendian ()))) then
      begin
        if sizeof<t> = i2sz 1 then
          big_endian<tk> ($UN.cast{t} 0x12ULL) = $UN.cast{t} 0x12ULL
        else if sizeof<t> = i2sz 2 then
          big_endian<tk> ($UN.cast{t} 0x1234ULL) = $UN.cast{t} 0x3412ULL
        else if sizeof<t> = i2sz 3 then
          big_endian<tk> ($UN.cast{t} 0x123456ULL) = $UN.cast{t} 0x563412ULL
        else if sizeof<t> = i2sz 4 then
          big_endian<tk> ($UN.cast{t} 0x12345678ULL) = $UN.cast{t} 0x78563412ULL
        else if sizeof<t> = i2sz 5 then
          big_endian<tk> ($UN.cast{t} 0x123456789AULL) = $UN.cast{t} 0x9A78563412ULL
        else if sizeof<t> = i2sz 6 then
          big_endian<tk> ($UN.cast{t} 0x123456789ABCULL) = $UN.cast{t} 0xBC9A78563412ULL
        else if sizeof<t> = i2sz 7 then
          big_endian<tk> ($UN.cast{t} 0x123456789ABCDEULL) = $UN.cast{t} 0xDEBC9A78563412ULL
        else if sizeof<t> = i2sz 8 then
          big_endian<tk> ($UN.cast{t} 0x123456789ABCDEF0ULL) = $UN.cast{t} 0xF0DEBC9A78563412ULL
        else
          false
      end
    else
      false
  end

implement
main0 () =
  {
    val _ = assertloc (test_big_endian<usintknd> ())
    val _ = assertloc (test_big_endian<uintknd> ())
    val _ = assertloc (test_big_endian<ulintknd> ())
    val _ = assertloc (test_big_endian<ullintknd> ())
    val _ = assertloc (test_big_endian<uint8knd> ())
    val _ = assertloc (test_big_endian<uint16knd> ())
    val _ = assertloc (test_big_endian<uint32knd> ())
    val _ = assertloc (test_big_endian<uint64knd> ())
    val _ = assertloc (test_big_endian<sizeknd> ())
    val _ = assertloc (test_big_endian<uintptrknd> ())
  }
