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

#define ATS_DYNLOADFLAG 0

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

#include "hashmap/HATS/config.hats"

staload "hashmap/SATS/structure.sats"

staload "hashmap/SATS/count-one-bits.sats"
staload _ = "hashmap/DATS/count-one-bits.dats"

stadef bitsizeof (t : vt@ype) = 8 * sizeof (t)

prval _ = $UNSAFE.prop_assert {sizeof (uintptr) == SIZEOF_UINTPTR} ()
prval _ = prop_verify {bitsizeof (uintptr) == BITSIZEOF_UINTPTR} ()

symintr <<
infixl ( * ) <<
overload << with g0uint_lsl_uintptr

symintr &
infixl ( * ) &
overload & with g0uint_land_uintptr

extern fun {}
get_node_entry {length : int | length <= bitsizeof (uintptr)}
               {i      : int | i < length}
               (node   : &node_vt (length) >> _,
                i      : uint i) :<!ref>
    @(bool,      (* Is the entry stored? *)
      bool,      (* Is the entry a leaf? *)
      uintptr)   (* Entry's value, or 0 if the entry is not stored. *)

implement {}
get_node_entry {length} {i} (node, i) =
  let
    macdef zero = g1int2uint<intknd,uintptrknd> 0
    macdef one = g1int2uint<intknd,uintptrknd> 1

    val @(pf_node | p_node) = node
    prval _ = lemma_node_v_param {length} pf_node
    macdef nod = !p_node

    val population_map = nod[0]
    val bit_selection_mask = (one << (u2i i))
    val is_stored = ((population_map & bit_selection_mask) <> zero)

    val result =
      if is_stored then
        let
          val node_kind_map = nod[1]
          val is_leaf = ((node_kind_map & bit_selection_mask) <> zero)

          val [index : int] (pf_index | index) =
            popcount_low_bits<uintptrknd> (g1ofg0 population_map, i)
          prval _ = popcount_low_bits_is_nonnegative pf_index
          prval _ = popcount_low_bits_bound pf_index
          prval _ = prop_verify {0 <= index} ()
          prval _ = prop_verify {index <= i} ()
          prval _ = prop_verify {index < length} ()

          val entry = nod[index + 2]
        in
          @(true, is_leaf, entry)
        end
      else
        @(false, true, zero)

    prval _ = $effmask_wrt (node := @(pf_node | p_node))
  in
    result
  end
