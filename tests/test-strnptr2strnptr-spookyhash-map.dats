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
      compare ($UN.strnptr2string (x.1),
               $UN.strnptr2string (y.1))
    else
      i
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

fn
test1 () : void =
  {
    val foo2 = string0_copy "foo2"
    val bar2 = string0_copy "bar2"
    val foo3 = string1_copy "foo3"
    val bar3 = string1_copy "bar3"

    val map = strnptrmap ()
    val map = s2s_map_set (map, "foo1", "bar1")
    val map = s2s_map_set (map, foo2, bar2)
    val map = s2s_map_set (map, foo3, bar3)

    val foo2 = string0_copy "foo2"
    val bar2 = string0_copy "bar2"
    val foo3 = string1_copy "foo3"
    val bar3 = string1_copy "bar3"

    val- ~ Some_vt x = s2s_map_get_opt (map, "foo1")
    val _ = assertloc ($UN.strnptr2string x = "bar1")
    val _ = free x

    val- ~ Some_vt x = s2s_map_get_opt (map, foo2)
    val _ = assertloc ($UN.strnptr2string x = $UN.strptr2string bar2)
    val _ = free x

    val- ~ Some_vt x = s2s_map_get_opt (map, "foo2")
    val _ = assertloc ($UN.strnptr2string x = $UN.strptr2string bar2)
    val _ = free x

    val- ~ Some_vt x = s2s_map_get_opt (map, foo3)
    val _ = assertloc ($UN.strnptr2string x = $UN.strnptr2string bar3)
    val _ = free x

    val- ~ Some_vt x = s2s_map_get_opt (map, "foo3")
    val _ = assertloc ($UN.strnptr2string x = $UN.strnptr2string bar3)
    val _ = free x

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

    val _ = free foo2
    val _ = free bar2
    val _ = free foo3
    val _ = free bar3

    val _ =
      assertloc
        (compare_structure
          (map, "tests/2021.10.31.10.54.20.structure",
           "tests/2021.10.31.10.54.20.structure.reference"))

    val _ = free map
  }

implement
main0 () =
  {
    val _ = test1 ()
  }
