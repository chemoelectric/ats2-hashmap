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

implement
strnptr2uintptrmap_get_opt_strnptr (map, key, value_copy,
                                    environment) =
  let
    implement
    hashmap$value_vt_copy<uintptr> (v) =
      if iseqz ($UNSAFE.cast{ptr} value_copy) then
        v
      else
        value_copy (v, environment)
  in
    strnptrmap_get_opt<uintptr> (map, key)
  end

implement
strnptr2uintptrmap_get_opt_strptr (map, key, value_copy,
                                   environment) =
  let
    val s = $UNSAFE.castvwtp1{Strnptr1} key
    prval _ = lemma_strnptr_param s
    val result =
      strnptr2uintptrmap_get_opt_strnptr (map, s, value_copy,
                                          environment)
    val _ = $UNSAFE.castvwtp0{void} s
  in
    result
  end

implement
strnptr2uintptrmap_get_opt_string (map, key, value_copy,
                                   environment) =
  (* WARNING: The following implementation really does assume that
     the "key" argument to strnptr2uintptrmap_del_strnptr is
     read-only. (You could implement this template without that
     assumption, by using string1_copy. *)
  let
    val s = $UNSAFE.castvwtp0{Strnptr1} key
    val result =
      strnptr2uintptrmap_get_opt_strnptr (map, s, value_copy,
                                          environment)
    prval _ = $UNSAFE.castvwtp0{void} s
  in
    result
  end
