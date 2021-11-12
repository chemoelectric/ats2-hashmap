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

#ifndef HEADER_GUARD_FOR_HASHMAP_STRINGSET_H__
#define HEADER_GUARD_FOR_HASHMAP_STRINGSET_H__

#include <stddef.h>
#include <stdint.h>

struct stringset_struct;
typedef struct stringset_struct *stringset_t;

struct stringset_elements_struct
{
  const char *element;
  struct stringset_elements_struct *next;
};
typedef struct stringset_elements_struct *stringset_elements_t;

inline stringset_t
ats2_hashmap_stringset (void)
{
  return NULL;
}

inline _Bool
ats2_hashmap_stringset_is_empty (stringset_t set)
{
  return (set == NULL);
}

inline _Bool
ats2_hashmap_stringset_isnot_empty (stringset_t set)
{
  return (set != NULL);
}

inline size_t
ats2_hashmap_stringset_size (stringset_t set)
{
  extern size_t ats2_055_hashmap__strnptr2uintptrmap_size (void *map);
  return ats2_055_hashmap__strnptr2uintptrmap_size (set);
}

inline stringset_t
ats2_hashmap_stringset_add (stringset_t set, const char *element)
{
  extern stringset_t
    ats2_055_hashmap__strnptr2uintptrmap_set_string
    (void *map, void *key, uintptr_t value);
  return ats2_055_hashmap__strnptr2uintptrmap_set_string
    (set, (void *) element, 0);
}

inline stringset_t
ats2_hashmap_stringset_del (stringset_t set, const char *element)
{
  extern stringset_t
    ats2_055_hashmap__strnptr2uintptrmap_del_string
    (void *map, void *key);
  return ats2_055_hashmap__strnptr2uintptrmap_del_string
    (set, (void *) element);
}

inline _Bool
ats2_hashmap_stringset_contains (stringset_t set, const char *element)
{
  extern _Bool
    ats2_hashmap_string2uintptrmap_has_key
    (stringset_t map, const char *key);
  return ats2_hashmap_string2uintptrmap_has_key (set, element);
}

inline stringset_elements_t
ats2_hashmap_stringset_elements (stringset_t set)
{
  extern void *ats2_055_hashmap__strnptr2uintptrmap_keys (void *map);
  return (stringset_elements_t)
    ats2_055_hashmap__strnptr2uintptrmap_keys (set);
}

inline void
ats2_hashmap_stringset_elements_free (stringset_elements_t elements)
{
  extern void ats2_055_hashmap__strnptr2uintptrmap_keys_free
    (void *keys);
  ats2_055_hashmap__strnptr2uintptrmap_keys_free (elements);
}

inline void
ats2_hashmap_stringset_free (stringset_t set)
{
  extern void ats2_055_hashmap__strnptr2uintptrmap_free (void *map);
  ats2_055_hashmap__strnptr2uintptrmap_free (set);
}

/* The following macro names are nicer to use. */
#define stringset ats2_hashmap_stringset
#define stringset_is_empty ats2_hashmap_stringset_is_empty
#define stringset_isnot_empty ats2_hashmap_stringset_isnot_empty
#define stringset_size ats2_hashmap_stringset_size
#define stringset_add ats2_hashmap_stringset_add
#define stringset_del ats2_hashmap_stringset_del
#define stringset_contains ats2_hashmap_stringset_contains
#define stringset_elements ats2_hashmap_stringset_elements
#define stringset_elements_free ats2_hashmap_stringset_elements_free
#define stringset_free ats2_hashmap_stringset_free

#endif /* HEADER_GUARD_FOR_HASHMAP_STRINGSET_H__ */
