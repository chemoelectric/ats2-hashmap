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
staload "hashmap/SATS/strnptrmap.sats"

(********************************************************************)

primplement
lemma_strnptr2strnptrmap_vt_param (map) =
  lemma_strnptrmap_vt_param (map)

(********************************************************************)
(* See also
   https://en.wikipedia.org/w/index.php?title=In_C&oldid=1052113293 *)

implement {}                    (* In C: a NULL pointer. *)
strnptr2strnptrmap () =
  strnptrmap ()

implement {}                    (* In C: is "map" a NULL pointer? *)
strnptr2strnptrmap_is_empty (map) =
  strnptrmap_is_empty (map)

implement {}                  (* In C: is "map" a non-NULL pointer? *)
strnptr2strnptrmap_isnot_empty (map) =
  strnptrmap_isnot_empty (map)

(********************************************************************)
