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

vtypedef key_vt = Strnptr1
vtypedef value_vt = Strnptr1

implement
strnptr2strnptrmap_has_key_strnptr (map, key) =
  strnptrmap_has_key<value_vt> (map, key)

implement
strnptr2strnptrmap_has_key_strptr (map, key) =
  let
    val s = $UNSAFE.castvwtp1{key_vt} key
    prval _ = lemma_strnptr_param s
    val result = strnptr2strnptrmap_has_key_strnptr (map, s)
    val _ = $UNSAFE.castvwtp0{void} s
  in
    result
  end

implement
strnptr2strnptrmap_has_key_string (map, key) =
  (* WARNING: The following implementation really does assume that
     the "key" argument to strnptr2strnptrmap_del_strnptr is
     read-only. (You could implement this template without that
     assumption, by using string1_copy. *)
  let
    val s = $UNSAFE.castvwtp0{key_vt} key
    val result = strnptr2strnptrmap_has_key_strnptr (map, s)
    prval _ = $UNSAFE.castvwtp0{void} s
  in
    result
  end
