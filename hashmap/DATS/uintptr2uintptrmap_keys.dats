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
uintptr2uintptrmap_keys (map, key_copy, environment) =
  let
    implement
    hashmap$key_vt_copy<key_t> (k) =
      if isneqz ($UNSAFE.cast{ptr} key_copy) then
        key_copy (k, environment)
      else
        k
  in
    hashmap_keys<key_t, value_t> (map)
  end

implement
uintptr2uintptrmap_keys_free (keys, key_free, environment) =
  if isneqz ($UNSAFE.cast{ptr} key_free) then
    let
      fun
      loop {n    : int | 0 <= n} .<n>.
           (keys : list_vt (key_t, n)) : void =
        case+ keys of
        | ~ NIL => ()
        | ~ k :: tail =>
          begin
            key_free (k, environment);
            loop tail
          end
      prval _ = lemma_list_vt_param keys
    in
      loop keys
    end
  else
    let
      fun
      loop {n    : int | 0 <= n} .<n>.
           (keys : list_vt (key_t, n)) : void =
        case+ keys of
        | ~ NIL => ()
        | ~ _ :: tail => loop tail
      prval _ = lemma_list_vt_param keys
    in
      loop keys
    end
