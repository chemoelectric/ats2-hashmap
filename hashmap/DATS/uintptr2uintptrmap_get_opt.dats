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

typedef hash_t = uintptr2uintptrmap_hash_t
typedef key_t = uintptr
typedef value_t = uintptr

implement
uintptr2uintptrmap_get_opt (map, key,
                            bits_source, hash_function, key_eq,
                            hash_free, value_copy, environment) =
  let
    val _ = assertloc (isneqz ($UNSAFE.cast{ptr} bits_source))
    val _ = assertloc (isneqz ($UNSAFE.cast{ptr} hash_function))
    val _ = assertloc (isneqz ($UNSAFE.cast{ptr} key_eq))

    implement
    hashmap$bits_source<hash_t> (hash, depth) =
      bits_source (hash, depth)

    implement
    hashmap$hash_function<hash_t><key_t> (key, hash) =
      hash_function (key, hash, environment)

    implement
    hashmap$key_vt_eq<key_t> (k_arg, k_stored) =
      key_eq (k_arg, k_stored, environment) <> 0

    implement
    hashmap$hash_vt_free<hash_t> (hash) =
      if isneqz ($UNSAFE.cast{ptr} hash_free) then
        hash_free (hash, environment)

    implement
    hashmap$value_vt_copy<value_t> (v) =
      if isneqz ($UNSAFE.cast{ptr} value_copy) then
        value_copy (v, environment)
      else
        v
  in
    hashmap_get_opt<hash_t><key_t, value_t> (map, key)
  end
