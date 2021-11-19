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

staload "hashmap/SATS/uintptr2uintptrmap.sats"
#include "hashmap/HATS/hashmap.hats"

#define NIL list_vt_nil ()
#define :: list_vt_cons

typedef hash_t = uintptr2uintptrmap_hash_t
typedef key_t = uintptr
typedef value_t = uintptr

implement
uintptr2uintptrmap_values (map, value_copy, environment) =
  let
    implement
    hashmap$value_vt_copy<value_t> (v) =
      if isneqz ($UNSAFE.cast{ptr} value_copy) then
        value_copy (v, environment)
      else
        v
  in
    hashmap_values<key_t, value_t> (map)
  end

implement
uintptr2uintptrmap_values_free (values, value_free, environment) =
  if isneqz ($UNSAFE.cast{ptr} value_free) then
    let
      fun
      loop {n      : int | 0 <= n} .<n>.
           (values : list_vt (value_t, n)) : void =
        case+ values of
        | ~ NIL => ()
        | ~ v :: tail =>
          begin
            value_free (v, environment);
            loop tail
          end
      prval _ = lemma_list_vt_param values
    in
      loop values
    end
  else
    let
      fun
      loop {n      : int | 0 <= n} .<n>.
           (values : list_vt (value_t, n)) : void =
        case+ values of
        | ~ NIL => ()
        | ~ _ :: tail => loop tail
      prval _ = lemma_list_vt_param values
    in
      loop values
    end
