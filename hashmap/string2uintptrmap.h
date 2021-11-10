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

#ifndef HEADER_GUARD_FOR_HASHMAP_STRING2UINTPTRMAP_H__
#define HEADER_GUARD_FOR_HASHMAP_STRING2UINTPTRMAP_H__

#include <stddef.h>
#include <stdint.h>

struct string2uintptrmap_struct;
typedef struct string2uintptrmap_struct *string2uintptrmap_t;

typedef struct
{
  const char *key;
  uintptr_t value;
} string2uintptrmap_pair_t;
struct string2uintptrmap_pairs_struct
{
  string2uintptrmap_pair_t pair;
  struct string2uintptrmap_pairs_struct *next;
};
typedef struct string2uintptrmap_pairs_struct *string2uintptrmap_pairs_t;

struct string2uintptrmap_keys_struct
{
  const char *key;
  struct string2uintptrmap_keys_struct *next;
};
typedef struct string2uintptrmap_keys_struct *string2uintptrmap_keys_t;

struct string2uintptrmap_values_struct
{
  uintptr_t value;
  struct string2uintptrmap_values_struct *next;
};
typedef struct string2uintptrmap_values_struct *string2uintptrmap_values_t;

inline string2uintptrmap_t
ats2_hashmap_string2uintptrmap (void)
{
  return NULL;
}

inline _Bool
ats2_hashmap_string2uintptrmap_is_empty (string2uintptrmap_t map)
{
  return (map == NULL);
}

inline _Bool
ats2_hashmap_string2uintptrmap_isnot_empty (string2uintptrmap_t map)
{
  return (map != NULL);
}

inline size_t
ats2_hashmap_string2uintptrmap_size (string2uintptrmap_t map)
{
  extern size_t ats2_055_hashmap__strnptr2uintptrmap_size (void *map);
  return ats2_055_hashmap__strnptr2uintptrmap_size (map);
}

inline string2uintptrmap_t
ats2_hashmap_string2uintptrmap_set (string2uintptrmap_t map,
                                    const char *key, uintptr_t value)
{
  extern string2uintptrmap_t
    ats2_055_hashmap__strnptr2uintptrmap_set_string (void *map,
                                                     void *key,
                                                     uintptr_t value);
  return ats2_055_hashmap__strnptr2uintptrmap_set_string (map, (void *) key,
                                                          value);
}

inline string2uintptrmap_t
ats2_hashmap_string2uintptrmap_del (string2uintptrmap_t map, const char *key)
{
  extern string2uintptrmap_t
    ats2_055_hashmap__strnptr2uintptrmap_del_string (void *map, void *key);
  return ats2_055_hashmap__strnptr2uintptrmap_del_string (map, (void *) key);
}

extern void
ats2_hashmap_string2uintptrmap_get (string2uintptrmap_t map,
                                    const char *key,
                                    _Bool *has_key, uintptr_t * value);

extern _Bool
ats2_hashmap_string2uintptrmap_has_key (string2uintptrmap_t map,
                                        const char *key);

inline string2uintptrmap_pairs_t
ats2_hashmap_string2uintptrmap_pairs (string2uintptrmap_t map)
{
  extern void *ats2_055_hashmap__strnptr2uintptrmap_pairs (void *map);
  return (string2uintptrmap_pairs_t)
    ats2_055_hashmap__strnptr2uintptrmap_pairs (map);
}

inline void
ats2_hashmap_string2uintptrmap_pairs_free (string2uintptrmap_pairs_t pairs)
{
  extern void ats2_055_hashmap__strnptr2uintptrmap_pairs_free (void *pairs);
  ats2_055_hashmap__strnptr2uintptrmap_pairs_free (pairs);
}

inline string2uintptrmap_keys_t
ats2_hashmap_string2uintptrmap_keys (string2uintptrmap_t map)
{
  extern void *ats2_055_hashmap__strnptr2uintptrmap_keys (void *map);
  return (string2uintptrmap_keys_t)
    ats2_055_hashmap__strnptr2uintptrmap_keys (map);
}

inline void
ats2_hashmap_string2uintptrmap_keys_free (string2uintptrmap_keys_t keys)
{
  extern void ats2_055_hashmap__strnptr2uintptrmap_keys_free (void *keys);
  ats2_055_hashmap__strnptr2uintptrmap_keys_free (keys);
}

inline string2uintptrmap_values_t
ats2_hashmap_string2uintptrmap_values (string2uintptrmap_t map)
{
  extern void *ats2_055_hashmap__strnptr2uintptrmap_values (void *map);
  return (string2uintptrmap_values_t)
    ats2_055_hashmap__strnptr2uintptrmap_values (map);
}

inline void
ats2_hashmap_string2uintptrmap_values_free (string2uintptrmap_values_t values)
{
  extern void ats2_055_hashmap__strnptr2uintptrmap_values_free (void *values);
  ats2_055_hashmap__strnptr2uintptrmap_values_free (values);
}

inline void
ats2_hashmap_string2uintptrmap_free (string2uintptrmap_t map)
{
  extern void ats2_055_hashmap__strnptr2uintptrmap_free (void *map);
  ats2_055_hashmap__strnptr2uintptrmap_free (map);
}

/* The following macro names are nicer to use. */
#define string2uintptrmap ats2_hashmap_string2uintptrmap
#define string2uintptrmap_is_empty ats2_hashmap_string2uintptrmap_is_empty
#define string2uintptrmap_isnot_empty ats2_hashmap_string2uintptrmap_isnot_empty
#define string2uintptrmap_size ats2_hashmap_string2uintptrmap_size
#define string2uintptrmap_set ats2_hashmap_string2uintptrmap_set
#define string2uintptrmap_del ats2_hashmap_string2uintptrmap_del
#define string2uintptrmap_get ats2_hashmap_string2uintptrmap_get
#define string2uintptrmap_has_key ats2_hashmap_string2uintptrmap_has_key
#define string2uintptrmap_pairs ats2_hashmap_string2uintptrmap_pairs
#define string2uintptrmap_pairs_free ats2_hashmap_string2uintptrmap_pairs_free
#define string2uintptrmap_keys ats2_hashmap_string2uintptrmap_keys
#define string2uintptrmap_keys_free ats2_hashmap_string2uintptrmap_keys_free
#define string2uintptrmap_values ats2_hashmap_string2uintptrmap_values
#define string2uintptrmap_values_free ats2_hashmap_string2uintptrmap_values_free
#define string2uintptrmap_free ats2_hashmap_string2uintptrmap_free

#endif /* HEADER_GUARD_FOR_HASHMAP_STRING2UINTPTRMAP_H__ */
