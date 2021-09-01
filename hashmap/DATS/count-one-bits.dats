(*

Count the number of 1-bits in a word.

Copyright © 2012-2021 Free Software Foundation, Inc.
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

Written by Ben Pfaff. (See the count-one-bits module of Gnulib.)

Modified for ats2-hashmap by Barry Schwartz.

*)

staload "hashmap/SATS/count-one-bits.sats"

%{
#if 1500 <= _MSC_VER && (defined _M_IX86 || defined _M_X64)
int ats2_hashmap_popcount_support = -1;
#endif
%}
