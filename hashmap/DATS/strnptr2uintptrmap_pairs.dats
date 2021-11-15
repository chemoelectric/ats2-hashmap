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

#define NIL list_vt_nil ()
#define :: list_vt_cons

implement
strnptr2uintptrmap_pairs (map, value_copy, environment) =
  let
    implement
    hashmap$value_vt_copy<uintptr> (v) =
      if iseqz ($UNSAFE.cast{ptr} value_copy) then
        v
      else
        value_copy (v, environment)
  in
    strnptrmap_pairs<uintptr> (map)
  end

implement
strnptr2uintptrmap_pairs_free (pairs, value_free, environment) =
  if iseqz ($UNSAFE.cast{ptr} value_free) then
    let
      implement
      list_vt_freelin$clear<@(Strnptr1, uintptr)> (x) =
        free (x.0)
    in
      list_vt_freelin<@(Strnptr1, uintptr)> pairs
    end
  else
    let
      fun
      loop {n     : int | 0 <= n} .<n>.
           (pairs : list_vt (@(Strnptr1, uintptr), n)) : void =
        case+ pairs of
        | ~ NIL => ()
        | ~ @(k, v) :: tail =>
          begin
            free k;
            value_free (v, environment);
            loop tail
          end
      prval _ = lemma_list_vt_param pairs
    in
      loop pairs
    end
