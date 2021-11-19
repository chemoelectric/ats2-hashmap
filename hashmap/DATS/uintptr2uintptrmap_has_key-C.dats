(*

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

*)

#define ATS_PACKNAME "ats2-hashmap"
#define ATS_EXTERN_PREFIX "ats2_hashmap_"

#define ATS_DYNLOADFLAG 0

%{$

#include <hashmap/uintptr2uintptrmap.h>

/* A function that casts the result from atstype_bool to _Bool. */
_Bool
ats2_hashmap_uintptr2uintptrmap_has_key
    (uintptr2uintptrmap_t map,
     uintptr2uintptrmap_key_t key,
     uintptr2uintptrmap_bits_source_t bits_source,
     uintptr2uintptrmap_hash_function_t hash_function,
     uintptr2uintptrmap_key_eq_t key_eq,
     uintptr2uintptrmap_hash_free_t hash_free,
     void *environment)
{
  extern atstype_bool
  ats2_055_hashmap__uintptr2uintptrmap_has_key
    (atstype_boxed, atstype_uintptr,
     atstype_funptr, atstype_funptr,
     atstype_funptr, atstype_funptr,
     atstype_ptrk);
  
  return (_Bool)
    ats2_055_hashmap__uintptr2uintptrmap_has_key
      ((atstype_boxed) map,
       (atstype_uintptr) key,
       (atstype_funptr) bits_source,
       (atstype_funptr) hash_function,
       (atstype_funptr) key_eq,
       (atstype_funptr) hash_free,
       (atstype_ptrk) environment);
}

%}
