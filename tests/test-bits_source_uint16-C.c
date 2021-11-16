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
/*
 * ATS runtime routines.
 *
 * C programmers will have to supply whatever implementations they
 * deem appropriate for their program. (For instance,
 * atsruntime_malloc_undef and atsruntime_mfree_undef might call Boehm
 * GC instead of malloc/free.)
 */

void *
atsruntime_malloc_undef (size_t n)
{
  void *p = malloc (n);
  if (!p)
    {
      fprintf (stderr, "Virtual memory exhausted.\n");
      exit (1);
    }
  return p;
}

void
atsruntime_mfree_undef (void *p)
{
  free (p);
}

void
atsruntime_handle_unmatchedval (char *msg0)
{
  fprintf (stderr, "ATS error: unmatched value at run-time:\n%s\n",
	   msg0);
  exit (1);
}

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
  uint16_t hash;

  hash = 0x1234U;
  check (bits_source_uint16 (&hash, 0U) == 52);
  check (bits_source_uint16 (&hash, 1U) == 8);
  check (bits_source_uint16 (&hash, 2U) == 1);
  check (bits_source_uint16 (&hash, 3U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint16 (&hash, 4U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint16 (&hash, 5U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint16 (&hash, 6U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint16 (&hash, 7U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint16 (&hash, 8U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint16 (&hash, 9U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint16 (&hash, 10U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint16 (&hash, 11U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint16 (&hash, 100U) == BITS_SOURCE_EXHAUSTED);

  hash = 0xDEADU;
  check (bits_source_uint16 (&hash, 0U) == 45);
  check (bits_source_uint16 (&hash, 1U) == 58);
  check (bits_source_uint16 (&hash, 2U) == 13);
  check (bits_source_uint16 (&hash, 3U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint16 (&hash, 4U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint16 (&hash, 5U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint16 (&hash, 6U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint16 (&hash, 7U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint16 (&hash, 8U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint16 (&hash, 9U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint16 (&hash, 10U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint16 (&hash, 11U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_uint16 (&hash, 100U) == BITS_SOURCE_EXHAUSTED);
}

int
main (int argc, char *argv[])
{
  test_num_bits_eq_6 ();
}

/********************************************************************/
