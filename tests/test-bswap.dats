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

staload "hashmap/SATS/memory.sats"
staload _ = "hashmap/DATS/memory.dats"

fn {tk : tkind}
test_bswap () : bool =
  let
    typedef t = g0uint (tk)
  in
    if sizeof<t> = i2sz 1 then
      bswap<tk> ($UN.cast{t} 0x12ULL) = $UN.cast{t} 0x12ULL
    else if sizeof<t> = i2sz 2 then
      bswap<tk> ($UN.cast{t} 0x1234ULL) = $UN.cast{t} 0x3412ULL
    else if sizeof<t> = i2sz 3 then
      bswap<tk> ($UN.cast{t} 0x123456ULL) = $UN.cast{t} 0x563412ULL
    else if sizeof<t> = i2sz 4 then
      bswap<tk> ($UN.cast{t} 0x12345678ULL) = $UN.cast{t} 0x78563412ULL
    else if sizeof<t> = i2sz 5 then
      bswap<tk> ($UN.cast{t} 0x123456789AULL) = $UN.cast{t} 0x9A78563412ULL
    else if sizeof<t> = i2sz 6 then
      bswap<tk> ($UN.cast{t} 0x123456789ABCULL) = $UN.cast{t} 0xBC9A78563412ULL
    else if sizeof<t> = i2sz 7 then
      bswap<tk> ($UN.cast{t} 0x123456789ABCDEULL) = $UN.cast{t} 0xDEBC9A78563412ULL
    else if sizeof<t> = i2sz 8 then
      bswap<tk> ($UN.cast{t} 0x123456789ABCDEF0ULL) = $UN.cast{t} 0xF0DEBC9A78563412ULL
    else
      false
  end

implement
main0 () =
  {
    val _ = assertloc (test_bswap<usintknd> ())
    val _ = assertloc (test_bswap<uintknd> ())
    val _ = assertloc (test_bswap<ulintknd> ())
    val _ = assertloc (test_bswap<ullintknd> ())
    val _ = assertloc (test_bswap<uint8knd> ())
    val _ = assertloc (test_bswap<uint16knd> ())
    val _ = assertloc (test_bswap<uint32knd> ())
    val _ = assertloc (test_bswap<uint64knd> ())
    val _ = assertloc (test_bswap<sizeknd> ())
    val _ = assertloc (test_bswap<uintptrknd> ())
  }
