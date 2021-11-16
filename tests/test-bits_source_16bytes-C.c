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
  uint8_t hash[16] = {
    0x0D,
    0xF0,
    0xCE,
    0xFA,
    0x11,
    0xBA,
    0x5E,
    0xBA,
    0x78,
    0x56,
    0x34,
    0x12,
    0xEF,
    0xBE,
    0xAD,
    0xDE
  };
  check (bits_source_16bytes (hash, 0U) == 0x0D);
  check (bits_source_16bytes (hash, 1U) == 0x00);
  check (bits_source_16bytes (hash, 2U) == 0x2F);
  check (bits_source_16bytes (hash, 3U) == 0x33);
  check (bits_source_16bytes (hash, 4U) == 0x3A);
  check (bits_source_16bytes (hash, 5U) == 0x07);
  check (bits_source_16bytes (hash, 6U) == 0x21);
  check (bits_source_16bytes (hash, 7U) == 0x2E);
  check (bits_source_16bytes (hash, 8U) == 0x1E);
  check (bits_source_16bytes (hash, 9U) == 0x29);
  check (bits_source_16bytes (hash, 10U) == 0x0B);
  check (bits_source_16bytes (hash, 11U) == 0x1E);
  check (bits_source_16bytes (hash, 12U) == 0x16);
  check (bits_source_16bytes (hash, 13U) == 0x11);
  check (bits_source_16bytes (hash, 14U) == 0x23);
  check (bits_source_16bytes (hash, 15U) == 0x04);
  check (bits_source_16bytes (hash, 16U) == 0x2F);
  check (bits_source_16bytes (hash, 17U) == 0x3B);
  check (bits_source_16bytes (hash, 18U) == 0x1B);
  check (bits_source_16bytes (hash, 19U) == 0x2B);
  check (bits_source_16bytes (hash, 20U) == 0x1E);
  check (bits_source_16bytes (hash, 21U) == 0x03);
  check (bits_source_16bytes (hash, 22U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_16bytes (hash, 23U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_16bytes (hash, 24U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_16bytes (hash, 25U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_16bytes (hash, 26U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_16bytes (hash, 27U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_16bytes (hash, 28U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_16bytes (hash, 29U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_16bytes (hash, 30U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_16bytes (hash, 31U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_16bytes (hash, 32U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_16bytes (hash, 33U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_16bytes (hash, 34U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_16bytes (hash, 35U) == BITS_SOURCE_EXHAUSTED);
  check (bits_source_16bytes (hash, 100U) == BITS_SOURCE_EXHAUSTED);
}

int
main (int argc, char *argv[])
{
  test_num_bits_eq_6 ();
}

/********************************************************************/
