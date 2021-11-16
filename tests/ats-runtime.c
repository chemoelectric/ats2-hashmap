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

#include <stdlib.h>
#include <stdio.h>

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
