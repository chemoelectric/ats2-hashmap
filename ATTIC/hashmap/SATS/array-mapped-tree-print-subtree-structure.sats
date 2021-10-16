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

staload "hashmap/SATS/array-mapped-tree-templates.sats"

(* Something useful for testing and debugging: print the structure
   and contents of the tree. *)
fun
print_subtree_structure
        {length : int | length <= bitsizeof (uintptr)}
        {node_p : addr}
        {depth  : int}
        (out             : FILEref,
         node            : !node_vt (length, node_p) >> _,
         depth           : uint depth,
         print_key_value : !((FILEref, uintptr) -<cloptr1> void)) :
    void
