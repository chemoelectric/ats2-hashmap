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

staload UN = "prelude/SATS/unsafe.sats"

staload "hashmap/SATS/uintptr-set.sats"
staload _ = "hashmap/DATS/uintptr-set.dats"

#include "hashmap/HATS/config.hats"

%{#
extern volatile _Atomic atstype_uintptr ats2_hashmap_node_alloc_count;
%}

macdef node_alloc_count =
  $extval (uintptr, "ats2_hashmap_node_alloc_count")

#define NIL list_vt_nil ()
#define :: list_vt_cons

extern castfn
i2up : {i : int | 0 <= i} int i -<> uintptr i

extern castfn
u2up : {i : int} uint i -<> uintptr i

macdef zero = i2up 0
prval _ = lemma_g1uint_param zero

macdef reasonably_big_number = u2up 0x1000000U
prval _ = lemma_g1uint_param reasonably_big_number

implement
g1uint_succ<uintptrknd> (x) =
  $UN.cast (succ ($UN.cast{uintptr} x))

implement
g1uint_eq<uintptrknd> (x, y) =
  $UN.cast (($UN.cast{uintptr} x) = ($UN.cast{uintptr} y))

implement
g1uint_lte<uintptrknd> (x, y) =
  $UN.cast (($UN.cast{uintptr} x) <= ($UN.cast{uintptr} y))

implement
gcompare_val_val<uintptr> (x, y) =
  if x < y then
    ~1
  else if x = y then
    0
  else
    1

fn
new_entry_printer () : (FILEref, uintptr) -<cloptr1> void =
  lam (out, entry) => fprint! (out, entry)

fn
entry_printer_free (printer : (FILEref, uintptr) -<cloptr1> void) :
    void =
  cloptr_free ($UN.castvwtp0 printer)

fn
println_uintptr (x : uintptr) : void =
  {
    val _ = $extfcall (int, "printf", "%08llX\n", $UN.cast{ullint} x)
  }

fn
compare_elements (set : !uintptr_set_vt >> _,
                  lst : List_vt uintptr) : bool =
  let
    val elems = uintptr_set_elements (set)
    val length_elems = length elems
    val length_lst = length lst
  in
    if length_elems <> length_lst then
      begin
        free elems;
        free lst;
        false
      end
    else
      let
        fun
        loop {n : int | 0 <= n}
             (elems : list_vt (uintptr, n),
              lst   : list_vt (uintptr, n)) : bool =
          case+ elems of
          | ~ NIL =>
            begin
              case+ lst of
              | ~ NIL => true
            end
          | ~ head1 :: tail1 =>
            begin
              case+ lst of
              | ~ head2 :: tail2 =>
                if head1 <> head2 then
                  begin
                    free tail1;
                    free tail2;
                    false
                  end
                else
                  loop (tail1, tail2)
            end

        val elems = list_vt_mergesort<uintptr> (elems)
        val lst = list_vt_mergesort<uintptr> (lst)

        prval _ = lemma_list_vt_param lst
      in
        loop (elems, lst)
      end
  end

fn
compare_structure (set                : !uintptr_set_vt >> _,
                   filename           : String0,
                   reference_filename : String0) : bool =
  (* Currently there are structure tests only for 64-bit uintptr. *)
  if BITSIZEOF_UINTPTR = 64 then
    let
      val f = fileref_open_exn (filename, file_mode_w)
      val print_entry = new_entry_printer ()
      val _ = uintptr_set_print_structure (f, set, print_entry)
      val _ = entry_printer_free (print_entry)
      val _ = fileref_close (f)

      val space = string1_copy (" ")
      val fname = string1_copy (filename)
      val reffname = string1_copy (reference_filename)
      val cmp = string1_copy ("cmp -s ")
      val command1 = strnptr_append (space, fname)
      val command2 = strnptr_append (reffname, command1)
      val _ = free (command1)
      val command = strnptr_append (cmp, command2)
      val _ = free (command2)
      val status =
        $extfcall (int, "system", $UN.castvwtp1{string} command)
      val _ = free (command)
      val _ = free (space)
      val _ = free (fname)
      val _ = free (reffname)
      val _ = free (cmp)
    in
      status = 0
    end
  else
    true

fn
test_empty () : void =
  {
    val set = uintptr_set ()
    val _ = assertloc (size set = i2sz 0)
    val _ = assertloc (iseqz set)
    val _ = assertloc (not (isneqz set))
    val _ =
      let
        var i : [i : int] uintptr i
      in
        for (i := zero; i <= reasonably_big_number; i := succ i)
          assertloc (not (has_element (set, $UN.cast i)))
      end
    val _ =
      assertloc
        (compare_structure
          (set, "tests/test-03-10-2021-11-51-50.structure",
                "tests/test-03-10-2021-11-51-50.structure.reference"))
    val _ = assertloc (compare_elements (set, NIL))
    val _ = free set
    val _ = assertloc (node_alloc_count = zero)
  }

fn
test_size_one () : void =
  {
    val set = uintptr_set ()

    val set = add_element (set, u2up 0x10U)
    val _ = assertloc (size set = i2sz 1)
    val _ = assertloc (not (iseqz set))
    val _ = assertloc (isneqz set)
    val _ =
      let
        var i : [i : int] uintptr i
      in
        for (i := zero; i <= reasonably_big_number; i := succ i)
          begin
            //println_uintptr (i);
            if i = u2up 0x10U then
              assertloc (has_element (set, i))
            else
              assertloc (not (has_element (set, i)))
          end
      end
    val _ =
      assertloc
        (compare_structure
          (set, "tests/test-03-10-2021-11-55-11.structure",
                "tests/test-03-10-2021-11-55-11.structure.reference"))
    val _ = assertloc (compare_elements (set, (u2up 0x10U) :: NIL))

    (* Add the same entry. Also, use different notations for
       the same operations. *)
    val set = set + u2up 0x10U
    val _ = assertloc (size set = i2sz 1)
    val _ = assertloc (not (iseqz set))
    val _ = assertloc (isneqz set)
    val _ =
      let
        var i : [i : int] uintptr i
      in
        for (i := zero; i <= reasonably_big_number; i := succ i)
          begin
            //println_uintptr (i);
            if i = u2up 0x10U then
              assertloc (set \contains i)
            else
              assertloc (not (set \contains i))
          end
      end
    val _ =
      assertloc
        (compare_structure
          (set, "tests/test-03-10-2021-11-58-30.structure",
                "tests/test-03-10-2021-11-58-30.structure.reference"))
    val _ = assertloc (compare_elements (set, (u2up 0x10U) :: NIL))

    val _ = free set
    val _ = assertloc (node_alloc_count = zero)
  }

fn
test_root_node_expansion () : void =
  {
    val set = uintptr_set () + (u2up 0x01U) + (u2up 0x02U)
    val _ = assertloc (size set = i2sz 2)
    val _ = assertloc (not (iseqz set))
    val _ = assertloc (isneqz set)
    val _ =
      let
        var i : [i : int] uintptr i
      in
        for (i := zero; i <= reasonably_big_number; i := succ i)
          begin
            //println_uintptr (i);
            if i = (u2up 0x01U) || i = (u2up 0x02U) then
              assertloc (set \contains i)
            else
              assertloc (not (set \contains i))
          end
      end
    val _ =
      assertloc
        (compare_structure
          (set, "tests/test-03-10-2021-12-00-18.structure",
                "tests/test-03-10-2021-12-00-18.structure.reference"))
    val _ = assertloc (compare_elements (set, (u2up 0x02U) :: (u2up 0x01U) :: NIL))
    val _ = free set
    val _ = assertloc (node_alloc_count = zero)

    val set = uintptr_set () + (u2up 0x02U) + (u2up 0x01U)
    val _ = assertloc (size set = i2sz 2)
    val _ = assertloc (not (iseqz set))
    val _ = assertloc (isneqz set)
    val _ =
      let
        var i : [i : int] uintptr i
      in
        for (i := zero; i <= reasonably_big_number; i := succ i)
          begin
            //println_uintptr (i);
            if i = (u2up 0x01U) || i = (u2up 0x02U) then
              assertloc (set \contains i)
            else
              assertloc (not (set \contains i))
          end
      end
    val _ =
      assertloc
        (compare_structure
          (set, "tests/test-03-10-2021-12-02-25.structure",
                "tests/test-03-10-2021-12-02-25.structure.reference"))
    val _ = assertloc (compare_elements (set, (u2up 0x02U) :: (u2up 0x01U) :: NIL))
    val _ = free set
    val _ = assertloc (node_alloc_count = zero)

    val set =
      uintptr_set () +
        (u2up 0x0FU) +
        (u2up 0x02U) +
        (u2up 0x05U) +
        (u2up 0x04U) +
        (u2up 0x09U) +
        (u2up 0x11U) +
        (u2up 0x01U) +
        (u2up 0x00U)
    val _ = assertloc (size set = i2sz 8)
    val _ = assertloc (not (iseqz set))
    val _ = assertloc (isneqz set)
    val _ =
      let
        var i : [i : int] uintptr i
      in
        for (i := zero; i <= reasonably_big_number; i := succ i)
          begin
            //println_uintptr (i);
            if i = (u2up 0x0FU) ||
               i = (u2up 0x02U) ||
               i = (u2up 0x05U) ||
               i = (u2up 0x04U) ||
               i = (u2up 0x09U) ||
               i = (u2up 0x11U) ||
               i = (u2up 0x01U) ||
               i = (u2up 0x00U) then
              assertloc (set \contains i)
            else
              assertloc (not (set \contains i))
          end
      end
    val _ =
      assertloc
        (compare_structure
          (set, "tests/test-03-10-2021-10-50-40.structure",
                "tests/test-03-10-2021-10-50-40.structure.reference"))
    val _ = assertloc (compare_elements (set,
                                         (u2up 0x11U) ::
                                         (u2up 0x0FU) ::
                                         (u2up 0x09U) ::
                                         (u2up 0x05U) ::
                                         (u2up 0x04U) ::
                                         (u2up 0x02U) ::
                                         (u2up 0x01U) ::
                                         (u2up 0x00U) :: NIL))
    val _ = free set
    val _ = assertloc (node_alloc_count = zero)
  }

fn
test_root_node_leaf_collision () : void =
  {
    val set = uintptr_set () + (u2up 0x01U) + (u2up 0x0101U)
    val _ = assertloc (size set = i2sz 2)
    val _ = assertloc (not (iseqz set))
    val _ = assertloc (isneqz set)
    val _ =
      let
        var i : [i : int] uintptr i
      in
        for (i := zero; i <= reasonably_big_number; i := succ i)
          begin
            //println_uintptr (i);
            if i = (u2up 0x01U) ||
               i = (u2up 0x0101U) then
              assertloc (set \contains i)
            else
              assertloc (not (set \contains i))
          end
      end
    val _ =
      assertloc
        (compare_structure
          (set, "tests/test-03-10-2021-12-26-02.structure",
                "tests/test-03-10-2021-12-26-02.structure.reference"))
    val _ = assertloc (compare_elements (set, (u2up 0x0101U) :: (u2up 0x01U) :: NIL))
    val _ = free set
    val _ = assertloc (node_alloc_count = zero)

    val set = uintptr_set () +
                (u2up 0x000101U) +
                (u2up 0x010101U)
    val _ = assertloc (size set = i2sz 2)
    val _ = assertloc (not (iseqz set))
    val _ = assertloc (isneqz set)
    val _ =
      let
        var i : [i : int] uintptr i
      in
        for (i := zero; i <= reasonably_big_number; i := succ i)
          begin
            //println_uintptr (i);
            if i = (u2up 0x000101U) ||
               i = (u2up 0x010101U) then
              assertloc (set \contains i)
            else
              assertloc (not (set \contains i))
          end
      end
    val _ =
      assertloc
        (compare_structure
          (set, "tests/test-03-10-2021-12-29-17.structure",
                "tests/test-03-10-2021-12-29-17.structure.reference"))
    val _ = assertloc (compare_elements (set, (u2up 0x010101U) :: (u2up 0x000101U) :: NIL))
    val _ = free set
    val _ = assertloc (node_alloc_count = zero)
  }

implement
main0 () =
  {
    val _ = test_empty ()
    val _ = test_size_one ()
    val _ = test_root_node_expansion ()
    val _ = test_root_node_leaf_collision ()
  }
