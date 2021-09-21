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

#ifndef ATS2_HASHMAP_CATS_BITS_SOURCE_CATS_HEADER_GUARD__
#define ATS2_HASHMAP_CATS_BITS_SOURCE_CATS_HEADER_GUARD__

#ifndef ats2_hashmap_attribute_const_inline

#ifdef __GNUC__

/* One-time-initialized functions always return the same value.
   Therefore they are ‘const’ in the GCC sense and can be treated
   specially by the C optimizer. */

#if 10 <= __GNUC__
#define ats2_hashmap_attribute_const_inline [[gnu::const]] ATSinline()
#else
#define ats2_hashmap_attribute_const_inline __attribute__((__const__)) ATSinline()
#endif

#else /* !__GNUC__ */

#define ats2_hashmap_attribute_const_inline ATSinline()

#endif /* !__GNUC__ */

#endif /* !ats2_hashmap_attribute_const_inline */

#define ATS2_HASHMAP_BITS_SOURCE_FUNCTION(TYPE)             \
  ats2_hashmap_attribute_const_inline atstype_ptr           \
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

#endif /* ATS2_HASHMAP_CATS_BITS_SOURCE_CATS_HEADER_GUARD__ */
