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

#include <hashmap/string2stringmap.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
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
test1 (void)
{
  bool result_found;
  const char *result;

  string2stringmap_t map = string2stringmap ();

  check (string2stringmap_is_empty (map));
  check (!string2stringmap_isnot_empty (map));
  check (string2stringmap_size (map) == 0);

  map = string2stringmap_set (map, "one", "ett");
  map = string2stringmap_set (map, "two", "två");
  map = string2stringmap_set (map, "three", "tre");

  check (!string2stringmap_is_empty (map));
  check (string2stringmap_isnot_empty (map));
  check (string2stringmap_size (map) == 3);

  string2stringmap_get (map, "one", &result_found, &result);
  check (result_found);
  check (strcmp (result, "ett") == 0);

  string2stringmap_get (map, "two", &result_found, &result);
  check (result_found);
  check (strcmp (result, "två") == 0);

  string2stringmap_get (map, "three", &result_found, &result);
  check (result_found);
  check (strcmp (result, "tre") == 0);

  string2stringmap_get (map, "four", &result_found, &result);
  check (!result_found);

  check (string2stringmap_has_key (map, "one"));
  check (string2stringmap_has_key (map, "two"));
  check (string2stringmap_has_key (map, "three"));
  check (!string2stringmap_has_key (map, "four"));

  string2stringmap_pairs_t pairs = string2stringmap_pairs (map);
  check ((strcmp (pairs->pair.key, "one") == 0
	  && strcmp (pairs->pair.value, "ett") == 0)
	 || (strcmp (pairs->pair.key, "two") == 0
	     && strcmp (pairs->pair.value, "två") == 0)
	 || (strcmp (pairs->pair.key, "three") == 0
	     && strcmp (pairs->pair.value, "tre") == 0));
  check ((strcmp (pairs->next->pair.key, "one") == 0
	  && strcmp (pairs->next->pair.value, "ett") == 0)
	 || (strcmp (pairs->next->pair.key, "two") == 0
	     && strcmp (pairs->next->pair.value, "två") == 0)
	 || (strcmp (pairs->next->pair.key, "three") == 0
	     && strcmp (pairs->next->pair.value, "tre") == 0));
  check ((strcmp (pairs->next->next->pair.key, "one") == 0
	  && strcmp (pairs->next->next->pair.value, "ett") == 0)
	 || (strcmp (pairs->next->next->pair.key, "two") == 0
	     && strcmp (pairs->next->next->pair.value, "två") == 0)
	 || (strcmp (pairs->next->next->pair.key, "three") == 0
	     && strcmp (pairs->next->next->pair.value, "tre") == 0));
  check (pairs->next->next->next == NULL);
  string2stringmap_pairs_free (pairs);

  string2stringmap_keys_t keys = string2stringmap_keys (map);
  check (strcmp (keys->key, "one") == 0 ||
	 strcmp (keys->key, "two") == 0
	 || strcmp (keys->key, "three") == 0);
  check (strcmp (keys->next->key, "one") == 0
	 || strcmp (keys->next->key, "two") == 0
	 || strcmp (keys->next->key, "three") == 0);
  check (strcmp (keys->next->next->key, "one") == 0
	 || strcmp (keys->next->next->key, "two") == 0
	 || strcmp (keys->next->next->key, "three") == 0);
  check (keys->next->next->next == NULL);
  string2stringmap_keys_free (keys);

  string2stringmap_values_t values = string2stringmap_values (map);
  check (strcmp (values->value, "ett") == 0
	 || strcmp (values->value, "två") == 0
	 || strcmp (values->value, "tre") == 0);
  check (strcmp (values->next->value, "ett") == 0
	 || strcmp (values->next->value, "två") == 0
	 || strcmp (values->next->value, "tre") == 0);
  check (strcmp (values->next->next->value, "ett") == 0
	 || strcmp (values->next->next->value, "två") == 0
	 || strcmp (values->next->next->value, "tre") == 0);
  check (values->next->next->next == NULL);
  string2stringmap_values_free (values);

  map = string2stringmap_del (map, "two");

  string2stringmap_get (map, "one", &result_found, &result);
  check (result_found);
  check (strcmp (result, "ett") == 0);

  string2stringmap_get (map, "two", &result_found, &result);
  check (!result_found);

  string2stringmap_get (map, "three", &result_found, &result);
  check (result_found);
  check (strcmp (result, "tre") == 0);

  string2stringmap_get (map, "four", &result_found, &result);
  check (!result_found);

  check (string2stringmap_has_key (map, "one"));
  check (!string2stringmap_has_key (map, "two"));
  check (string2stringmap_has_key (map, "three"));
  check (!string2stringmap_has_key (map, "four"));

  string2stringmap_free (map);
}

int
main (int argc, char *argv[])
{
  test1 ();
  return 0;
}

/********************************************************************/
