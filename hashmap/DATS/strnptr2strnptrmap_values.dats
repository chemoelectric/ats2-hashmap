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

vtypedef value_vt = Strnptr1

implement
strnptr2strnptrmap_values (map) =
  let
    implement
    hashmap$value_vt_copy<value_vt> (v) =
      strnptr_copy v
  in
    strnptrmap_values<value_vt> (map)
  end

implement
strnptr2strnptrmap_values_free (values) =
  let
    implement
    list_vt_freelin$clear<value_vt> (x) =
      free x
  in
    list_vt_freelin<value_vt> values
  end
