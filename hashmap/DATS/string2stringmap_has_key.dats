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

#include <hashmap/string2stringmap.h>

/* A function that casts the result from atstype_bool to _Bool. */
_Bool
ats2_hashmap_string2stringmap_has_key (string2stringmap_t map,
                                       const char *key)
{
  extern atstype_bool
    ats2_055_hashmap__strnptr2strnptrmap_has_key_string
      (atstype_boxed map, atstype_ptrk key);
  
  return (_Bool)
    ats2_055_hashmap__strnptr2strnptrmap_has_key_string
      ((atstype_boxed) map, (atstype_ptrk) key);
}

%}
