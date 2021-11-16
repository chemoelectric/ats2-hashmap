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
  uint8_t hash = 0x96U;
  check (bits_source_uint8 (&hash, 0U) == 0x16);
  check (bits_source_uint8 (&hash, 1U) == 0x02);
  check (bits_source_uint8 (&hash, 2U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint8 (&hash, 3U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint8 (&hash, 4U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint8 (&hash, 5U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint8 (&hash, 100U) == BITS_SOURCE_EXHAUSTED);
}

int
main (int argc, char *argv[])
{
  test_num_bits_eq_6 ();
}

/********************************************************************/
