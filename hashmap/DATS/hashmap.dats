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

#include "hashmap/HATS/bits-source-include.hats"

staload UN = "prelude/SATS/unsafe.sats"

staload "hashmap/SATS/hashmap.sats"
staload "hashmap/SATS/array-mapped-tree.sats"
staload "hashmap/SATS/bits-source.sats"

#define NIL list_vt_nil ()
#define :: list_vt_cons

datavtype map_vt (hash_vt  : vt@ype,
                  key_vt   : vt@ype,
                  value_vt : vt@ype,
                  size     : int) =
| map_vt_nil (hash_vt, key_vt, value_vt, 0) of ()
| {n : int | 1 <= n}
  {node_p : addr}
  map_vt_tree (hash_vt, key_vt, value_vt, n) of
    (size_t n, ptr node_p)

assume hashmap_vt (hash_vt, key_vt, value_vt, size) =
  map_vt (hash_vt, key_vt, value_vt, size)

implement {}
hashmap () = map_vt_nil ()
