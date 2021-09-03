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

(********************************************************************)

(*

This implementation structures the nodes differently from how
Bagwell's paper suggests.

Of the following reasons for doing this, the first is by far the more
important:

  * Bagwell's scheme is incompatible with Boehm GC. The collector
    might (and surely often would) collect nodes that were pointed to
    by pointers that had their LSB set.

  * Bagwell's scheme would not work if, for any reason, an object
    might be placed at an odd address.

  * The structures implemented here have obvious uses as integer maps,
    integer sets, hash sets, etc.

In the implementation used here, an internal node is laid out as
follows:

    population_map (uintptr)   -- used to compute indices into the
                                  array of *this* node.
    node_kind_map  (uintptr)   -- if a bit is set, the corresponding
                                  array entry is or points to a
                                  leaf node.
    entry 0        (uintptr)
    entry 1        (uintptr)
    entry 2        (uintptr)
       .
       .
       .
    entry N        (uintptr)   -- where N < sizeof (uintptr)

*)

(********************************************************************)

viewdef node_v (length : int, p : addr) =
  @[uintptr][length + 2] @ p

vtypedef node_vt (length : int, p : addr) =
  @(node_v (length, p) | ptr p)
vtypedef node_vt (length : int) =
  [p : addr] node_vt (length, p)
vtypedef node_vt =
  [length : int] node_vt (length)

praxi
lemma_node_v_param :
  {length : int} {p : addr}
  (!node_v (length, p) >> _) -<prf> [0 <= length] void

fun {}
get_node_entry {length : int | length <= sizeof (uintptr)}
               {i      : int | i < sizeof (uintptr)}
               (node   : &node_vt (length) >> _,
                i      : size_t i) :<!ref>
    @(bool,      (* Is the entry stored? *)
      bool,      (* Is the entry a leaf? *)
      uintptr)   (* Entry's value, or 0 if the entry is not stored. *)

(********************************************************************)
