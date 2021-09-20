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

staload "hashmap/SATS/uintptr-set.sats"
staload "hashmap/SATS/array-mapped-tree.sats"
staload "hashmap/SATS/bits-source.sats"

datavtype set_vt (size : int) =
| set_vt_nil (0) of ()
| {n : int | 1 <= n}
  {node_p : addr}
  {num_bits : int | valid_num_bits (num_bits)}
  set_vt_tree (n) of
    (size_t n,
     array_mapped_tree_vt node_p,
     bits_source_cloptr (uintptr, num_bits)) (* FIXME: Make the bits_source a one-time initialized thing. *)

assume uintptr_set_vt (size) = set_vt (size)

implement
uintptr_set_add_element {size} (set, element) =
  case+ set of
  | set_vt_nil () =>
    () // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME
  | set_vt_tree (size, tree , bits_source) =>
    let
//      val _ = set := set_vt_tree (size, tree(*, bits_source*))
    in
      () // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME // FIXME
    end
