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

#include <hashmap/bits_source.h>
#include <stdlib.h>
#include <stdio.h>
#include <inttypes.h>

/********************************************************************/

#define check(expr)                                     \
  ((expr) ?                                             \
   ((void) 0) :                                         \
   check_fail (#expr, __FILE__, __LINE__, __func__))

static void
check_fail (const char *expr, const char *file, size_t line,
	    const char *func)
{
  fprintf (stderr, "check failed: ‘%s’ in %s at %s:%zu\n",
	   expr, func, file, line);
  exit (1);
}

void
test_num_bits_eq_6 (void)
{
  struct
  {
    uint64_t u0;
    uint64_t u1;
  } hash;
  hash.u0 = 0xBA5EBA11FACEF00DULL;
  hash.u1 = 0xDEADBEEF12345678ULL;
  check (bits_source_uint64_uint64 (&hash, 0U) == 0x0D);
  check (bits_source_uint64_uint64 (&hash, 1U) == 0x00);
  check (bits_source_uint64_uint64 (&hash, 2U) == 0x2F);
  check (bits_source_uint64_uint64 (&hash, 3U) == 0x33);
  check (bits_source_uint64_uint64 (&hash, 4U) == 0x3A);
  check (bits_source_uint64_uint64 (&hash, 5U) == 0x07);
  check (bits_source_uint64_uint64 (&hash, 6U) == 0x21);
  check (bits_source_uint64_uint64 (&hash, 7U) == 0x2E);
  check (bits_source_uint64_uint64 (&hash, 8U) == 0x1E);
  check (bits_source_uint64_uint64 (&hash, 9U) == 0x29);
  check (bits_source_uint64_uint64 (&hash, 10U) == 0x0B);
  check (bits_source_uint64_uint64 (&hash, 11U) == 0x1E);
  check (bits_source_uint64_uint64 (&hash, 12U) == 0x16);
  check (bits_source_uint64_uint64 (&hash, 13U) == 0x11);
  check (bits_source_uint64_uint64 (&hash, 14U) == 0x23);
  check (bits_source_uint64_uint64 (&hash, 15U) == 0x04);
  check (bits_source_uint64_uint64 (&hash, 16U) == 0x2F);
  check (bits_source_uint64_uint64 (&hash, 17U) == 0x3B);
  check (bits_source_uint64_uint64 (&hash, 18U) == 0x1B);
  check (bits_source_uint64_uint64 (&hash, 19U) == 0x2B);
  check (bits_source_uint64_uint64 (&hash, 20U) == 0x1E);
  check (bits_source_uint64_uint64 (&hash, 21U) == 0x03);
  check (bits_source_uint64_uint64 (&hash, 22U) ==
	 BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint64_uint64 (&hash, 23U) ==
	 BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint64_uint64 (&hash, 24U) ==
	 BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint64_uint64 (&hash, 25U) ==
	 BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint64_uint64 (&hash, 26U) ==
	 BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint64_uint64 (&hash, 27U) ==
	 BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint64_uint64 (&hash, 28U) ==
	 BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint64_uint64 (&hash, 29U) ==
	 BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint64_uint64 (&hash, 30U) ==
	 BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint64_uint64 (&hash, 31U) ==
	 BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint64_uint64 (&hash, 32U) ==
	 BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint64_uint64 (&hash, 33U) ==
	 BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint64_uint64 (&hash, 34U) ==
	 BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint64_uint64 (&hash, 35U) ==
	 BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint64_uint64 (&hash, 100U) ==
	 BITS_SOURCE_EXHAUSTED);
}

int
main (int argc, char *argv[])
{
  test_num_bits_eq_6 ();
}

/********************************************************************/
