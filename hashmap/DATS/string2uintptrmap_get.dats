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

staload "hashmap/SATS/strnptr2uintptrmap.sats"
#include "hashmap/HATS/strnptrmap.hats"

extern fun
ats2_hashmap_string2uintptrmap_get__internal
        {size        : int}
        (map         : !RD(strnptr2uintptrmap_vt (size)) >> _,
         key         : string,
         value_copy  : (uintptr, ptr) -> uintptr,
         environment : ptr,
         found       : &bool? >> bool,
         result      : &uintptr? >> uintptr) : void =
  "sta#ats2_hashmap_string2uintptrmap_get__internal"

implement
ats2_hashmap_string2uintptrmap_get__internal
        (map, key, value_copy, environment, found, result) =
  let
    val value_opt = strnptr2uintptrmap_get_opt (map, key, value_copy,
                                                environment)
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

#include <hashmap/string2uintptrmap.h>

void
ats2_hashmap_string2uintptrmap_get
        (string2uintptrmap_t map,
         const char *key,
         uintptr_t (*value_copy) (uintptr_t, void *),
         void *environment,
         _Bool *has_key,
         uintptr_t *value)
{
  atstype_bool found;
  ats2_hashmap_string2uintptrmap_get__internal
    (map, (void *) key, value_copy, environment, &found, value);
  *has_key = (_Bool) found;
}

%}
