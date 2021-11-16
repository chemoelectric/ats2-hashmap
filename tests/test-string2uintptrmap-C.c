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

#include <hashmap/string2uintptrmap.h>
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

bool value_is_freed;
void *value_freed_env;

void
value_free (uintptr_t v, void *environment)
{
  value_is_freed = true;
  value_freed_env = environment;
}

bool value_is_copied;
void *value_copied_env;

uintptr_t
value_copy (uintptr_t v, void *environment)
{
  value_is_copied = true;
  value_copied_env = environment;
  return v;
}

void
test1 (void)
{
  bool result_found;
  uintptr_t result;

  string2uintptrmap_t map = string2uintptrmap ();

  //printf ("%d\n", (int) string2uintptrmap_is_empty (map));
  check (string2uintptrmap_is_empty (map));
  //printf ("%d\n", (int) string2uintptrmap_isnot_empty (map));
  check (!string2uintptrmap_isnot_empty (map));
  //printf ("%zu\n", string2uintptrmap_size (map));
  check (string2uintptrmap_size (map) == 0);

  map = string2uintptrmap_set (map, "one", 1, NULL, NULL);
  map = string2uintptrmap_set (map, "two", 2, NULL, NULL);
  map = string2uintptrmap_set (map, "three", 3, NULL, NULL);

  //printf ("%d\n", (int) string2uintptrmap_is_empty (map));
  check (!string2uintptrmap_is_empty (map));
  //printf ("%d\n", (int) string2uintptrmap_isnot_empty (map));
  check (string2uintptrmap_isnot_empty (map));
  //printf ("%zu\n", string2uintptrmap_size (map));
  check (string2uintptrmap_size (map) == 3);

  string2uintptrmap_get (map, "one", NULL, NULL, &result_found,
			 &result);
  //printf ("%d %zu\n", (int) result_found, result);
  check (result_found);
  check (result == 1);

  string2uintptrmap_get (map, "two", NULL, NULL, &result_found,
			 &result);
  //printf ("%d %zu\n", (int) result_found, result);
  check (result_found);
  check (result == 2);

  string2uintptrmap_get (map, "three", NULL, NULL, &result_found,
			 &result);
  //printf ("%d %zu\n", (int) result_found, result);
  check (result_found);
  check (result == 3);

  string2uintptrmap_get (map, "four", NULL, NULL, &result_found,
			 &result);
  //printf ("%d\n", (int) result_found);
  check (!result_found);

  //printf ("%d\n", (int) string2uintptrmap_has_key (map, "one"));
  check (string2uintptrmap_has_key (map, "one"));

  //printf ("%d\n", (int) string2uintptrmap_has_key (map, "two"));
  check (string2uintptrmap_has_key (map, "two"));

  //printf ("%d\n", (int) string2uintptrmap_has_key (map, "three"));
  check (string2uintptrmap_has_key (map, "three"));

  //printf ("%d\n", (int) string2uintptrmap_has_key (map, "four"));
  check (!string2uintptrmap_has_key (map, "four"));

  string2uintptrmap_pairs_t pairs =
    string2uintptrmap_pairs (map, NULL, NULL);
  //printf ("%s %" PRIuPTR "\n", pairs->pair.key, pairs->pair.value);
  //printf ("%s %" PRIuPTR "\n", pairs->next->pair.key, pairs->next->pair.value);
  //printf ("%s %" PRIuPTR "\n", pairs->next->next->pair.key, pairs->next->next->pair.value);
  check ((strcmp (pairs->pair.key, "one") == 0
	  && pairs->pair.value == 1)
	 || (strcmp (pairs->pair.key, "two") == 0
	     && pairs->pair.value == 2)
	 || (strcmp (pairs->pair.key, "three") == 0
	     && pairs->pair.value == 3));
  check ((strcmp (pairs->next->pair.key, "one") == 0
	  && pairs->next->pair.value == 1)
	 || (strcmp (pairs->next->pair.key, "two") == 0
	     && pairs->next->pair.value == 2)
	 || (strcmp (pairs->next->pair.key, "three") == 0
	     && pairs->next->pair.value == 3));
  check ((strcmp (pairs->next->next->pair.key, "one") == 0
	  && pairs->next->next->pair.value == 1)
	 || (strcmp (pairs->next->next->pair.key, "two") == 0
	     && pairs->next->next->pair.value == 2)
	 || (strcmp (pairs->next->next->pair.key, "three") == 0
	     && pairs->next->next->pair.value == 3));
  check (pairs->next->next->next == NULL);
  string2uintptrmap_pairs_free (pairs, NULL, NULL);

  string2uintptrmap_keys_t keys = string2uintptrmap_keys (map);
  //printf ("%s\n", keys->key);
  //printf ("%s\n", keys->next->key);
  //printf ("%s\n", keys->next->next->key);
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
  string2uintptrmap_keys_free (keys);

  string2uintptrmap_values_t values =
    string2uintptrmap_values (map, NULL, NULL);
  //printf ("%" PRIuPTR "\n", values->value);
  //printf ("%" PRIuPTR "\n", values->next->value);
  //printf ("%" PRIuPTR "\n", values->next->next->value);
  check (values->value == 1 || values->value == 2
	 || values->value == 3);
  check (values->next->value == 1 || values->next->value == 2
	 || values->next->value == 3);
  check (values->next->next->value == 1
	 || values->next->next->value == 2
	 || values->next->next->value == 3);
  check (values->next->next->next == NULL);
  string2uintptrmap_values_free (values, NULL, NULL);

  map = string2uintptrmap_del (map, "two", NULL, NULL);

  string2uintptrmap_get (map, "one", NULL, NULL, &result_found,
			 &result);
  //printf ("%d %zu\n", (int) result_found, result);
  check (result_found);
  check (result == 1);

  string2uintptrmap_get (map, "two", NULL, NULL, &result_found,
			 &result);
  //printf ("%d\n", (int) result_found, result);
  check (!result_found);

  string2uintptrmap_get (map, "three", NULL, NULL, &result_found,
			 &result);
  //printf ("%d %zu\n", (int) result_found, result);
  check (result_found);
  check (result == 3);

  string2uintptrmap_get (map, "four", NULL, NULL, &result_found,
			 &result);
  //printf ("%d\n", (int) result_found);
  check (!result_found);

  //printf ("%d\n", (int) string2uintptrmap_has_key (map, "one"));
  check (string2uintptrmap_has_key (map, "one"));

  //printf ("%d\n", (int) string2uintptrmap_has_key (map, "two"));
  check (!string2uintptrmap_has_key (map, "two"));

  //printf ("%d\n", (int) string2uintptrmap_has_key (map, "three"));
  check (string2uintptrmap_has_key (map, "three"));

  //printf ("%d\n", (int) string2uintptrmap_has_key (map, "four"));
  check (!string2uintptrmap_has_key (map, "four"));

  string2uintptrmap_free (map, NULL, NULL);
}

void
test2 (void)
{
  string2uintptrmap_t map;

  map = string2uintptrmap ();
  value_is_freed = false;
  value_freed_env = NULL;
  map = string2uintptrmap_set (map, "one", 1, NULL, NULL);
  check (!value_is_freed);
  check (value_freed_env == NULL);
  map = string2uintptrmap_set (map, "one", 1, NULL, NULL);
  check (!value_is_freed);
  check (value_freed_env == NULL);
  map = string2uintptrmap_set (map, "one", 1, value_free, NULL);
  check (value_is_freed);
  check (value_freed_env == NULL);
  string2uintptrmap_free (map, NULL, NULL);

  map = string2uintptrmap ();
  value_is_freed = false;
  value_freed_env = NULL;
  map = string2uintptrmap_set (map, "one", 1, value_free, NULL);
  check (!value_is_freed);
  check (value_freed_env == NULL);
  map = string2uintptrmap_set (map, "one", 1, value_free, NULL);
  check (value_is_freed);
  check (value_freed_env == NULL);
  map =
    string2uintptrmap_set (map, "one", 1, value_free,
			   &value_freed_env);
  check (value_is_freed);
  check (value_freed_env == &value_freed_env);
  string2uintptrmap_free (map, NULL, NULL);
}

void
test3 (void)
{
  string2uintptrmap_t map;

  map = string2uintptrmap ();
  value_is_freed = false;
  value_freed_env = NULL;
  map = string2uintptrmap_set (map, "one", 1, NULL, NULL);
  check (!value_is_freed);
  check (value_freed_env == NULL);
  map = string2uintptrmap_del (map, "one", NULL, NULL);
  check (!value_is_freed);
  check (value_freed_env == NULL);
  string2uintptrmap_free (map, NULL, NULL);

  map = string2uintptrmap ();
  value_is_freed = false;
  value_freed_env = NULL;
  map = string2uintptrmap_set (map, "one", 1, value_free, NULL);
  check (!value_is_freed);
  check (value_freed_env == NULL);
  map = string2uintptrmap_del (map, "one", value_free, NULL);
  check (value_is_freed);
  check (value_freed_env == NULL);
  string2uintptrmap_free (map, NULL, NULL);

  map = string2uintptrmap ();
  value_is_freed = false;
  value_freed_env = NULL;
  map =
    string2uintptrmap_set (map, "one", 1, value_free,
			   &value_freed_env);
  check (!value_is_freed);
  check (value_freed_env == NULL);
  map =
    string2uintptrmap_del (map, "one", value_free, &value_freed_env);
  check (value_is_freed);
  check (value_freed_env == &value_freed_env);
  string2uintptrmap_free (map, NULL, NULL);
}

void
test4 (void)
{
  bool result_found;
  uintptr_t result;
  string2uintptrmap_t map;

  map = string2uintptrmap ();

  value_is_copied = false;
  value_copied_env = NULL;
  map = string2uintptrmap_set (map, "one", 1, NULL, NULL);
  check (!value_is_copied);
  check (value_copied_env == NULL);

  string2uintptrmap_get (map, "one", NULL, NULL, &result_found,
			 &result);
  check (result_found);
  check (result == 1);
  check (!value_is_copied);
  check (value_copied_env == NULL);

  string2uintptrmap_get (map, "one", value_copy, NULL,
			 &result_found, &result);
  check (result_found);
  check (result == 1);
  check (value_is_copied);
  check (value_copied_env == NULL);

  string2uintptrmap_get (map, "one", value_copy, &result,
			 &result_found, &result);
  check (result_found);
  check (result == 1);
  check (value_is_copied);
  check (value_copied_env == &result);

  string2uintptrmap_free (map, NULL, NULL);
}

void
test5 (void)
{
  string2uintptrmap_t map;
  string2uintptrmap_pairs_t pairs;

  map = string2uintptrmap ();

  map = string2uintptrmap_set (map, "one", 1, NULL, NULL);
  map = string2uintptrmap_set (map, "two", 2, NULL, NULL);
  map = string2uintptrmap_set (map, "three", 3, NULL, NULL);

  value_is_copied = false;
  value_copied_env = NULL;
  value_is_freed = false;
  value_freed_env = NULL;
  pairs = string2uintptrmap_pairs (map, NULL, NULL);
  check (!value_is_copied);
  check (value_copied_env == NULL);
  check (!value_is_freed);
  check (value_freed_env == NULL);
  value_is_copied = false;
  value_copied_env = NULL;
  value_is_freed = false;
  value_freed_env = NULL;
  string2uintptrmap_pairs_free (pairs, NULL, NULL);
  check (!value_is_copied);
  check (value_copied_env == NULL);
  check (!value_is_freed);
  check (value_freed_env == NULL);

  value_is_copied = false;
  value_copied_env = NULL;
  value_is_freed = false;
  value_freed_env = NULL;
  pairs = string2uintptrmap_pairs (map, value_copy, NULL);
  check (value_is_copied);
  check (value_copied_env == NULL);
  check (!value_is_freed);
  check (value_freed_env == NULL);
  value_is_copied = false;
  value_copied_env = NULL;
  value_is_freed = false;
  value_freed_env = NULL;
  string2uintptrmap_pairs_free (pairs, value_free, NULL);
  check (!value_is_copied);
  check (value_copied_env == NULL);
  check (value_is_freed);
  check (value_freed_env == NULL);

  value_is_copied = false;
  value_copied_env = NULL;
  value_is_freed = false;
  value_freed_env = NULL;
  pairs = string2uintptrmap_pairs (map, value_copy, &value_copy);
  check (value_is_copied);
  check (value_copied_env == &value_copy);
  check (!value_is_freed);
  check (value_freed_env == NULL);
  value_is_copied = false;
  value_copied_env = NULL;
  value_is_freed = false;
  value_freed_env = NULL;
  string2uintptrmap_pairs_free (pairs, value_free, &value_free);
  check (!value_is_copied);
  check (value_copied_env == NULL);
  check (value_is_freed);
  check (value_freed_env == &value_free);

  string2uintptrmap_free (map, NULL, NULL);
}

void
test6 (void)
{
  string2uintptrmap_t map;
  string2uintptrmap_values_t values;

  map = string2uintptrmap ();

  map = string2uintptrmap_set (map, "one", 1, NULL, NULL);
  map = string2uintptrmap_set (map, "two", 2, NULL, NULL);
  map = string2uintptrmap_set (map, "three", 3, NULL, NULL);

  value_is_copied = false;
  value_copied_env = NULL;
  value_is_freed = false;
  value_freed_env = NULL;
  values = string2uintptrmap_values (map, NULL, NULL);
  check (!value_is_copied);
  check (value_copied_env == NULL);
  check (!value_is_freed);
  check (value_freed_env == NULL);
  value_is_copied = false;
  value_copied_env = NULL;
  value_is_freed = false;
  value_freed_env = NULL;
  string2uintptrmap_values_free (values, NULL, NULL);
  check (!value_is_copied);
  check (value_copied_env == NULL);
  check (!value_is_freed);
  check (value_freed_env == NULL);

  value_is_copied = false;
  value_copied_env = NULL;
  value_is_freed = false;
  value_freed_env = NULL;
  values = string2uintptrmap_values (map, value_copy, NULL);
  check (value_is_copied);
  check (value_copied_env == NULL);
  check (!value_is_freed);
  check (value_freed_env == NULL);
  value_is_copied = false;
  value_copied_env = NULL;
  value_is_freed = false;
  value_freed_env = NULL;
  string2uintptrmap_values_free (values, value_free, NULL);
  check (!value_is_copied);
  check (value_copied_env == NULL);
  check (value_is_freed);
  check (value_freed_env == NULL);

  value_is_copied = false;
  value_copied_env = NULL;
  value_is_freed = false;
  value_freed_env = NULL;
  values = string2uintptrmap_values (map, value_copy, &value_copy);
  check (value_is_copied);
  check (value_copied_env == &value_copy);
  check (!value_is_freed);
  check (value_freed_env == NULL);
  value_is_copied = false;
  value_copied_env = NULL;
  value_is_freed = false;
  value_freed_env = NULL;
  string2uintptrmap_values_free (values, value_free, &value_free);
  check (!value_is_copied);
  check (value_copied_env == NULL);
  check (value_is_freed);
  check (value_freed_env == &value_free);

  string2uintptrmap_free (map, NULL, NULL);
}

void
test7 (void)
{
  string2uintptrmap_t map;

  map = string2uintptrmap ();
  map = string2uintptrmap_set (map, "one", 1, NULL, NULL);
  map = string2uintptrmap_set (map, "two", 2, NULL, NULL);
  map = string2uintptrmap_set (map, "three", 3, NULL, NULL);
  value_is_copied = false;
  value_copied_env = NULL;
  value_is_freed = false;
  value_freed_env = NULL;
  string2uintptrmap_free (map, NULL, NULL);
  check (!value_is_copied);
  check (value_copied_env == NULL);
  check (!value_is_freed);
  check (value_freed_env == NULL);

  map = string2uintptrmap ();
  map = string2uintptrmap_set (map, "one", 1, NULL, NULL);
  map = string2uintptrmap_set (map, "two", 2, NULL, NULL);
  map = string2uintptrmap_set (map, "three", 3, NULL, NULL);
  value_is_copied = false;
  value_copied_env = NULL;
  value_is_freed = false;
  value_freed_env = NULL;
  string2uintptrmap_free (map, value_free, NULL);
  check (!value_is_copied);
  check (value_copied_env == NULL);
  check (value_is_freed);
  check (value_freed_env == NULL);


  map = string2uintptrmap ();
  map = string2uintptrmap_set (map, "one", 1, NULL, NULL);
  map = string2uintptrmap_set (map, "two", 2, NULL, NULL);
  map = string2uintptrmap_set (map, "three", 3, NULL, NULL);
  value_is_copied = false;
  value_copied_env = NULL;
  value_is_freed = false;
  value_freed_env = NULL;
  string2uintptrmap_free (map, value_free, &string2uintptrmap_free);
  check (!value_is_copied);
  check (value_copied_env == NULL);
  check (value_is_freed);
  check (value_freed_env == &string2uintptrmap_free);
}

int
main (int argc, char *argv[])
{
  test1 ();
  test2 ();
  test3 ();
  test4 ();
  test5 ();
  test6 ();
  test7 ();
  return 0;
}

/********************************************************************/
