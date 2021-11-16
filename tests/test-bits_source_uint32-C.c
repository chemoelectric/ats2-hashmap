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
  uint32_t hash;

  hash = 0x12345678U;
  check (bits_source_uint32 (&hash, 0U) == 0x38);
  check (bits_source_uint32 (&hash, 1U) == 0x19);
  check (bits_source_uint32 (&hash, 2U) == 0x05);
  check (bits_source_uint32 (&hash, 3U) == 0x0D);
  check (bits_source_uint32 (&hash, 4U) == 0x12);
  check (bits_source_uint32 (&hash, 5U) == 0x00);
  check (bits_source_uint32 (&hash, 6U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint32 (&hash, 7U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint32 (&hash, 8U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint32 (&hash, 9U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint32 (&hash, 10U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint32 (&hash, 11U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint32 (&hash, 100U) == BITS_SOURCE_EXHAUSTED);

  hash = 0xDEADBEEFU;
  check (bits_source_uint32 (&hash, 0U) == 0x2F);
  check (bits_source_uint32 (&hash, 1U) == 0x3B);
  check (bits_source_uint32 (&hash, 2U) == 0x1B);
  check (bits_source_uint32 (&hash, 3U) == 0x2B);
  check (bits_source_uint32 (&hash, 4U) == 0x1E);
  check (bits_source_uint32 (&hash, 5U) == 0x03);
  check (bits_source_uint32 (&hash, 6U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint32 (&hash, 7U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint32 (&hash, 8U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint32 (&hash, 9U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint32 (&hash, 10U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint32 (&hash, 11U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint32 (&hash, 100U) == BITS_SOURCE_EXHAUSTED);
}

int
main (int argc, char *argv[])
{
  test_num_bits_eq_6 ();
}

/********************************************************************/
