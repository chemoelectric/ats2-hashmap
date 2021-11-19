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
uintptr2uintptrmap_pairs (map, key_copy, value_copy, environment) =
  let
    implement
    hashmap$key_vt_copy<key_t> (k) =
      if isneqz ($UNSAFE.cast{ptr} key_copy) then
        key_copy (k, environment)
      else
        k

    implement
    hashmap$value_vt_copy<value_t> (v) =
      if isneqz ($UNSAFE.cast{ptr} value_copy) then
        value_copy (v, environment)
      else
        v
  in
    hashmap_pairs<key_t, value_t> (map)
  end

implement
uintptr2uintptrmap_pairs_free (pairs, key_free, value_free,
                               environment) =
  let
    fun
    loop {n     : int | 0 <= n} .<n>.
         (pairs : list_vt (@(key_t, value_t), n)) : void =
      case+ pairs of
      | ~ NIL => ()
      | ~ @(k, v) :: tail =>
        begin
          if isneqz ($UNSAFE.cast{ptr} key_free) then
            key_free (k, environment);
          if isneqz ($UNSAFE.cast{ptr} value_free) then
            value_free (v, environment);
          loop tail
        end

    prval _ = lemma_list_vt_param pairs
  in
    loop pairs
  end
