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

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

#include "hashmap/HATS/uintptr2uintptrmap.hats"

#define map_vt uintptr2uintptrmap_vt

typedef key_t = uintptr
typedef value_t = uintptr

vtypedef bits_source_vt = uintptr2uintptrmap_bits_source_vt
typedef hash_function_t = uintptr2uintptrmap_hash_function_t
typedef key_eq_t = uintptr2uintptrmap_key_eq_t
typedef hash_free_t = uintptr2uintptrmap_hash_free_t
typedef key_free_t = uintptr2uintptrmap_uintptr_free_t
typedef value_free_t = uintptr2uintptrmap_uintptr_free_t
typedef key_copy_t = uintptr2uintptrmap_uintptr_copy_t
typedef value_copy_t = uintptr2uintptrmap_uintptr_copy_t

extern fun
ats2_hashmap_uintptr2uintptrmap_get__internal
        {size          : int}
        (map           : !RD(map_vt (size)) >> _,
         key           : key_t,
         bits_source   : bits_source_vt,
         hash_function : hash_function_t,
         key_eq        : key_eq_t,
         hash_free     : hash_free_t,
         value_copy    : value_copy_t,
         environment   : ptr,
         found         : &bool? >> bool,
         result        : &value_t? >> value_t) : void =
  "sta#ats2_hashmap_uintptr2uintptrmap_get__internal"

implement
ats2_hashmap_uintptr2uintptrmap_get__internal
        (map, key, bits_source, hash_function, key_eq,
         hash_free, value_copy, environment, found, result) =
  let
    val value_opt =
      uintptr2uintptrmap_get_opt
        (map, key, bits_source, hash_function, key_eq,
         hash_free, value_copy, environment)
  in
    case+ value_opt of
    | ~ Some_vt value =>
      begin
        found := true;
        result := value
      end
    | ~ None_vt () =>
      let
        prval _ = $UNSAFE.castview2void_at{uintptr} (view@ result)
      in
        found := false
      end
  end

%{$

#include <hashmap/uintptr2uintptrmap.h>

void
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
         uintptr2uintptrmap_value_t *value)
{
  atstype_bool found;
  ats2_hashmap_uintptr2uintptrmap_get__internal
    (map, key, bits_source, hash_function, key_eq,
     hash_free, value_copy, environment, &found, value);
  *has_key = (_Bool) found;
}

%}
