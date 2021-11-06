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

%{#
#include <stdio.h>
#include <stdlib.h>
%}

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

#include "hashmap/HATS/strnptrmap-spookyhash.hats"

staload UN = "prelude/SATS/unsafe.sats"

#define NIL list_vt_nil ()
#define :: list_vt_cons

implement
list_vt_mergesort$cmp<Strnptr1> (x, y) =
  compare ($UN.strnptr2string x, $UN.strnptr2string y)

implement
list_vt_mergesort$cmp<@(Strnptr1, Strnptr1)> (x, y) =
  let
    val i = compare ($UN.strnptr2string (x.0),
                     $UN.strnptr2string (y.0))
  in
    if i = 0 then
      compare($UN.strnptr2string (x.1),
              $UN.strnptr2string (y.1))
    else
      i
  end

fn
compare_num (x : string, y : string) :<> int =
  let
    val nx = $extfcall (ullint, "atoll", x)
    val ny = $extfcall (ullint, "atoll", y)
  in
    compare (nx, ny)
  end

local

  implement
  hashmap$value_vt_free<Strnptr1> (value) =
    free value

  implement
  hashmap$value_vt_copy<Strnptr1> (value) =
    string1_copy ($UN.strnptr2string value)

in

  fn
  s2s_map_set_string_string
          {size  : int}
          (map   : strnptrmap_vt (Strnptr1, size),
           key   : string,
           value : string) :
      [new_size : int | new_size == size || new_size == size + 1]
      strnptrmap_vt (Strnptr1, new_size) =
    let
      val value = g1ofg0 value
      prval _ = lemma_string_param value
    in
      strnptrmap_set<Strnptr1> (map, key, string1_copy value)
    end
  fn
  s2s_map_set_strptr_strptr
          {size  : int}
          (map   : strnptrmap_vt (Strnptr1, size),
           key   : Strptr1,
           value : Strptr1) :
      [new_size : int | new_size == size || new_size == size + 1]
      strnptrmap_vt (Strnptr1, new_size) =
    let
      val value = strptr2strnptr value
      prval _ = lemma_strnptr_param value
    in
      strnptrmap_set<Strnptr1> (map, key, value)
    end
  fn
  s2s_map_set_strnptr_strnptr
          {size  : int}
          (map   : strnptrmap_vt (Strnptr1, size),
           key   : Strnptr1,
           value : Strnptr1) :
      [new_size : int | new_size == size || new_size == size + 1]
      strnptrmap_vt (Strnptr1, new_size) =
    strnptrmap_set<Strnptr1> (map, key, value)
  overload s2s_map_set with s2s_map_set_string_string of 50
  overload s2s_map_set with s2s_map_set_strptr_strptr of 60
  overload s2s_map_set with s2s_map_set_strnptr_strnptr of 70

  fn
  s2s_map_del_string
          {size  : int}
          (map   : strnptrmap_vt (Strnptr1, size),
           key   : string) :
      [new_size : int | new_size == size || new_size == size - 1]
      strnptrmap_vt (Strnptr1, new_size) =
    strnptrmap_del<Strnptr1> (map, key)
  fn
  s2s_map_del_strptr
          {size  : int}
          (map   : strnptrmap_vt (Strnptr1, size),
           key   : !RD(Strptr1) >> _) :
      [new_size : int | new_size == size || new_size == size - 1]
      strnptrmap_vt (Strnptr1, new_size) =
    strnptrmap_del<Strnptr1> (map, key)
  fn
  s2s_map_del_strnptr
          {size  : int}
          (map   : strnptrmap_vt (Strnptr1, size),
           key   : !RD(Strnptr1) >> _) :
      [new_size : int | new_size == size || new_size == size - 1]
      strnptrmap_vt (Strnptr1, new_size) =
    strnptrmap_del<Strnptr1> (map, key)
  overload s2s_map_del with s2s_map_del_string of 50
  overload s2s_map_del with s2s_map_del_strptr of 60
  overload s2s_map_del with s2s_map_del_strnptr of 70

  fn
  s2s_map_get_opt_string
        {size : int}
        (map  : !RD(strnptrmap_vt (Strnptr1, size)) >> _,
         key  : string) :
      Option_vt (Strnptr1) =
    strnptrmap_get_opt<Strnptr1> {size} (map, key)
  fn
  s2s_map_get_opt_strptr
        {size : int}
        (map  : !RD(strnptrmap_vt (Strnptr1, size)) >> _,
         key  : !RD(Strptr1) >> _) :
      Option_vt (Strnptr1) =
    strnptrmap_get_opt<Strnptr1> {size} (map, key)
  fn
  s2s_map_get_opt_strnptr
        {size : int}
        (map  : !RD(strnptrmap_vt (Strnptr1, size)) >> _,
         key  : !RD(Strnptr1) >> _) :
      Option_vt (Strnptr1) =
    strnptrmap_get_opt<Strnptr1> {size} (map, key)
  overload s2s_map_get_opt with s2s_map_get_opt_string of 50
  overload s2s_map_get_opt with s2s_map_get_opt_strptr of 60
  overload s2s_map_get_opt with s2s_map_get_opt_strnptr of 70

  fn
  s2s_map_has_key_string
        {size : int}
        (map  : !RD(strnptrmap_vt (Strnptr1, size)) >> _,
         key  : string) :
      bool =
    strnptrmap_has_key<Strnptr1> {size} (map, key)
  fn
  s2s_map_has_key_strptr
        {size : int}
        (map  : !RD(strnptrmap_vt (Strnptr1, size)) >> _,
         key  : !RD(Strptr1) >> _) :
      bool =
    strnptrmap_has_key<Strnptr1> {size} (map, key)
  fn
  s2s_map_has_key_strnptr
        {size : int}
        (map  : !RD(strnptrmap_vt (Strnptr1, size)) >> _,
         key  : !RD(Strnptr1) >> _) :
      bool =
    strnptrmap_has_key<Strnptr1> {size} (map, key)
  overload s2s_map_has_key with s2s_map_has_key_string of 50
  overload s2s_map_has_key with s2s_map_has_key_strptr of 60
  overload s2s_map_has_key with s2s_map_has_key_strnptr of 70

  fn
  s2s_map_pairs
          {size : int}
          (map  : !strnptrmap_vt (Strnptr1, size) >> _) :
      list_vt (@(Strnptr1, Strnptr1), size) =
    strnptrmap_pairs<Strnptr1> {size} map

  fn
  s2s_map_keys
          {size : int}
          (map  : !strnptrmap_vt (Strnptr1, size) >> _) :
      list_vt (Strnptr1, size) =
    strnptrmap_keys<Strnptr1> {size} map

  fn
  s2s_map_values
          {size : int}
          (map  : !strnptrmap_vt (Strnptr1, size) >> _) :
      list_vt (Strnptr1, size) =
    strnptrmap_values<Strnptr1> {size} map

  fn
  s2s_map_free
          {size : int}
          (map  : strnptrmap_vt (Strnptr1, size)) :
      void =
    strnptrmap_free<Strnptr1> map
  overload free with s2s_map_free of 20

end

implement
list_vt_freelin$clear<Strnptr1> (x) =
  free x

implement
list_vt_freelin$clear<@(Strnptr1, Strnptr1)> (x) =
  begin
    free (x.0);
    free (x.1)
  end

fn
make_strnptr_fprint () :
    (FILEref, !Strnptr1 >> _) -<cloptr1> void =
  lam (f, s) => fprint! (f, $UN.strnptr2string s)

fn
rand_uint64 (seed : uint64) :<> uint64 =
  (* A linear congruential generator used by Donald Knuth.
     See https://en.wikipedia.org/w/index.php?title=Linear_congruential_generator&oldid=1043012257 *)
  (seed * ($UN.cast{uint64} 6364136223846793005ULL)) +
    ($UN.cast{uint64} 1442695040888963407ULL)

var rand_seed : uint64 = $UN.cast{uint64} 1442695040888963407ULL
val p_rand_seed : [p : addr] ptr p = addr@ rand_seed

fn
get_rand_seed () : uint64 =
  let
    val [p : addr] @(pf | p) =
      $UN.castvwtp0{[p : addr] @(uint64 @ p | ptr p)} (p_rand_seed)
    val seed = !p
    prval _ = $UN.castvwtp0{void} @(pf | p)
  in
    seed
  end

fn
set_rand_seed (seed : uint64) : void =
  {
    val [p : addr] @(pf | p) =
      $UN.castvwtp0{[p : addr] @(uint64 @ p | ptr p)} (p_rand_seed)
    val _ = !p := seed
    prval _ = $UN.castvwtp0{void} @(pf | p)
  }

fn
reset_rand_seed () : void =
  set_rand_seed ($UN.cast{uint64} 1442695040888963407ULL)

fn
randint_size {n : int | n != 0}
             (n : size_t n) : sizeLt (n) =
  let
    prval _ = lemma_g1uint_param n
    val seed = get_rand_seed ()
  in
    set_rand_seed (rand_uint64 (seed));
    ($UN.cast{Size_t} seed) mod n
  end

fn
size2strnptr (n : size_t) : Strnptr1 =
  let
    var arr : @[char][1000]
    val _ = $extfcall (int, "snprintf", addr@ arr, i2sz 1000,
                       "%zu", n)
    val s = $UN.cast{String} (addr@ arr)
    prval _ = lemma_string_param s
  in
    string1_copy s
  end

fn
fprint_strnptr_list_vt
        {n   : int}
        (f   : FILEref,
         lst : !list_vt (Strnptr1, n) >> _) :
    void =
  let
    fun
    loop {m         : int | 0 <= m} .<m>.
         (lst       : !list_vt (Strnptr1, m) >> _,
          separator : string) :
        void =
      case+ lst of
      | NIL => ()
      | @ head :: tail =>
        {
          val _ = fprint! (f, separator, head)
          val _ = loop (tail, " ")
          prval _ = fold@ lst
        }
    prval _ = lemma_list_vt_param lst
  in
    fprint! (f, "(");
    loop (lst, "");
    fprint! (f, ")")
  end

fn
fprint_strnptr_pair_list_vt
        {n   : int}
        (f   : FILEref,
         lst : !list_vt (@(Strnptr1, Strnptr1), n) >> _) :
    void =
  let
    fun
    loop {m         : int | 0 <= m} .<m>.
         (lst       : !list_vt (@(Strnptr1, Strnptr1), m) >> _,
          separator : string) :
        void =
      case+ lst of
      | NIL => ()
      | @ head :: tail =>
        {
          val _ = fprint! (f, separator,
                           "(", head.0, " . ", head.1, ")")
          val _ = loop (tail, " ")
          prval _ = fold@ lst
        }
    prval _ = lemma_list_vt_param lst
  in
    fprint! (f, "(");
    loop (lst, "");
    fprint! (f, ")")
  end

fn
strnptr_list_vt_test
        {m, n : int}
        (lst1 : !list_vt (Strnptr1, m) >> _,
         lst2 : !list_vt (string, n) >> _) :
    bool =
  let
    fun
    loop {m, n : int | 0 <= m; 0 <= n} .<m,n>.
         (lst1 : !list_vt (Strnptr1, m) >> _,
          lst2 : !list_vt (string, n) >> _) :
        bool =
      case+ lst1 of
      | NIL =>
        begin
          case+ lst2 of
          | NIL => true
          | _ :: _ => false
        end
      | head1 :: tail1 =>
        begin
          case+ lst2 of
          | NIL => false
          | head2 :: tail2 =>
            if ($UN.strnptr2string head1) <> head2 then
              false
            else
              loop (tail1, tail2)
        end
    prval _ = lemma_list_vt_param lst1
    prval _ = lemma_list_vt_param lst2
  in
    loop (lst1, lst2)
  end

fn
strnptr_pair_list_vt_test
        {m, n : int}
        (lst1 : !list_vt (@(Strnptr1, Strnptr1), m) >> _,
         lst2 : !list_vt (@(string, string), n) >> _) :
    bool =
  let
    fun
    loop {m, n : int | 0 <= m; 0 <= n} .<m,n>.
         (lst1 : !list_vt (@(Strnptr1, Strnptr1), m) >> _,
          lst2 : !list_vt (@(string, string), n) >> _) :
        bool =
      case+ lst1 of
      | NIL =>
        begin
          case+ lst2 of
          | NIL => true
          | _ :: _ => false
        end
      | head1 :: tail1 =>
        begin
          case+ lst2 of
          | NIL => false
          | head2 :: tail2 =>
            if ($UN.strnptr2string (head1.0)) <> (head2.0) then
              false
            else if ($UN.strnptr2string (head1.1)) <> (head2.1) then
              false
            else
              true
        end
    prval _ = lemma_list_vt_param lst1
    prval _ = lemma_list_vt_param lst2
  in
    loop (lst1, lst2)
  end

fn
s2s_map_fprint
        {size : int}
        (f    : FILEref,
         map  : !strnptrmap_vt (Strnptr1, size) >> _) : void =
  {
    val key_fprint = make_strnptr_fprint ()
    val value_fprint = make_strnptr_fprint ()
    val _ =
      hashmap_fprint<Strnptr1, Strnptr1>
        (f, map, key_fprint, value_fprint)
    val _ = cloptr_free ($UN.castvwtp0{cloptr0} key_fprint)
    val _ = cloptr_free ($UN.castvwtp0{cloptr0} value_fprint)
  }

fn
compare_structure
        {size               : int}
        (map                : !strnptrmap_vt (Strnptr1, size) >> _,
         filename           : String0,
         reference_filename : String0) : bool =
  let
    val f = fileref_open_exn (filename, file_mode_w)
    val _ = s2s_map_fprint (f, map)
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
      $extfcall (int, "system", $UNSAFE.castvwtp1{string} command)
    val _ = free (command)
    val _ = free (space)
    val _ = free (fname)
    val _ = free (reffname)
    val _ = free (cmp)
  in
    status = 0
  end

fun
check_pairs {n   : int}
            (lst : !list_vt (@(Strnptr1, Strnptr1), n) >> _,
             map : !strnptrmap_vt (Strnptr1) >> _) :
    bool =
  case+ lst of
  | NIL => true
  | head :: tail =>
    let
      val- true = s2s_map_has_key (map, head.0)
      val- ~ Some_vt entry = s2s_map_get_opt (map, head.0)
      val eq =
        ($UN.strnptr2string entry) = ($UN.strnptr2string (head.1)) 
      val _ = free entry
    in
      if eq then
        check_pairs (tail, map)
      else
        false
    end

fun
check_lst {bigness : int}
          {n       : int | 0 <= n; n <= bigness} .<n>.
          (bigness : size_t bigness,
           lst     : &list_vt (Strnptr1, n) >> _,
           arr     : &(@[size_t][bigness]) >> _,
           n       : size_t n) : bool =
  case+ lst of
  | NIL => true
  | @ x :: tail =>
    let
      val y = size2strnptr (arr[bigness - n])
      val eq = (($UN.strnptr2string x) = ($UN.strnptr2string y))
      val _ = free y
    in
      if not eq then
        let
          prval _ = fold@ lst
        in
          false
        end
      else
        let
          val result = check_lst (bigness, tail, arr, pred n)
          prval _ = fold@ lst
        in
          result
        end
    end

fn
test1 () : void =
  {
    val foo2 = string0_copy "foo2"
    val bar2 = string0_copy "bar2"
    val foo3 = string1_copy "foo3"
    val bar3 = string1_copy "bar3"

    val map = strnptrmap ()

    val _ = assertloc (size map = i2sz 0)
    val _ = assertloc (iseqz map)
    val _ = assertloc (not (isneqz map))

    val map = s2s_map_set (map, "foo1", "bar1")
    val map = s2s_map_set (map, foo2, bar2)
    val map = s2s_map_set (map, foo3, bar3)

    val _ = assertloc (size map = i2sz 3)
    val _ = assertloc (not (iseqz map))
    val _ = assertloc (isneqz map)

    val foo2 = string0_copy "foo2"
    val bar2 = string0_copy "bar2"
    val foo3 = string1_copy "foo3"
    val bar3 = string1_copy "bar3"

    val- true = s2s_map_has_key (map, "foo1")
    val- ~ Some_vt x = s2s_map_get_opt (map, "foo1")
    val _ = assertloc ($UN.strnptr2string x = "bar1")
    val _ = free x

    val- true = s2s_map_has_key (map, foo2)
    val- ~ Some_vt x = s2s_map_get_opt (map, foo2)
    val _ = assertloc ($UN.strnptr2string x = $UN.strptr2string bar2)
    val _ = free x

    val- true = s2s_map_has_key (map, "foo2")
    val- ~ Some_vt x = s2s_map_get_opt (map, "foo2")
    val _ = assertloc ($UN.strnptr2string x = $UN.strptr2string bar2)
    val _ = free x

    val- true = s2s_map_has_key (map, foo3)
    val- ~ Some_vt x = s2s_map_get_opt (map, foo3)
    val _ = assertloc ($UN.strnptr2string x = $UN.strnptr2string bar3)
    val _ = free x

    val- true = s2s_map_has_key (map, "foo3")
    val- ~ Some_vt x = s2s_map_get_opt (map, "foo3")
    val _ = assertloc ($UN.strnptr2string x = $UN.strnptr2string bar3)
    val _ = free x

    val- false = s2s_map_has_key (map, "foo4")
    val- false = s2s_map_has_key (map, "foo5")
    val- false = s2s_map_has_key (map, "foo6")
    val- false = s2s_map_has_key (map, "foo7")
    val- ~ None_vt () = s2s_map_get_opt (map, "foo4")
    val- ~ None_vt () = s2s_map_get_opt (map, "foo5")
    val- ~ None_vt () = s2s_map_get_opt (map, "foo6")
    val- ~ None_vt () = s2s_map_get_opt (map, "foo7")

    val pairs =
      list_vt_mergesort<@(Strnptr1, Strnptr1)> (s2s_map_pairs (map))
    val pairs_ref = @("foo1", "bar1") :: @("foo2", "bar2")
                       :: @("foo3", "bar3") :: NIL
    val _ = assertloc (strnptr_pair_list_vt_test (pairs, pairs_ref))
    val _ = free pairs_ref
    //val _ = fprint_strnptr_pair_list_vt (stdout_ref, pairs)
    //val _ = fprintln! (stdout_ref)
    val _ = list_vt_freelin pairs

    val keys = list_vt_mergesort<Strnptr1> (s2s_map_keys (map))
    val keys_ref = "foo1" :: "foo2" :: "foo3" :: NIL
    val _ = assertloc (strnptr_list_vt_test (keys, keys_ref))
    val _ = free keys_ref
    //val _ = fprint_strnptr_list_vt (stdout_ref, keys)
    //val _ = fprintln! (stdout_ref)
    val _ = list_vt_freelin keys

    val values = list_vt_mergesort<Strnptr1> (s2s_map_values (map))
    val values_ref = "bar1" :: "bar2" :: "bar3" :: NIL
    val _ = assertloc (strnptr_list_vt_test (values, values_ref))
    val _ = free values_ref
    //val _ = fprint_strnptr_list_vt (stdout_ref, values)
    //val _ = fprintln! (stdout_ref)
    val _ = list_vt_freelin values

    val _ =
      assertloc
        (compare_structure
          (map, "tests/2021.10.31.10.54.20.structure",
           "tests/2021.10.31.10.54.20.structure.reference"))

    val map = s2s_map_set (map, "foo3", "bar1")
    val map = s2s_map_set (map, "foo1", "bar2")
    val map = s2s_map_set (map, "foo2", "bar3")

    val _ =
      assertloc
        (compare_structure
          (map, "tests/2021.10.31.11.39.37.structure",
           "tests/2021.10.31.11.39.37.structure.reference"))

    val _ = free foo2
    val _ = free bar2
    val _ = free foo3
    val _ = free bar3

    val _ = free map
  }

fn
test2 () : void =
  {
    val _ = reset_rand_seed ()

    #define BIGNESS 10000

    var numbers_in_order : @[size_t][BIGNESS]
    val _ =
      let
        implement
        array_initize$init<size_t> (i, x) =
          x := succ i
      in
        array_initize<size_t> (numbers_in_order, i2sz BIGNESS)
      end

    var numbers_permuted : @[size_t][BIGNESS]
    val _ =
      let
        implement
        array_initize$init<size_t> (i, x) =
          x := succ i
        implement
        array_permute$randint<> (n) =
          randint_size (n)
      in
        array_initize<size_t> (numbers_permuted, i2sz BIGNESS);
        array_permute<size_t> (numbers_permuted, i2sz BIGNESS)
      end

    fun
    fill_map {i         : int | i <= BIGNESS} .<BIGNESS - i>.
             (map       : strnptrmap_vt (Strnptr1),
              key_arr   : &(@[size_t][BIGNESS]) >> _,
              value_arr : &(@[size_t][BIGNESS]) >> _,
              i         : size_t i) :
        strnptrmap_vt (Strnptr1) =
      if i = i2sz BIGNESS then
        map
      else
        let
          prval _ = lemma_g1uint_param i
        in
          fill_map (s2s_map_set (map, size2strnptr (key_arr[i]),
                                 size2strnptr (value_arr[i])),
                    key_arr, value_arr, succ i)
        end

    val map = strnptrmap ()
    val map = fill_map (map, numbers_permuted,
                        numbers_in_order, i2sz 0)
    val _ = assertloc (size map = i2sz BIGNESS)
    val _ = assertloc (not (iseqz map))
    val _ = assertloc (isneqz map)
    val _ =
      assertloc
        (compare_structure
          (map, "tests/2021.10.31.13.08.40.structure",
           "tests/2021.10.31.13.08.40.structure.reference"))
    //
    var keys =
      let
        implement
        list_vt_mergesort$cmp<Strnptr1> (x, y) =
          compare_num ($UN.strnptr2string x,
                       $UN.strnptr2string y)
      in
        list_vt_mergesort<Strnptr1> (s2s_map_keys (map))
      end
    var values =
      let
        implement
        list_vt_mergesort$cmp<Strnptr1> (x, y) =
          compare_num ($UN.strnptr2string x,
                       $UN.strnptr2string y)
      in
        list_vt_mergesort<Strnptr1> (s2s_map_values (map))
      end
    val _ = assertloc (length keys = BIGNESS)
    val _ = assertloc (length values = BIGNESS)
    val _ = assertloc (check_lst (i2sz BIGNESS, keys,
                                  numbers_in_order,
                                  i2sz BIGNESS))
    val _ = assertloc (check_lst (i2sz BIGNESS, values,
                                  numbers_in_order,
                                  i2sz BIGNESS))
    val _ = list_vt_freelin keys
    val _ = list_vt_freelin values
    //
    val pairs = s2s_map_pairs (map)
    val _ = assertloc (length pairs = BIGNESS)
    val _ = check_pairs (pairs, map)
    val _ = list_vt_freelin pairs
    //
    val- false = s2s_map_has_key (map, "nope")
    val- false = s2s_map_has_key (map, "inte")
    val- false = s2s_map_has_key (map, "nej")
    val- false = s2s_map_has_key (map, "ikke")
    val- false = s2s_map_has_key (map, "jamais")
    val- false = s2s_map_has_key (map, "minime")
    val- ~ None_vt () = s2s_map_get_opt (map, "nope")
    val- ~ None_vt () = s2s_map_get_opt (map, "inte")
    val- ~ None_vt () = s2s_map_get_opt (map, "nej")
    val- ~ None_vt () = s2s_map_get_opt (map, "ikke")
    val- ~ None_vt () = s2s_map_get_opt (map, "jamais")
    val- ~ None_vt () = s2s_map_get_opt (map, "minime")
    //
    val _ = free map

    val map1 = strnptrmap ()
    val map1 = fill_map (map1, numbers_permuted,
                         numbers_permuted, i2sz 0)
    val _ = assertloc (size map1 = i2sz BIGNESS)
    val _ = assertloc (not (iseqz map1))
    val _ = assertloc (isneqz map1)
    val _ =
      assertloc
        (compare_structure
          (map1, "tests/2021.10.31.13.19.39.structure",
           "tests/2021.10.31.13.19.39.structure.reference"))
    val map2 = strnptrmap ()
    val map2 = fill_map (map2, numbers_in_order,
                         numbers_in_order, i2sz 0)
    val _ = assertloc (size map2 = i2sz BIGNESS)
    val _ = assertloc (not (iseqz map2))
    val _ = assertloc (isneqz map2)
    val _ =
      assertloc
        (compare_structure
          (map2, "tests/2021.10.31.13.23.10.structure",
           "tests/2021.10.31.13.23.10.structure.reference"))
    val _ =
      (* Check that map1 and map2 have the same structure. *)
      assertloc
        ($extfcall
          (int, "system",
           "cmp -s tests/2021.10.31.13.19.39.structure tests/2021.10.31.13.23.10.structure")
              = 0)
    //
    val pairs = s2s_map_pairs (map1)
    val _ = assertloc (length pairs = BIGNESS)
    val _ = check_pairs (pairs, map1)
    val _ = list_vt_freelin pairs
    //
    val- false = s2s_map_has_key (map1, "nope")
    val- false = s2s_map_has_key (map1, "inte")
    val- false = s2s_map_has_key (map1, "nej")
    val- false = s2s_map_has_key (map1, "ikke")
    val- false = s2s_map_has_key (map1, "jamais")
    val- false = s2s_map_has_key (map1, "minime")
    val- ~ None_vt () = s2s_map_get_opt (map1, "nope")
    val- ~ None_vt () = s2s_map_get_opt (map1, "inte")
    val- ~ None_vt () = s2s_map_get_opt (map1, "nej")
    val- ~ None_vt () = s2s_map_get_opt (map1, "ikke")
    val- ~ None_vt () = s2s_map_get_opt (map1, "jamais")
    val- ~ None_vt () = s2s_map_get_opt (map1, "minime")
    //
    val pairs = s2s_map_pairs (map2)
    val _ = assertloc (length pairs = BIGNESS)
    val _ = check_pairs (pairs, map2)
    val _ = list_vt_freelin pairs
    //
    val- false = s2s_map_has_key (map2, "nope")
    val- false = s2s_map_has_key (map2, "inte")
    val- false = s2s_map_has_key (map2, "nej")
    val- false = s2s_map_has_key (map2, "ikke")
    val- false = s2s_map_has_key (map2, "jamais")
    val- false = s2s_map_has_key (map2, "minime")
    val- ~ None_vt () = s2s_map_get_opt (map2, "nope")
    val- ~ None_vt () = s2s_map_get_opt (map2, "inte")
    val- ~ None_vt () = s2s_map_get_opt (map2, "nej")
    val- ~ None_vt () = s2s_map_get_opt (map2, "ikke")
    val- ~ None_vt () = s2s_map_get_opt (map2, "jamais")
    val- ~ None_vt () = s2s_map_get_opt (map2, "minime")
    //
    var keys =
      let
        implement
        list_vt_mergesort$cmp<Strnptr1> (x, y) =
          compare_num ($UN.strnptr2string x,
                       $UN.strnptr2string y)
      in
        list_vt_mergesort<Strnptr1> (s2s_map_keys (map1))
      end
    var values =
      let
        implement
        list_vt_mergesort$cmp<Strnptr1> (x, y) =
          compare_num ($UN.strnptr2string x,
                       $UN.strnptr2string y)
      in
        list_vt_mergesort<Strnptr1> (s2s_map_values (map1))
      end
    val _ = assertloc (length keys = BIGNESS)
    val _ = assertloc (length values = BIGNESS)
    val _ = assertloc (check_lst (i2sz BIGNESS, keys,
                                  numbers_in_order,
                                  i2sz BIGNESS))
    val _ = assertloc (check_lst (i2sz BIGNESS, values,
                                  numbers_in_order,
                                  i2sz BIGNESS))
    val _ = list_vt_freelin keys
    val _ = list_vt_freelin values
    //
    var keys =
      let
        implement
        list_vt_mergesort$cmp<Strnptr1> (x, y) =
          compare_num ($UN.strnptr2string x,
                       $UN.strnptr2string y)
      in
        list_vt_mergesort<Strnptr1> (s2s_map_keys (map2))
      end
    var values =
      let
        implement
        list_vt_mergesort$cmp<Strnptr1> (x, y) =
          compare_num ($UN.strnptr2string x,
                       $UN.strnptr2string y)
      in
        list_vt_mergesort<Strnptr1> (s2s_map_values (map2))
      end
    val _ = assertloc (length keys = BIGNESS)
    val _ = assertloc (length values = BIGNESS)
    val _ = assertloc (check_lst (i2sz BIGNESS, keys,
                                  numbers_in_order,
                                  i2sz BIGNESS))
    val _ = assertloc (check_lst (i2sz BIGNESS, values,
                                  numbers_in_order,
                                  i2sz BIGNESS))
    val _ = list_vt_freelin keys
    val _ = list_vt_freelin values
    //
    val _ = free map1
    val _ = free map2
  }

fn
test3 () : void =
  {
    val _ = reset_rand_seed ()

    #define BIGNESS 1000

    var numbers_in_order : @[size_t][BIGNESS]
    val _ =
      let
        implement
        array_initize$init<size_t> (i, x) =
          x := succ i
      in
        array_initize<size_t> (numbers_in_order, i2sz BIGNESS)
      end

    fun
    fill_map {i         : int | i <= BIGNESS} .<BIGNESS - i>.
             (map       : strnptrmap_vt (Strnptr1),
              key_arr   : &(@[size_t][BIGNESS]) >> _,
              value_arr : &(@[size_t][BIGNESS]) >> _,
              i         : size_t i) :
        strnptrmap_vt (Strnptr1) =
      if i = i2sz BIGNESS then
        map
      else
        let
          prval _ = lemma_g1uint_param i
        in
          fill_map (s2s_map_set (map, size2strnptr (key_arr[i]),
                                 size2strnptr (value_arr[i])),
                    key_arr, value_arr, succ i)
        end

    val map = strnptrmap ()
    val map = fill_map (map, numbers_in_order,
                        numbers_in_order, i2sz 0)

    val _ =
      assertloc
        (compare_structure
          (map, "tests/2021.11.06.15.34.58.structure",
           "tests/2021.11.06.15.34.58.structure.reference"))

    fun
    diminish_map {i, n    : int | 0 <= n; i + n <= BIGNESS} .<n>.
                 (map     : strnptrmap_vt (Strnptr1),
                  key_arr : &(@[size_t][BIGNESS]) >> _,
                  i       : size_t i,
                  n       : size_t n) :
        strnptrmap_vt (Strnptr1) =
      if n = i2sz 0 then
        map
      else
        let
          prval _ = lemma_g1uint_param i
          val i_key = key_arr[i]
          val s_key = size2strnptr i_key
          val map =
            diminish_map (s2s_map_del (map, s_key), key_arr,
                          succ i, pred n)
          val _ = strnptr_free s_key
        in
          map
        end

    val map = diminish_map (map, numbers_in_order, i2sz 0, i2sz 1)

    val _ =
      assertloc
        (compare_structure
          (map, "tests/2021.11.06.15.34.59.structure",
           "tests/2021.11.06.15.34.59.structure.reference"))

    val map = diminish_map (map, numbers_in_order, i2sz 0, i2sz 10)

    val _ =
      assertloc
        (compare_structure
          (map, "tests/2021.11.06.15.55.46.structure",
           "tests/2021.11.06.15.55.46.structure.reference"))

    val map = diminish_map (map, numbers_in_order, i2sz 900, i2sz 90)

    val _ =
      assertloc
        (compare_structure
          (map, "tests/2021.11.06.15.55.47.structure",
           "tests/2021.11.06.15.55.47.structure.reference"))

    val map = diminish_map (map, numbers_in_order, i2sz 0, i2sz 990)

    val _ =
      assertloc
        (compare_structure
          (map, "tests/2021.11.06.15.55.48.structure",
           "tests/2021.11.06.15.55.48.structure.reference"))

    val _ = free map
  }

implement
main0 () =
  {
    val _ = test1 ()
    val _ = test2 ()
    val _ = test3 ()
  }
