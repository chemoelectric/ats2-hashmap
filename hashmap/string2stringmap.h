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

#ifndef HEADER_GUARD_FOR_ATS2_HASHMAP_HASHMAP_STRING2STRINGMAP_H__
#define HEADER_GUARD_FOR_ATS2_HASHMAP_HASHMAP_STRING2STRINGMAP_H__

#include <stddef.h>

/********************************************************************/

struct string2stringmap_struct;
typedef struct string2stringmap_struct *string2stringmap_t;

typedef struct
{
  char *key;
  char *value;
} string2stringmap_pair_t;
struct string2stringmap_pairs_struct
{
  string2stringmap_pair_t pair;
  struct string2stringmap_pairs_struct *next;
};
typedef struct string2stringmap_pairs_struct
  *string2stringmap_pairs_t;

struct string2stringmap_keys_struct
{
  char *key;
  struct string2stringmap_keys_struct *next;
};
typedef struct string2stringmap_keys_struct *string2stringmap_keys_t;

struct string2stringmap_values_struct
{
  char *value;
  struct string2stringmap_values_struct *next;
};
typedef struct string2stringmap_values_struct
  *string2stringmap_values_t;

/********************************************************************/

/* A new map is simply a NULL pointer. You may rely on that, or use
   ats2_hashmap_string2stringmap() for documentation. */
inline string2stringmap_t
ats2_hashmap_string2stringmap (void)
{
  return NULL;
}

/* An empty map is simply a NULL pointer. You may rely on that, or use
   ats2_hashmap_string2stringmap_is_empty(map) for documentation. */
inline _Bool
ats2_hashmap_string2stringmap_is_empty (string2stringmap_t map)
{
  return (map == NULL);
}

/* An unempty map is simply a non-NULL pointer. You may rely on that,
   or use ats2_hashmap_string2stringmap_isnot_empty(map) for
   documentation. */
inline _Bool
ats2_hashmap_string2stringmap_isnot_empty (string2stringmap_t map)
{
  return (map != NULL);
}

/* Use ats2_hashmap_string2stringmap_size(map) to get the cardinality
   of the map. */
inline size_t
ats2_hashmap_string2stringmap_size (string2stringmap_t map)
{
  extern size_t ats2_055_hashmap__strnptr2strnptrmap_size (void *map);
  return ats2_055_hashmap__strnptr2strnptrmap_size (map);
}

/* Use ats2_hashmap_string2stringmap_set(map, key, value) to add an
   entry to the map or to replace an existing entry. */
inline string2stringmap_t
  ats2_hashmap_string2stringmap_set
  (string2stringmap_t map, const char *key, const char *value)
{
  extern string2stringmap_t
    ats2_055_hashmap__strnptr2strnptrmap_set_string_string
    (void *map, void *key, void *value);
  return ats2_055_hashmap__strnptr2strnptrmap_set_string_string
    (map, (void *) key, (void *) value);
}

/* Use ats2_hashmap_string2stringmap_del(map, key) to remove an entry
   from a map. If no matching entry is found, the new map will be
   equivalent to the old map (though it is not guaranteed to be the
   same storage). */
inline string2stringmap_t
  ats2_hashmap_string2stringmap_del
  (string2stringmap_t map, const char *key)
{
  extern string2stringmap_t
    ats2_055_hashmap__strnptr2strnptrmap_del_string
    (void *map, void *key);
  return ats2_055_hashmap__strnptr2strnptrmap_del_string
    (map, (void *) key);
}

/* Use ats2_hashmap_string2stringmap_get(map, key, &has_key, &value)
   to get a copy of a value from the map, given a key. You may also
   learn that there is no match to the key. */
extern void ats2_hashmap_string2stringmap_get
  (string2stringmap_t map, const char *key,
   _Bool *has_key, char **value);

/* Use ats2_hashmap_string2stringmap_has_key(map, key) to learn
   whether or not there is a match to a given key. */
extern _Bool
  ats2_hashmap_string2stringmap_has_key
  (string2stringmap_t map, const char *key);

/* Use ats2_hashmap_string2stringmap_pairs(map) to get a linked list
   of copies of the key-value pairs in the map. The order of the list
   is unspecified. */
inline string2stringmap_pairs_t
ats2_hashmap_string2stringmap_pairs (string2stringmap_t map)
{
  extern void *ats2_055_hashmap__strnptr2strnptrmap_pairs (void *map);
  return (string2stringmap_pairs_t)
    ats2_055_hashmap__strnptr2strnptrmap_pairs (map);
}

/* Use ats2_hashmap_string2stringmap_pairs_free(pairs_list) to free a
   list returned by ats2_hashmap_string2stringmap_pairs. */
inline void
  ats2_hashmap_string2stringmap_pairs_free
  (string2stringmap_pairs_t pairs)
{
  extern void ats2_055_hashmap__strnptr2strnptrmap_pairs_free
    (void *pairs);
  ats2_055_hashmap__strnptr2strnptrmap_pairs_free (pairs);
}

/* Use ats2_hashmap_string2stringmap_keys(map) to get a linked list
   of copies of the keys in the map. The order of the list is
   unspecified. */
inline string2stringmap_keys_t
ats2_hashmap_string2stringmap_keys (string2stringmap_t map)
{
  extern void *ats2_055_hashmap__strnptr2strnptrmap_keys (void *map);
  return (string2stringmap_keys_t)
    ats2_055_hashmap__strnptr2strnptrmap_keys (map);
}

/* Use ats2_hashmap_string2stringmap_pairs_free(keys_list) to free a
   list returned by ats2_hashmap_string2stringmap_keys. */
inline void
  ats2_hashmap_string2stringmap_keys_free
  (string2stringmap_keys_t keys)
{
  extern void ats2_055_hashmap__strnptr2strnptrmap_keys_free
    (void *keys);
  ats2_055_hashmap__strnptr2strnptrmap_keys_free (keys);
}

/* Use ats2_hashmap_string2stringmap_values(map) to get a linked list
   of copies of the values in the map. The order of the list is
   unspecified. */
inline string2stringmap_values_t
ats2_hashmap_string2stringmap_values (string2stringmap_t map)
{
  extern void *ats2_055_hashmap__strnptr2strnptrmap_values
    (void *map);
  return (string2stringmap_values_t)
    ats2_055_hashmap__strnptr2strnptrmap_values (map);
}

/* Use ats2_hashmap_string2stringmap_values_free(values_list) to free
   a list returned by ats2_hashmap_string2stringmap_values. */
inline void
  ats2_hashmap_string2stringmap_values_free
  (string2stringmap_values_t values)
{
  extern void ats2_055_hashmap__strnptr2strnptrmap_values_free
    (void *values);
  ats2_055_hashmap__strnptr2strnptrmap_values_free (values);
}

/* Use ats2_hashmap_string2stringmap_free(map) to free a map. */
inline void
ats2_hashmap_string2stringmap_free (string2stringmap_t map)
{
  extern void ats2_055_hashmap__strnptr2strnptrmap_free (void *map);
  ats2_055_hashmap__strnptr2strnptrmap_free (map);
}

/********************************************************************/

/* The following macro names are nicer to use. */
#define string2stringmap ats2_hashmap_string2stringmap
#define string2stringmap_is_empty ats2_hashmap_string2stringmap_is_empty
#define string2stringmap_isnot_empty ats2_hashmap_string2stringmap_isnot_empty
#define string2stringmap_size ats2_hashmap_string2stringmap_size
#define string2stringmap_set ats2_hashmap_string2stringmap_set
#define string2stringmap_del ats2_hashmap_string2stringmap_del
#define string2stringmap_get ats2_hashmap_string2stringmap_get
#define string2stringmap_has_key ats2_hashmap_string2stringmap_has_key
#define string2stringmap_pairs ats2_hashmap_string2stringmap_pairs
#define string2stringmap_pairs_free ats2_hashmap_string2stringmap_pairs_free
#define string2stringmap_keys ats2_hashmap_string2stringmap_keys
#define string2stringmap_keys_free ats2_hashmap_string2stringmap_keys_free
#define string2stringmap_values ats2_hashmap_string2stringmap_values
#define string2stringmap_values_free ats2_hashmap_string2stringmap_values_free
#define string2stringmap_free ats2_hashmap_string2stringmap_free

/********************************************************************/

#endif /* HEADER_GUARD_FOR_ATS2_HASHMAP_HASHMAP_STRING2STRINGMAP_H__ */
