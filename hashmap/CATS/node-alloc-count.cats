/*

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

*/

#ifndef ATS2_HASHMAP_CATS_NODE_ALLOC_COUNT_CATS_HEADER_GUARD__
#define ATS2_HASHMAP_CATS_NODE_ALLOC_COUNT_CATS_HEADER_GUARD__

extern volatile _Atomic atstype_uintptr ats2_hashmap_node_alloc_count;

ATSinline() void
ats2_hashmap_node_alloc_increment__ (void)
{
  ats2_hashmap_node_alloc_count += 1;
}

ATSinline() void
ats2_hashmap_node_alloc_decrement__ (void)
{
  ats2_hashmap_node_alloc_count -= 1;
}

#endif /* ATS2_HASHMAP_CATS_NODE_ALLOC_COUNT_CATS_HEADER_GUARD__ */
