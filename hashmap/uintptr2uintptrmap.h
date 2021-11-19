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

#ifndef HEADER_GUARD_FOR_ATS2_HASHMAP_HASHMAP_UINTPTR2UINTPTRMAP_H__
#define HEADER_GUARD_FOR_ATS2_HASHMAP_HASHMAP_UINTPTR2UINTPTRMAP_H__

#include <stddef.h>
#include <stdint.h>

#include <hashmap/bits_source.h>

/********************************************************************/

struct uintptr2uintptrmap_struct;
typedef struct uintptr2uintptrmap_struct *uintptr2uintptrmap_t;

typedef struct
{
  uintptr_t key;
  uintptr_t value;
} uintptr2uintptrmap_pair_t;
struct uintptr2uintptrmap_pairs_struct
{
  uintptr2uintptrmap_pair_t pair;
  struct uintptr2uintptrmap_pairs_struct *next;
};
typedef struct uintptr2uintptrmap_pairs_struct
  *uintptr2uintptrmap_pairs_t;

struct uintptr2uintptrmap_keys_struct
{
  uintptr_t key;
  struct uintptr2uintptrmap_keys_struct *next;
};
typedef struct uintptr2uintptrmap_keys_struct
  *uintptr2uintptrmap_keys_t;

struct uintptr2uintptrmap_values_struct
{
  uintptr_t value;
  struct uintptr2uintptrmap_values_struct *next;
};
typedef struct uintptr2uintptrmap_values_struct
  *uintptr2uintptrmap_values_t;

/********************************************************************/

/* *INDENT-OFF* */

typedef uintptr_t uintptr2uintptrmap_key_t;
typedef uintptr_t uintptr2uintptrmap_value_t;

typedef ats2_hashmap_bits_source_t uintptr2uintptrmap_bits_source_t;

typedef void uintptr2uintptrmap_hash_function_func_t (uintptr_t, void *, void *);
typedef uintptr2uintptrmap_hash_function_func_t *uintptr2uintptrmap_hash_function_t;

typedef int uintptr2uintptrmap_key_eq_func_t (uintptr_t, uintptr_t);
typedef uintptr2uintptrmap_key_eq_func_t *uintptr2uintptrmap_key_eq_t;

typedef void uintptr2uintptrmap_hash_free_func_t (void *, void *);
typedef uintptr2uintptrmap_hash_free_func_t *uintptr2uintptrmap_hash_free_t;

typedef void uintptr2uintptrmap_uintptr_free_func_t (uintptr_t, void *);
typedef uintptr2uintptrmap_uintptr_free_func_t *uintptr2uintptrmap_key_free_t;
typedef uintptr2uintptrmap_uintptr_free_func_t *uintptr2uintptrmap_value_free_t;

typedef uintptr_t uintptr2uintptrmap_uintptr_copy_func_t (uintptr_t, void *);
typedef uintptr2uintptrmap_uintptr_copy_func_t *uintptr2uintptrmap_key_copy_t;
typedef uintptr2uintptrmap_uintptr_copy_func_t *uintptr2uintptrmap_value_copy_t;

/* *INDENT-ON* */

/********************************************************************/

/*

  bits_source (*p_hash, depth)

                   A "bits source" function for reading bits
                   from the hash value stored at p_hash; "depth"
                   is an unsigned integer specifying which bits
                   to read. This function must be provided.

  hash_function (key, *p_hash, *p_environment)

                   Given a uintptr_t as key or pointer to a key,
                   compute a hash value and store it at p_hash;
                   the hash value must be no longer than 64 bytes.
                   This function must be provided.

  key_eq (key_arg, key_stored, *p_environment)

                   Are the objects referred to by the uintptr_t
                   objects key_arg and key_stored equal? This
                   function must be provided.

  hash_free (*p_hash, *p_environment)

                   Frees a hash value pointed to by p_hash;
                   hash_free may be a NULL pointer, if no freeing
                   is necessary.

  key_free (key, *p_environment)

                   Frees a key pointed to by the uintptr_t "key";
                   key_free may be a NULL pointer, if no freeing
                   is necessary.

  value_free (value, *p_environment)

                   Frees a value pointed to by the uintptr_t "value";
                   value_free may be a NULL pointer, if no freeing
                   is necessary.

  key_copy (key, *p_environment)

                   Copies a key pointed to by the uintptr_t "key";
                   key_free may be a NULL pointer, to simply copy
                   the uintptr_t.

  value_copy (value, *p_environment)

                   Copies a value pointed to by the uintptr_t "value";
                   value_free may be a NULL pointer, to simply copy
                   the uintptr_t.

*/

/********************************************************************/

/* *INDENT-OFF* */

/* A new map is simply a NULL pointer. You may rely on that, or use
   ats2_hashmap_uintptr2uintptrmap() for documentation. */
inline uintptr2uintptrmap_t
ats2_hashmap_uintptr2uintptrmap (void)
{
  return NULL;
}

/* An empty map is simply a NULL pointer. You may rely on that, or use
   ats2_hashmap_uintptr2uintptrmap_is_empty(map) for documentation. */
inline _Bool
ats2_hashmap_uintptr2uintptrmap_is_empty (uintptr2uintptrmap_t map)
{
  return (map == NULL);
}

/* An unempty map is simply a non-NULL pointer. You may rely on that,
   or use ats2_hashmap_uintptr2uintptrmap_isnot_empty(map) for
   documentation. */
inline _Bool
ats2_hashmap_uintptr2uintptrmap_isnot_empty (uintptr2uintptrmap_t map)
{
  return (map != NULL);
}

/* Use ats2_hashmap_uintptr2uintptrmap_size(map) to get the cardinality
   of the map. */
inline size_t
ats2_hashmap_uintptr2uintptrmap_size (uintptr2uintptrmap_t map)
{
  extern size_t ats2_055_hashmap__uintptr2uintptrmap_size (void *map);
  return ats2_055_hashmap__uintptr2uintptrmap_size (map);
}

/* Use ats2_hashmap_uintptr2uintptrmap_set to add an entry to the map
   or to replace an existing entry. */
inline uintptr2uintptrmap_t
ats2_hashmap_uintptr2uintptrmap_set
    (uintptr2uintptrmap_t map,
     uintptr2uintptrmap_key_t key,
     uintptr2uintptrmap_value_t value,
     uintptr2uintptrmap_bits_source_t bits_source,
     uintptr2uintptrmap_hash_function_t hash_function,
     uintptr2uintptrmap_key_eq_t key_eq,
     uintptr2uintptrmap_hash_free_t hash_free,
     uintptr2uintptrmap_key_free_t key_free,
     uintptr2uintptrmap_value_free_t value_free,
     void *environment)
{
  extern uintptr2uintptrmap_t
  ats2_055_hashmap__uintptr2uintptrmap_set
    (void *map,
     uintptr_t key,
     uintptr_t value,
     void *bits_source,
     void *hash_function,
     void *key_eq,
     void *hash_free,
     void *key_free,
     void *value_free,
     void *environment);
  return ats2_055_hashmap__uintptr2uintptrmap_set
    ((void *) map,
     key, value,
     (void *) bits_source,
     (void *) hash_function,
     (void *) key_eq,
     (void *) hash_free,
     (void *) key_free,
     (void *) value_free,
     environment);
}

/* Use ats2_hashmap_uintptr2uintptrmap_del to remove an entry from a
   map. If no matching entry is found, the new map will be equivalent
   to the old map (though it is not guaranteed to be the same
   storage). */
inline uintptr2uintptrmap_t
ats2_hashmap_uintptr2uintptrmap_del
    (uintptr2uintptrmap_t map,
     uintptr2uintptrmap_key_t key,
     uintptr2uintptrmap_bits_source_t bits_source,
     uintptr2uintptrmap_hash_function_t hash_function,
     uintptr2uintptrmap_key_eq_t key_eq,
     uintptr2uintptrmap_hash_free_t hash_free,
     uintptr2uintptrmap_key_free_t key_free,
     uintptr2uintptrmap_value_free_t value_free,
     void *environment)
{
  extern uintptr2uintptrmap_t
  ats2_055_hashmap__uintptr2uintptrmap_del
    (void *map,
     uintptr_t key,
     void *bits_source,
     void *hash_function,
     void *key_eq,
     void *hash_free,
     void *key_free,
     void *value_free,
     void *environment);
  return ats2_055_hashmap__uintptr2uintptrmap_del
    ((void *) map,
     key,
     (void *) bits_source,
     (void *) hash_function,
     (void *) key_eq,
     (void *) hash_free,
     (void *) key_free,
     (void *) value_free,
     environment);
}

/* Use ats2_hashmap_uintptr2uintptrmap_get to get a copy of a value
   from the map, given a key. You may also learn that there is no
   match to the key. */
extern void
ats2_hashmap_uintptr2uintptrmap_get
    (uintptr2uintptrmap_t map,
     uintptr2uintptrmap_key_t key,
     uintptr2uintptrmap_bits_source_t bits_source,
     uintptr2uintptrmap_hash_function_t hash_function,
     uintptr2uintptrmap_key_eq_t key_eq,
     uintptr2uintptrmap_hash_free_t hash_free,
     uintptr2uintptrmap_value_copy_t value_copy,
     void *environment,
     _Bool *has_key,
     uintptr2uintptrmap_value_t *value);

/* Use ats2_hashmap_uintptr2uintptrmap_has_key to learn whether or not
   there is a match to a given key. */
extern _Bool
ats2_hashmap_uintptr2uintptrmap_has_key
    (uintptr2uintptrmap_t map,
     uintptr2uintptrmap_key_t key,
     uintptr2uintptrmap_bits_source_t bits_source,
     uintptr2uintptrmap_hash_function_t hash_function,
     uintptr2uintptrmap_key_eq_t key_eq,
     uintptr2uintptrmap_hash_free_t hash_free,
     void *environment);


/* Use ats2_hashmap_uintptr2uintptrmap_pairs to get a linked list of
   copies of the key-value pairs in the map. The order of the list is
   unspecified. */
inline uintptr2uintptrmap_pairs_t
ats2_hashmap_uintptr2uintptrmap_pairs
    (uintptr2uintptrmap_t map,
     uintptr2uintptrmap_key_copy_t key_copy,
     uintptr2uintptrmap_value_copy_t value_copy,
     void *environment)
{
  extern void *ats2_055_hashmap__uintptr2uintptrmap_pairs
    (void *map, void *key_copy, void *value_copy, void *environment);
  return (uintptr2uintptrmap_pairs_t)
    ats2_055_hashmap__uintptr2uintptrmap_pairs
    ((void *) map, (void *) key_copy, (void *) value_copy,
     environment);
}

/* Use ats2_hashmap_uintptr2uintptrmap_pairs_free to free a list
   returned by ats2_hashmap_uintptr2uintptrmap_pairs. */
inline void
ats2_hashmap_uintptr2uintptrmap_pairs_free
    (uintptr2uintptrmap_pairs_t pairs,
     uintptr2uintptrmap_key_free_t key_free,
     uintptr2uintptrmap_value_free_t value_free,
     void *environment)
{
  extern void ats2_055_hashmap__uintptr2uintptrmap_pairs_free
    (void *pairs,
     void *key_free,
     void *value_free,
     void *environment);
  ats2_055_hashmap__uintptr2uintptrmap_pairs_free
    ((void *) pairs, (void *) key_free, (void *) value_free,
     environment);
}

/* Use ats2_hashmap_uintptr2uintptrmap_keys to get a linked list of
   copies of the keys in the map. The order of the list is
   unspecified. */
inline uintptr2uintptrmap_keys_t
ats2_hashmap_uintptr2uintptrmap_keys
    (uintptr2uintptrmap_t map,
     uintptr2uintptrmap_key_copy_t key_copy,
     void *environment)
{
  extern void *ats2_055_hashmap__uintptr2uintptrmap_keys
    (void *map, void *key_copy, void *environment);
  return (uintptr2uintptrmap_keys_t)
    ats2_055_hashmap__uintptr2uintptrmap_keys
    ((void *) map, (void *) key_copy, environment);
}

/* Use ats2_hashmap_uintptr2uintptrmap_keys_free to free a list
   returned by ats2_hashmap_uintptr2uintptrmap_keys. */
inline void
ats2_hashmap_uintptr2uintptrmap_keys_free
    (uintptr2uintptrmap_keys_t keys,
     uintptr2uintptrmap_key_free_t key_free,
     void *environment)
{
  extern void ats2_055_hashmap__uintptr2uintptrmap_keys_free
    (void *keys,
     void *key_free,
     void *environment);
  ats2_055_hashmap__uintptr2uintptrmap_keys_free
    ((void *) keys, (void *) key_free, environment);
}

/* Use ats2_hashmap_uintptr2uintptrmap_values to get a linked list of
   copies of the values in the map. The order of the list is
   unspecified. */
inline uintptr2uintptrmap_values_t
ats2_hashmap_uintptr2uintptrmap_values
    (uintptr2uintptrmap_t map,
     uintptr2uintptrmap_value_copy_t value_copy,
     void *environment)
{
  extern void *ats2_055_hashmap__uintptr2uintptrmap_values
    (void *map, void *value_copy, void *environment);
  return (uintptr2uintptrmap_values_t)
    ats2_055_hashmap__uintptr2uintptrmap_values
    ((void *) map, (void *) value_copy, environment);
}

/* Use ats2_hashmap_uintptr2uintptrmap_values_free to free a list
   returned by ats2_hashmap_uintptr2uintptrmap_values. */
inline void
ats2_hashmap_uintptr2uintptrmap_values_free
    (uintptr2uintptrmap_values_t values,
     uintptr2uintptrmap_value_free_t value_free,
     void *environment)
{
  extern void ats2_055_hashmap__uintptr2uintptrmap_values_free
    (void *values,
     void *value_free,
     void *environment);
  ats2_055_hashmap__uintptr2uintptrmap_values_free
    ((void *) values, (void *) value_free, environment);
}

/* Use ats2_hashmap_uintptr2uintptrmap_free to free a map. */
inline void
ats2_hashmap_uintptr2uintptrmap_free
    (uintptr2uintptrmap_t map,
     uintptr2uintptrmap_key_free_t key_free,
     uintptr2uintptrmap_value_free_t value_free,
     void *environment)
{
  extern void ats2_055_hashmap__uintptr2uintptrmap_free
    (void *map, void *key_free, void *value_free, void *environment);
  ats2_055_hashmap__uintptr2uintptrmap_free
    ((void *) map, (void *) key_free, (void *) value_free,
     environment);
}

/* *INDENT-ON* */

/********************************************************************/

/* The following macro names are nicer to use. */
#define uintptr2uintptrmap ats2_hashmap_uintptr2uintptrmap
#define uintptr2uintptrmap_is_empty ats2_hashmap_uintptr2uintptrmap_is_empty
#define uintptr2uintptrmap_isnot_empty ats2_hashmap_uintptr2uintptrmap_isnot_empty
#define uintptr2uintptrmap_size ats2_hashmap_uintptr2uintptrmap_size
#define uintptr2uintptrmap_set ats2_hashmap_uintptr2uintptrmap_set
#define uintptr2uintptrmap_del ats2_hashmap_uintptr2uintptrmap_del
#define uintptr2uintptrmap_get ats2_hashmap_uintptr2uintptrmap_get
#define uintptr2uintptrmap_has_key ats2_hashmap_uintptr2uintptrmap_has_key
#define uintptr2uintptrmap_pairs ats2_hashmap_uintptr2uintptrmap_pairs
#define uintptr2uintptrmap_pairs_free ats2_hashmap_uintptr2uintptrmap_pairs_free
#define uintptr2uintptrmap_keys ats2_hashmap_uintptr2uintptrmap_keys
#define uintptr2uintptrmap_keys_free ats2_hashmap_uintptr2uintptrmap_keys_free
#define uintptr2uintptrmap_values ats2_hashmap_uintptr2uintptrmap_values
#define uintptr2uintptrmap_values_free ats2_hashmap_uintptr2uintptrmap_values_free
#define uintptr2uintptrmap_free ats2_hashmap_uintptr2uintptrmap_free

/********************************************************************/

#endif /* HEADER_GUARD_FOR_ATS2_HASHMAP_HASHMAP_UINTPTR2UINTPTRMAP_H__ */
