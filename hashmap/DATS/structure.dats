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

staload "hashmap/SATS/structure.sats"

(********************************************************************)

extern praxi
make_proof_is_value_ptr :
  {b : bool} () -<prf> IS_VALUE_PTR (b)

extern praxi
make_proof_is_base_ptr :
  {b : bool} () -<prf> IS_BASE_PTR (b)

extern praxi
make_node_v_of_length :
  {length : int} {p : addr}
  () -<prf> @[node_entry_t][length] @ p

#ifdef ENABLE_ODD_ALIGNMENT #then
  (* A pointer, plus a uint8 set to 1 if the pointer is to
     a value object, or set to 0 if the pointer is to an
     internal node. *)
  assume node_entry_right_t = @(ptr, uint8)
  fn {} value_ptr_true () :<> uint8 = $UNSAFE.cast 1
  fn {} value_ptr_false () :<> uint8 = $UNSAFE.cast 0
#else
  (* An evenly-aligned pointer, with the least significant
     bit set for a pointer to a value object, clear for a
     pointer to an internal node. *)
  assume node_entry_right_t = uintptr
#endif

#ifdef ENABLE_ODD_ALIGNMENT #then

  implement {}
  node_entry_right_is_value_ptr (right) =
    let
      val [b : bool] b = g1ofg0 (right.1 <> value_ptr_false ())
    in
      @(make_proof_is_value_ptr {b} () | b)
    end

  implement {}
  node_entry_right_is_base_ptr (right) =
    let
      val [b : bool] b = g1ofg0 (right.1 = value_ptr_false ())
    in
      @(make_proof_is_base_ptr {b} () | b)
    end

#else

  implement {}
  node_entry_right_is_value_ptr (right) =
    let
      macdef zero = $UNSAFE.cast{uintptr} 0
      macdef one = $UNSAFE.cast{uintptr} 1
      val i = $UNSAFE.cast{uintptr} right
      val [b : bool] b = g1ofg0 (g0uint_land_uintptr (i, one) <> zero)
    in
      @(make_proof_is_value_ptr {b} () | b)
    end

  implement {}
  node_entry_right_is_base_ptr (right) =
    let
      macdef zero = $UNSAFE.cast{uintptr} 0
      macdef one = $UNSAFE.cast{uintptr} 1
      val i = $UNSAFE.cast{uintptr} right
      val [b : bool] b = g1ofg0 (g0uint_land_uintptr (i, one) = zero)
    in
      @(make_proof_is_base_ptr {b} () | b)
    end

#endif

(********************************************************************)
(* Key-value pairs. (That is, leaf nodes.) *)

implement {}
node_entry_left2key_ptr (left) =
  $UNSAFE.cast left

implement {}
key_ptr2node_entry_left (key_p) =
  $UNSAFE.cast key_p

#ifdef ENABLE_ODD_ALIGNMENT #then

  implement {}
  node_entry_right2value_ptr (pf | right) =
    $UNSAFE.cast (right.0)

  implement {}
  value_ptr2node_entry_right (p) =
    @(make_proof_is_value_ptr {true} () |
      @($UNSAFE.cast p, value_ptr_true ()))

#else

  implement {}
  node_entry_right2value_ptr (pf | right) =
    (* Clear the "This is a value pointer" bit. This
       will have been set to 1 to indicate that the
       pointer is to a value rather than a map-base pair. *)
    $UNSAFE.cast (pred ($UNSAFE.cast{uintptr} right))

  implement {}
  value_ptr2node_entry_right (p) =
    (* Set the "This is a value pointer" bit. The least
       significant bit of the actual pointer will be clear,
       due to alignment of the malloc(3). *)
    @(make_proof_is_value_ptr {true} () |
      succ ($UNSAFE.cast{uintptr} p))

#endif

(********************************************************************)
(* Map-base pairs. (That is, internal nodes.) *)

implement {}
node_entry_left2entry_map (left) =
  $UNSAFE.cast left

implement {}
entry_map2node_entry_left (map) =
  $UNSAFE.cast map

#ifdef ENABLE_ODD_ALIGNMENT #then

  implement {}
  node_entry_right2node_vt {length} (pf | right) =
    let
      val [p : addr] p = g1ofg0 (right.0)
    in
      @(make_node_v_of_length {length} {p} () | p)
    end

  implement {}
  node_vt2node_entry_right {length} (node) =
    let
      val @(_ | p) = node
    in
      (make_proof_is_base_ptr {true} () |
       @($UNSAFE.cast p, value_ptr_false ()))
    end

#else

  implement {}
  node_entry_right2node_vt {length} (pf | right) =
    (* The "This is a value pointer" bit will already be clear.
       Leave it alone. *)
    let
      val [p : addr] p = g1ofg0 ($UNSAFE.cast{ptr} right)
    in
      @(make_node_v_of_length {length} {p} () | p)
    end

  implement {}
  node_vt2node_entry_right {length} (node) =
    (* "This is a value pointer" bit will already be clear.
       Leave it alone. *)
    let
      val @(_ | p) = node
    in
      (make_proof_is_base_ptr {true} () | $UNSAFE.cast p)
    end

#endif

(********************************************************************)
