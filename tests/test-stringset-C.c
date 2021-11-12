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

#include <hashmap/stringset.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

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

int
main (int argc, char *argv[])
{
  stringset_t set = stringset ();

  //printf ("%d\n", (int) stringset_is_empty (set));
  check (stringset_is_empty (set));
  //printf ("%d\n", (int) stringset_isnot_empty (set));
  check (!stringset_isnot_empty (set));
  //printf ("%zu\n", stringset_size (set));
  check (stringset_size (set) == 0);

  set = stringset_add (set, "one");
  set = stringset_add (set, "two");
  set = stringset_add (set, "three");

  //printf ("%d\n", (int) stringset_is_empty (set));
  check (!stringset_is_empty (set));
  //printf ("%d\n", (int) stringset_isnot_empty (set));
  check (stringset_isnot_empty (set));
  //printf ("%zu\n", stringset_size (set));
  check (stringset_size (set) == 3);

  //printf ("%d\n", (int) stringset_contains (set, "one"));
  check (stringset_contains (set, "one"));

  //printf ("%d\n", (int) stringset_contains (set, "two"));
  check (stringset_contains (set, "two"));

  //printf ("%d\n", (int) stringset_contains (set, "three"));
  check (stringset_contains (set, "three"));

  //printf ("%d\n", (int) stringset_contains (set, "four"));
  check (!stringset_contains (set, "four"));

  stringset_elements_t elements = stringset_elements (set);
  //printf ("%s\n", elements->element);
  //printf ("%s\n", elements->next->element);
  //printf ("%s\n", elements->next->next->element);
  check (strcmp (elements->element, "one") == 0 ||
	 strcmp (elements->element, "two") == 0 ||
	 strcmp (elements->element, "three") == 0);
  check (strcmp (elements->next->element, "one") == 0 ||
	 strcmp (elements->next->element, "two") == 0 ||
	 strcmp (elements->next->element, "three") == 0);
  check (strcmp (elements->next->next->element, "one") == 0 ||
	 strcmp (elements->next->next->element, "two") == 0 ||
	 strcmp (elements->next->next->element, "three") == 0);
  check (elements->next->next->next == NULL);
  stringset_elements_free (elements);

  set = stringset_del (set, "two");

  //printf ("%d\n", (int) stringset_contains (set, "one"));
  check (stringset_contains (set, "one"));

  //printf ("%d\n", (int) stringset_contains (set, "two"));
  check (!stringset_contains (set, "two"));

  //printf ("%d\n", (int) stringset_contains (set, "three"));
  check (stringset_contains (set, "three"));

  //printf ("%d\n", (int) stringset_contains (set, "four"));
  check (!stringset_contains (set, "four"));

  stringset_free (set);

  return 0;
}
