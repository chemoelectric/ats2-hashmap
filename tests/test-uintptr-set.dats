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

#define ats2_hashmap_test_uintptr_set_add(x, y) ((x) + (y))
#define ats2_hashmap_test_uintptr_set_mul(x, y) ((x) * (y))
#define ats2_hashmap_test_uintptr_set_mod(x, y) ((x) % (y))
#define ats2_hashmap_test_uintptr_set_eq(x, y) ((x) == (y))
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
  compare (x, y)

implement
g1uint_add<uint64knd> (x, y) =
  let
    extern fun
    add {x, y : int}
        (x    : g1uint (uint64knd, x),
         y    : g1uint (uint64knd, y)) :<>
        g1uint (uint64knd, x + y) =
      "mac#ats2_hashmap_test_uintptr_set_add"
  in
    add (x, y)
  end

implement
g1uint_mul<uint64knd> (x, y) =
  let
    extern fun
    mul {x, y : int}
        (x    : g1uint (uint64knd, x),
         y    : g1uint (uint64knd, y)) :<>
        g1uint (uint64knd, x * y) =
      "mac#ats2_hashmap_test_uintptr_set_mul"
  in
    mul (x, y)
  end

implement
g1uint_mod<uint64knd> (x, y) =
  let
    extern fun
    mod_ {x, y : int | 1 <= y}
         (x    : g1uint (uint64knd, x),
          y    : g1uint (uint64knd, y)) :<>
        g1uint (uint64knd, x mod y) =
      "mac#ats2_hashmap_test_uintptr_set_mod"
  in
    mod_ (x, y)
  end

implement
g1uint_eq<uint64knd> (x, y) =
  let
    extern fun
    eq {x, y : int}
       (x    : g1uint (uint64knd, x),
        y    : g1uint (uint64knd, y)) :<>
        bool (x == y) =
      "mac#ats2_hashmap_test_uintptr_set_eq"
  in
    eq (x, y)
  end

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

        val elems = list_vt_quicksort<uintptr> (elems)
        val lst = list_vt_quicksort<uintptr> (lst)

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
generate_random_numbers {n       : int}
                        {seed    : int}
                        {modulus : int}
                        {factor  : int}
                        (arr     : &(@[uintptr][n]),
                         n       : size_t n,
                         seed    : uint64 seed,
                         modulus : uint64 modulus,
                         factor  : uint64 factor) : void =
  let
    (*
      See https://en.wikipedia.org/w/index.php?title=Linear_congruential_generator&oldid=1043012257
      These are numbers attributed to Donald Knuth.
    *)
    val a : [u : int] uint64 u =
      $extval ([u : int] uint64 u,
               "((atstype_uint64) 6364136223846793005ULL)")
    val c : [u : int] uint64 u =
      $extval ([u : int] uint64 u,
               "((atstype_uint64) 1442695040888963407ULL)")

    var seed : [seed : int] uint64 seed = seed
    var i : [i : int | 0 <= i; i <= n] size_t i
    prval _ = lemma_g1uint_param n
    prval _ = lemma_g1uint_param modulus
  in
    for (i := i2sz 0; i <> n; i := succ i)
      let
        val seed1 = (a * seed) + c
      in
        seed := seed1;
        if modulus = $extval (uint64 0, "((atstype_uint64) 0)") then
          arr[i] := $UN.cast{uintptr} (factor * seed1)
        else
          arr[i] := $UN.cast{uintptr} (factor * (g1uint_mod (seed1, modulus)))
      end
  end

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
          (set, "tests/test-2021-10-03-11-51-50.structure",
                "tests/test-2021-10-03-11-51-50.structure.reference"))
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
          (set, "tests/test-2021-10-03-11-55-11.structure",
                "tests/test-2021-10-03-11-55-11.structure.reference"))
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
          (set, "tests/test-2021-10-03-11-58-30.structure",
                "tests/test-2021-10-03-11-58-30.structure.reference"))
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
          (set, "tests/test-2021-10-03-12-00-18.structure",
                "tests/test-2021-10-03-12-00-18.structure.reference"))
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
          (set, "tests/test-2021-10-03-12-02-25.structure",
                "tests/test-2021-10-03-12-02-25.structure.reference"))
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
          (set, "tests/test-2021-10-03-10-50-40.structure",
                "tests/test-2021-10-03-10-50-40.structure.reference"))
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
          (set, "tests/test-2021-10-03-12-26-02.structure",
                "tests/test-2021-10-03-12-26-02.structure.reference"))
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
          (set, "tests/test-2021-10-03-12-29-17.structure",
                "tests/test-2021-10-03-12-29-17.structure.reference"))
    val _ = assertloc (compare_elements (set, (u2up 0x010101U) :: (u2up 0x000101U) :: NIL))
    val _ = free set
    val _ = assertloc (node_alloc_count = zero)
  }

fn
test_root_node_subnode_collision () : void =
  {
    val set = uintptr_set () + (u2up 0x01U) + (u2up 0x0101U) + (u2up 0x010101U)
    val _ = assertloc (size set = i2sz 3)
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
               i = (u2up 0x0101U) ||
               i = (u2up 0x010101U) then
              assertloc (set \contains i)
            else
              assertloc (not (set \contains i))
          end
      end
    val _ =
      assertloc
        (compare_structure
          (set, "tests/test-2021-10-05-01-01-01.structure",
                "tests/test-2021-10-05-01-01-01.structure.reference"))
    val _ = assertloc (compare_elements (set, (u2up 0x010101U) :: (u2up 0x0101U) :: (u2up 0x01U) :: NIL))
    val _ = free set
    val _ = assertloc (node_alloc_count = zero)
  }

fn
array_to_list {n   : int}
              (arr : &(@[uintptr][n]),
               n   : size_t n) :
    list_vt (uintptr, n) =
  let
    fun
    loop {i   : int | 0 <= i; i <= n} .<i>.
         (arr : &(@[uintptr][n]),
          n   : size_t n,
          i   : size_t i,
          lst : list_vt (uintptr, n - i)) :
        list_vt (uintptr, n) =
      if i = i2sz 0 then
        lst
      else
        let
          val j = pred i
          val elem = arr[j]
        in
          loop {i - 1} (arr, n, j, elem :: lst)
        end

    prval _ = lemma_g1uint_param n
  in
    loop {n} (arr, n, n, NIL)
  end

fn
test_array_of_numbers {n           : int}
                      (numbers     : &(@[uintptr][n]),
                       n           : size_t n,
                       struct_file : String0,
                       ref_file    : String0) : bool =
  let
    prval _ = lemma_g1uint_param n

    var set : uintptr_set_vt = uintptr_set ()
    var i : [i : int | 0 <= i; i <= n] size_t i
    val _ =
      for (i := i2sz 0; i <> n; i := succ i)
        begin
          //print! (i, " "); println_uintptr (numbers[i]);
          set := set + numbers[i]
        end
    val _ =
      for (i := i2sz 0; i <> n; i := succ i)
        begin
          //print! (i, " "); println_uintptr (numbers[i]);
          assertloc (set \contains numbers[i])
        end
    val result = compare_structure (set, struct_file, ref_file)
    val lst = list_vt_quicksort<uintptr> (array_to_list (numbers, n))
    fun
    loop (set : !uintptr_set_vt,
          lst : !List_vt (uintptr),
          i   : uintptr) : void =
      case+ lst of
      | NIL => ()
      | @ head :: tail =>
        {
          fun
          loop2 (set  : !uintptr_set_vt,
                 head : uintptr,
                 j    : uintptr) : uintptr =
            if j = head then
              begin
                assertloc (set \contains j);
                succ j
              end
            else
              begin
                assertloc (not (set \contains j));
                loop2 (set, head, succ j)
              end
          val _ = loop (set, tail, loop2 (set, head, i))
          prval _ = fold@ lst
        }
    val _ = free lst
// FIXME: The list may contain duplicates and needs to be cleaned of them,
//        before one can run this test:
//    val result = result && compare_elements (set, array_to_list (numbers, n))
    val _ = free set
  in
    result
  end

implement
main0 () =
  {
    val _ = test_empty ()
    val _ = test_size_one ()
    val _ = test_root_node_expansion ()
    val _ = test_root_node_leaf_collision ()
    val _ = test_root_node_subnode_collision ()

    #define NUMBER_OF_RANDOM_NUMBERS 1000

    var random_numbers =
      @[uintptr][NUMBER_OF_RANDOM_NUMBERS]
        ($extval (uintptr, "((atstype_uintptr) 0)"))
    val seed = $extval ([u : int] uint64 u, "((atstype_uint64) 1234)")
    val _ =
      generate_random_numbers
        (random_numbers, i2sz NUMBER_OF_RANDOM_NUMBERS, seed,
         $extval (uint64 0, "((atstype_uint64) 0)"),
         $extval (uint64 0, "((atstype_uint64) 1)"))
    val _ =
      assertloc
        (test_array_of_numbers
          (random_numbers, i2sz NUMBER_OF_RANDOM_NUMBERS,
           "tests/test-2021-10-05-03-40-40.structure",
           "tests/test-2021-10-05-03-40-40.structure.reference"))

    var clashier_numbers =
      @[uintptr][NUMBER_OF_RANDOM_NUMBERS]
        ($extval (uintptr, "((atstype_uintptr) 0)"))
    val _ =
      generate_random_numbers
        (clashier_numbers, i2sz NUMBER_OF_RANDOM_NUMBERS, seed,
         $extval (uint64 0, "((atstype_uint64) 1000)"),
         $extval (uint64 0, "((atstype_uint64) 1000)"))
    val _ =
      assertloc
        (test_array_of_numbers
          (clashier_numbers, i2sz NUMBER_OF_RANDOM_NUMBERS,
           "tests/test-2021-10-05-04-18-20.structure",
           "tests/test-2021-10-05-04-18-20.structure.reference"))
  }
