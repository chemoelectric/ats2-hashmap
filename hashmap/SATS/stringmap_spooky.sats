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

staload "hashmap/SATS/hashmap.sats"

vtypedef stringmap_vt (value_vt : vt@ype+,
                       size     : int) =
  hashmap_vt (Strnptr1, value_vt, size)
vtypedef stringmap_vt (value_vt : vt@ype+) =
  [size : int]
  stringmap_vt (value_vt, size)

prfun
lemma_stringmap_vt_param :
  {value_vt : vt@ype}
  {size     : int}
  (!stringmap_vt (value_vt, size) >> _) -<prf>
    [0 <= size] void

fun {}
stringmap {value_vt : vt@ype} () :
  stringmap_vt (value_vt, 0)
