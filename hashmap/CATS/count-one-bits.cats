/* count-one-bits.cats -- counts the number of 1-bits in a word.
   Copyright © 2007-2021 Free Software Foundation, Inc.
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

   Written by Ben Pfaff. (See the count-one-bits module of Gnulib.)

   Modified for ats2-hashmap by Barry Schwartz.

*/

#ifndef HASHMAP_COUNT_ONE_BITS_CATS_HEADER_GUARD__
#define HASHMAP_COUNT_ONE_BITS_CATS_HEADER_GUARD__

#include <limits.h>
#include <stdlib.h>

#define ATS2_HASHMAP_COUNT_ONE_BITS_INLINE ATSinline ()

/* Assuming the GCC builtin is GCC_BUILTIN and the MSC builtin is MSC_BUILTIN,
   expand to code that computes the number of 1-bits of the local
   variable 'x' of type TYPE (an unsigned integer type) and return it
   from the current function.  */
#if (__GNUC__ > 3 || (__GNUC__ == 3 && __GNUC_MINOR__ >= 4)) \
    || (__clang_major__ >= 4)
# define ATS2_HASHMAP_COUNT_ONE_BITS(GCC_BUILTIN, MSC_BUILTIN, TYPE) \
    return GCC_BUILTIN (x)
#else

/* Compute and return the number of 1-bits set in the least
   significant 32 bits of X. */
ATS2_HASHMAP_COUNT_ONE_BITS_INLINE int
ats2_hashmap_count_one_bits_32 (unsigned int x)
{
  x = ((x & 0xaaaaaaaaU) >> 1) + (x & 0x55555555U);
  x = ((x & 0xccccccccU) >> 2) + (x & 0x33333333U);
  x = (x >> 16) + (x & 0xffff);
  x = ((x & 0xf0f0) >> 4) + (x & 0x0f0f);
  return (x >> 8) + (x & 0x00ff);
}

/* Expand to code that computes the number of 1-bits of the local
   variable 'x' of type TYPE (an unsigned integer type) and return it
   from the current function.  */
# define ATS2_HASHMAP_COUNT_ONE_BITS_GENERIC(TYPE)                      \
    do                                                                  \
      {                                                                 \
        int count = 0;                                                  \
        int bits;                                                       \
        for (bits = 0; bits < sizeof (TYPE) * CHAR_BIT; bits += 32)     \
          {                                                             \
            count += count_one_bits_32 (x);                             \
            x = x >> 31 >> 1;                                           \
          }                                                             \
        return count;                                                   \
      }                                                                 \
    while (0)

# if 1500 <= _MSC_VER && (defined _M_IX86 || defined _M_X64)

/*
  FIXME: It seems to me (Barry Schwartz) that this code should use
         atomic operations and a double-checked lock for the
         ‘ats2_hashmap_popcount_support’ variable.

         I, personally, have no way to use this code, anyway.
*/

/* While gcc falls back to its own generic code if the machine
   on which it's running doesn't support popcount, with Microsoft's
   compiler we need to detect and fallback ourselves.  */

#  if 0
#   include <intrin.h>
#  else
    /* Don't pollute the namespace with too many MSVC intrinsics.  */
#   pragma intrinsic (__cpuid)
#   pragma intrinsic (__popcnt)
#   if defined _M_X64
#    pragma intrinsic (__popcnt64)
#   endif
#  endif

#  if !defined _M_X64
static inline __popcnt64 (unsigned long long x)
{
  return __popcnt ((unsigned int) (x >> 32)) + __popcnt ((unsigned int) x);
}
#  endif

/* Return nonzero if popcount is supported.  */


/* 1 if supported, 0 if not supported, -1 if unknown.  */
extern int ats2_hashmap_popcount_support;

ATS2_HASHMAP_COUNT_ONE_BITS_INLINE int
ats2_hashmap_popcount_supported (void)
{
  if (ats2_hashmap_popcount_support < 0)
    {
      /* Do as described in
         <https://docs.microsoft.com/en-us/cpp/intrinsics/popcnt16-popcnt-popcnt64> */
      int cpu_info[4];
      __cpuid (cpu_info, 1);
      ats2_hashmap_popcount_support = (cpu_info[2] >> 23) & 1;
    }
  return ats2_hashmap_popcount_support;
}

#  define ATS2_HASHMAP_COUNT_ONE_BITS(GCC_BUILTIN, MSC_BUILTIN, TYPE)   \
     do                                                                 \
       {                                                                \
         if (ats2_hashmap_popcount_supported ())                        \
           return MSC_BUILTIN (x);                                      \
         else                                                           \
           ATS2_HASHMAP_COUNT_ONE_BITS_GENERIC (TYPE);                  \
       }                                                                \
     while (0)

# else

#  define ATS2_HASHMAP_COUNT_ONE_BITS(GCC_BUILTIN, MSC_BUILTIN, TYPE) \
     ATS2_HASHMAP_COUNT_ONE_BITS_GENERIC (TYPE)

# endif
#endif

/* Compute and return the number of 1-bits set in X. */
ATS2_HASHMAP_COUNT_ONE_BITS_INLINE int
ats2_hashmap_count_one_bits_uint (unsigned int x)
{
  ATS2_HASHMAP_COUNT_ONE_BITS (__builtin_popcount, __popcnt, unsigned int);
}

/* Compute and return the number of 1-bits set in X. */
ATS2_HASHMAP_COUNT_ONE_BITS_INLINE int
ats2_hashmap_count_one_bits_ulint (unsigned long int x)
{
  ATS2_HASHMAP_COUNT_ONE_BITS (__builtin_popcountl, __popcnt, unsigned long int);
}

/* Compute and return the number of 1-bits set in X. */
ATS2_HASHMAP_COUNT_ONE_BITS_INLINE int
ats2_hashmap_count_one_bits_ullint (unsigned long long int x)
{
  ATS2_HASHMAP_COUNT_ONE_BITS (__builtin_popcountll, __popcnt64, unsigned long long int);
}

#if SIZEOF_UINTPTR_T <= SIZEOF_UNSIGNED_INT
#define ats2_hashmap_count_one_bits_uintptr ats2_hashmap_count_one_bits_uint
#elif SIZEOF_UINTPTR_T <= SIZEOF_UNSIGNED_LONG_INT
#define ats2_hashmap_count_one_bits_uintptr ats2_hashmap_count_one_bits_ulint
#elif SIZEOF_UINTPTR_T <= SIZEOF_UNSIGNED_LONG_LONG_INT
#define ats2_hashmap_count_one_bits_uintptr ats2_hashmap_count_one_bits_ullint
#else
#error "I failed to find a count-one-bits implementation for uintptr_t."
#endif

/* Compute and return the number of 1-bits set in X,
   ignoring all bits of index i or higher. */
ATS2_HASHMAP_COUNT_ONE_BITS_INLINE int
ats2_hashmap_count_low_one_bits_uint (unsigned int x, int i)
{
  return ats2_hashmap_count_one_bits_uint (x & ~((~(unsigned int) 0) << i));
}

/* Compute and return the number of 1-bits set in X,
   ignoring all bits of index i or higher. */
ATS2_HASHMAP_COUNT_ONE_BITS_INLINE int
ats2_hashmap_count_low_one_bits_ulint (unsigned long int x, int i)
{
  return ats2_hashmap_count_one_bits_ulint (x & ~((~(unsigned long int) 0) << i));
}

/* Compute and return the number of 1-bits set in X,
   ignoring all bits of index i or higher. */
ATS2_HASHMAP_COUNT_ONE_BITS_INLINE int
ats2_hashmap_count_low_one_bits_ullint (unsigned long long int x, int i)
{
  return ats2_hashmap_count_one_bits_ullint (x & ~((~(unsigned long long int) 0) << i));
}

/* Compute and return the number of 1-bits set in X,
   ignoring all bits of index i or higher. */
ATS2_HASHMAP_COUNT_ONE_BITS_INLINE int
ats2_hashmap_count_low_one_bits_uintptr (uintptr_t x, int i)
{
  return ats2_hashmap_count_one_bits_uintptr (x & ~((~(uintptr_t) 0) << i));
}

#endif /* HASHMAP_COUNT_ONE_BITS_CATS_HEADER_GUARD__ */
