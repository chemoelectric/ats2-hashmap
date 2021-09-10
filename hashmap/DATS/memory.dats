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

staload "hashmap/SATS/array_prf.sats"
staload "hashmap/SATS/memory.sats"

implement {t}
array_copy_elements {n1, n2} {i1, i2} {length}
                    (dst, i1, src, i2, length) =
  {
    prval _ = lemma_g1uint_param i1
    prval _ = lemma_g1uint_param i2
    prval _ = lemma_g1uint_param length

    val p_dst = ptr_add<t> (addr@ dst, i1)
    val p_src = ptr_add<t> (addr@ src, i2)

    prval @(pf1a, pf1b, pf1c) =
      array_v_subdivide3 {t} {..} {i1, length, n1 - i1 - length}
                         (view@ dst)
    prval @(pf2a, pf2b, pf2c) =
      array_v_subdivide3 {t} {..} {i2, length, n2 - i2 - length}
                         (view@ src)

    prval pf1bytes = array2bytes {length} {..} pf1b
    prval pf2bytes = array2bytes {length} {..} pf2b

    val _ = memcpy (!p_dst, !p_src, length * sizeof<t>)

    prval _ = pf1b := bytes2array {length} {..} pf1bytes
    prval _ = pf2b := bytes2array {length} {..} pf2bytes

    prval _ = view@ dst :=
      array_v_join3 {t} {..} {i1, length, n1 - i1 - length}
                    (pf1a, pf1b, pf1c)
    prval _ = view@ src :=
      array_v_join3 {t} {..} {i2, length, n2 - i2 - length}
                    (pf2a, pf2b, pf2c)
  }
