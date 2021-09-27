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

#ifndef HASHMAP_UPTR_CATS_HEADER_GUARD__
#define HASHMAP_UPTR_CATS_HEADER_GUARD__

ATSinline() atstype_uintptr
ats2_hashmap_ptr2uptr (atstype_ptr p)
{
  return (atstype_uintptr) p;
}

ATSinline() atstype_ptr
ats2_hashmap_uptr2ptr (atstype_uintptr p)
{
  return (atstype_ptr) p;
}

#endif /* HASHMAP_UPTR_CATS_HEADER_GUARD__ */
