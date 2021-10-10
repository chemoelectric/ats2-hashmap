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

#include "hashmap/HATS/bits-source-include.hats"

staload UN = "prelude/SATS/unsafe.sats"

staload "hashmap/SATS/hashmap.sats"
staload "hashmap/SATS/array-mapped-tree.sats"
staload "hashmap/SATS/bits-source.sats"
staload "hashmap/SATS/uptr.sats"

staload _ = "hashmap/DATS/uptr.dats"

#define NIL list_vt_nil ()
#define :: list_vt_cons

(********************************************************************)

datavtype map_vt (hash_vt  : vt@ype,
                  key_vt   : vt@ype,
                  value_vt : vt@ype,
                  size     : int) =
| map_vt_nil (hash_vt, key_vt, value_vt, 0) of ()
| {n : int | 1 <= n}
  {node_p : addr}
  map_vt_tree (hash_vt, key_vt, value_vt, n) of
    (size_t n, ptr node_p)

assume hashmap_vt (hash_vt, key_vt, value_vt, size) =
  map_vt (hash_vt, key_vt, value_vt, size)

(********************************************************************)

fn {x_vt, y_vt : vt@ype}
pair_create (x : x_vt,
             y : y_vt) :
    [p : addr]
    @(@(x_vt, y_vt) @ p, mfree_gc_v p | ptr p) =
  let
    val num_bytes = sizeof<@(x_vt, y_vt)>
    val @(pf_pair, pf_mfree | p) = malloc_gc num_bytes
    prval _ = $UN.castview2void_at{@(x_vt?, y_vt?)} pf_pair
    val _ = !p := @(x, y)
  in
    @(pf_pair, pf_mfree | p)
  end

fn {x_vt, y_vt : vt@ype}
pair_free {p      : addr}
          (pair   : @(@(x_vt, y_vt) @ p, mfree_gc_v p | ptr p),
           x_free : !(x_vt -<cloptr1> void) >> _,
           y_free : !(y_vt -<cloptr1> void) >> _) :
    void =
  {
    val @(pf_pair, pf_mfree | p) = pair
    val @(x, y) = !p
    
    (* Free the elements of the pair. *)
    val _ = x_free x
    val _ = y_free y

    prval _ =
      $UN.castview2void_at{@[byte?][sizeof (@(x_vt, y_vt))]} pf_pair

    (* Free the storage for the pair itself. *)
    val _ = mfree_gc (pf_pair, pf_mfree | p)
  }

(********************************************************************)

implement {}
hashmap () = map_vt_nil ()

(********************************************************************)

(*
implement {key_vt, value_vt}
hashmap_free (map, key_free, value_free) =
  {
    val key_free_p = $UN.castvwtp1{Ptr} key_free
    val value_free_p = $UN.castvwtp1{Ptr} value_free

    val key_value_free =
      (* A closure that frees a key-value pair. *)
      (* FIXME: These will be needed more generally. Make
                a subroutine for that. *)
      lam (key_value_up : uintptr) : void =<cloptr1>
        {
          val key_free =
            $UN.castvwtp0{key_vt -<cloptr1> void} key_free_p
          val value_free =
            $UN.castvwtp0{value_vt -<cloptr1> void} value_free_p

          val pair =
            $UN.castvwtp0
              {[p : addr]
               @(@(key_vt, value_vt) @ p, mfree_gc_v p | ptr p)}
              (uptr2ptr (uintptr2uptr key_value_up))

          (* Free the key-value pair. *)
          val _ = pair_free (pair, key_free, value_free)

          prval _ = $UN.castvwtp0{void} key_free
          prval _ = $UN.castvwtp0{void} value_free
        }

    prval _ = cloptr_free ($UN.castvwtp0{cloptr0} key_value_free)
  }
*)

(********************************************************************)
