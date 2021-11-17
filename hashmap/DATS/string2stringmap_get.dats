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

staload "hashmap/SATS/strnptr2strnptrmap.sats"
#include "hashmap/HATS/strnptrmap.hats"

extern fun
ats2_hashmap_string2stringmap_get__internal
        {size        : int}
        (map         : !RD(strnptr2strnptrmap_vt (size)) >> _,
         key         : string,
         found       : &bool? >> bool,
         result      : &Strnptr1? >> Strnptr1) : void =
  "sta#ats2_hashmap_string2stringmap_get__internal"

implement
ats2_hashmap_string2stringmap_get__internal (map, key,
                                             found, result) =
  let
    val value_opt = strnptr2strnptrmap_get_opt (map, key)
  in
    case+ value_opt of
    | ~ Some_vt value =>
      begin
        found := true;
        result := value
      end
    | ~ None_vt () =>
      let
        prval _ = $UNSAFE.castview2void_at{Strnptr1} (view@ result)
      in
        found := false
      end
  end

%{$

#include <hashmap/string2stringmap.h>

void
ats2_hashmap_string2stringmap_get
        (string2stringmap_t map,
         const char *key,
         _Bool *has_key,
         const char **value)
{
  atstype_bool found;
  ats2_hashmap_string2stringmap_get__internal
    (map, (void *) key, &found, (void *) value);
  *has_key = (_Bool) found;
}

%}
