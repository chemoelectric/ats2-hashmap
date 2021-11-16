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

include(`common-macros.m4')dnl

#ifndef HEADER_GUARD_FOR_ATS2_HASHMAP_HASHMAP_BITS_SOURCE_H__
#define HEADER_GUARD_FOR_ATS2_HASHMAP_HASHMAP_BITS_SOURCE_H__

#include <stddef.h>
#include <stdint.h>

/********************************************************************/

typedef int ats2_hashmap_bits_source_func_t (void *hash,
                                             unsigned int depth);
typedef ats2_hashmap_bits_source_func_t *ats2_hashmap_bits_source_t;

#define ATS2_HASHMAP_BITS_SOURCE_EXHAUSTED (-1)

/********************************************************************/

/* For hash values that are integers stored in native-endian order. */
ats2_hashmap_bits_source_func_t ats2_055_hashmap__bits_source_uint8;
ats2_hashmap_bits_source_func_t ats2_055_hashmap__bits_source_uint16;
ats2_hashmap_bits_source_func_t ats2_055_hashmap__bits_source_uint32;
ats2_hashmap_bits_source_func_t ats2_055_hashmap__bits_source_uint64;

/* For hash values that are two uint64_t stored in native-endian
   order, with the first uint64_t used as a bit source first.
   (This is a common way to store 128-bit integers while employing
   only standard C.) */
ats2_hashmap_bits_source_func_t
  ats2_055_hashmap__bits_source_uint64_uint64;

/* For hash values that are anything stored in byte-address order. */
ats2_hashmap_bits_source_func_t ats2_055_hashmap__bits_source_1byte;
m4_forloop(`i',2,64,`ats2_hashmap_bits_source_func_t ats2_055_hashmap__bits_source_`'i`'bytes;
')dnl

/********************************************************************/

/* The following macro names are nicer to use than the names declared
   above. */

#define BITS_SOURCE_EXHAUSTED ATS2_HASHMAP_BITS_SOURCE_EXHAUSTED

#define bits_source_func_t ats2_hashmap_bits_source_func_t
#define bits_source_t ats2_hashmap_bits_source_t

#define bits_source_uint8 ats2_055_hashmap__bits_source_uint8
#define bits_source_uint16 ats2_055_hashmap__bits_source_uint16
#define bits_source_uint32 ats2_055_hashmap__bits_source_uint32
#define bits_source_uint64 ats2_055_hashmap__bits_source_uint64

#define bits_source_uint64_uint64 ats2_055_hashmap__bits_source_uint64_uint64

#define bits_source_1byte ats2_055_hashmap__bits_source_1byte
m4_forloop(`i',2,64,`#define bits_source_`'i`'bytes ats2_055_hashmap__bits_source_`'i`'bytes
')dnl

/********************************************************************/

#endif /* HEADER_GUARD_FOR_ATS2_HASHMAP_HASHMAP_BITS_SOURCE_H__ */
