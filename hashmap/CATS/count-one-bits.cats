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

#ifndef HASHMAP_IMPLEMENTATION_CATS_HEADER_GUARD__
#define HASHMAP_IMPLEMENTATION_CATS_HEADER_GUARD__

#include <count-one-bits.h>

#if 4 <= SIZEOF_UNSIGNED_INT
#define ats2_hashmap_count_one_bits_uint32 count_one_bits
#elif 4 <= SIZEOF_UNSIGNED_LONG_INT
#define ats2_hashmap_count_one_bits_uint32 count_one_bits_l
#elif 4 <= SIZEOF_UNSIGNED_LONG_LONG_INT
#define ats2_hashmap_count_one_bits_uint32 count_one_bits_ll
#else
#error "I failed to find an unsigned integer type at least 4 bytes long."
#endif

#if 8 <= SIZEOF_UNSIGNED_INT
#define ats2_hashmap_count_one_bits_uint64 count_one_bits
#elif 8 <= SIZEOF_UNSIGNED_LONG_INT
#define ats2_hashmap_count_one_bits_uint64 count_one_bits_l
#elif 8 <= SIZEOF_UNSIGNED_LONG_LONG_INT
#define ats2_hashmap_count_one_bits_uint64 count_one_bits_ll
#else
#error "I failed to find an unsigned integer type at least 8 bytes long."
#endif

#endif /* HASHMAP_IMPLEMENTATION_CATS_HEADER_GUARD__ */
