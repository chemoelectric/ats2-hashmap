/*

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

*/

#ifndef HEADER_GUARD_ATS2_HASHMAP_BITS_SOURCE_CATS__
#define HEADER_GUARD_ATS2_HASHMAP_BITS_SOURCE_CATS__

/* One-time-initialized functions always return the same value.
   Therefore they are ‘const’ in the GCC sense and can be treated
   specially by the C optimizer. */
#include <hashmap/CATS/const.cats>

#define ATS2_HASHMAP_BITS_SOURCE_FUNCTION(TYPE)             \
  ats2_hashmap_attribute_const static inline atstype_ptr    \
  ats2_hashmap_bits_source_##TYPE (void)                    \
  {                                                         \
    extern atstype_ptr                                      \
      ats2_hashmap_get_bits_source_cloref_##TYPE (void);    \
    return ats2_hashmap_get_bits_source_cloref_##TYPE ();   \
  }

ATS2_HASHMAP_BITS_SOURCE_FUNCTION (uint8)
ATS2_HASHMAP_BITS_SOURCE_FUNCTION (uint16)
ATS2_HASHMAP_BITS_SOURCE_FUNCTION (uint32)
ATS2_HASHMAP_BITS_SOURCE_FUNCTION (uint64)
ATS2_HASHMAP_BITS_SOURCE_FUNCTION (uint128)
ATS2_HASHMAP_BITS_SOURCE_FUNCTION (uintptr)
ATS2_HASHMAP_BITS_SOURCE_FUNCTION (size)
ATS2_HASHMAP_BITS_SOURCE_FUNCTION (usint)
ATS2_HASHMAP_BITS_SOURCE_FUNCTION (uint)
ATS2_HASHMAP_BITS_SOURCE_FUNCTION (ulint)
ATS2_HASHMAP_BITS_SOURCE_FUNCTION (ullint)
ATS2_HASHMAP_BITS_SOURCE_FUNCTION (uint64_uint64)

#endif /* HEADER_GUARD_ATS2_HASHMAP_BITS_SOURCE_CATS__ */
