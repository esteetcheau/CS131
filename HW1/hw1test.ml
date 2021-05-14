let subset_test0 = subset [1] [1;2;3]
let subset_test1 = subset [3;4;3] [1;2;3]
let subset_test2 = not (subset [1;1;3] [4;1;3])
let subset_test3 = subset [] [1;3]
let subset_test4 = subset [3;8] [1;2;3;5;4;3]

let equal_sets_test0 = equal_sets [5;3] [3;5;3;5]
let equal_sets_test1 = not (equal_sets [1;3;1;1;1] [3;1;3])
let equal_sets_test2 = equal_sets [] []
let equal_sets_test3 = equal_sets [1;2;3] [3;2;1]


let set_union_test0 = equal_sets (set_union [] [1;2;3]) [1;2;3]
let set_union_test1 = equal_sets (set_union [3;1;3] [1;2;3]) [1;2;3]
let set_union_test2 = equal_sets (set_union [1;2] [3;4]) [3;4;2;1;3;3;4]
let set_union_test3 = equal_sets (set_union [1] [2]) []
let set_union_test4 = equal_sets (set_union [] [2;2;2]) [2]
let set_union_test5 = equal_sets (set_union [5;6] [6]) [6]


let set_all_union_test0 =
  equal_sets (set_all_union []) []
let set_all_union_test1 =
  equal_sets (set_all_union [[3;1]; [4]; [5;6]; [1;2;3]]) [1;2;3;4]
let set_all_union_test2 =
  equal_sets (set_all_union [[5;2]; []; [5;2]; [3;5;7]]) [2;3;5]
let set_all_union_test3 =
  equal_sets (set_all_union [[1;2]; [5;2]; [3;4;1;2;1]]) [1;2;3;4;5]

let computed_fixed_point_test0 =
  computed_fixed_point (=) (fun x -> x / 2) 100 = 0
let computed_fixed_point_test1 =
  computed_fixed_point (=) (fun x -> x *. 2.) 2. = infinity
let computed_fixed_point_test2 =
  computed_fixed_point (=) sqrt 100. = 1.
  let computed_fixed_point_test2 =
  computed_fixed_point (=) (fun x -> x / 10) 100 = 0
let computed_fixed_point_test3 =
  ((computed_fixed_point (fun x y -> abs_float (x -. y) < 1.)
			 (fun x -> x /. 2.)
			 10.)
   = 1.25)


type my_nonterminals =
  | HI | I | NEED | AN | A

let my_rules =
   [HI, [T"("; N HI; T")"];
    HI, [N A];
    HI, [N HI; N NEED; N ];
    HI, [N I];
    HI, [N NEED; N AN];
    I, [T"bye"; N HI];
    I, [T"++"];
    NEED, [T"--"];
    NEED, [T"+"];
    NEED, [T"-"];
    AN, [T"0"];
    AN, [T"1"];
    AN, [T"2"];
    AN, [T"3"];
    A, [T"4"];
    A, [T"5"];
    A, [T"6"];
    A, [T"7"];
    A, [T"8"];
    A, [T"9"]]

let my_grammar = HI, my_rules

let my_test0 =
  filter_reachable my_grammar = my_grammar

let my_test1 =
  filter_reachable (HI, List.tl my_rules) = (HI, List.tl my_rules)

let my_test2 =
  filter_reachable (I, my_rules) = (I, my_rules)

let my_test3 =
  filter_reachable (HI, List.tl (List.tl my_rules)) =
    (HI,
     [HI, [N HI; N AN; N HI];
      HI, [N I];
      HI, [N NEED; N I];
      HI, [N I; N NEED];
      I, [T "$"; N HI];
      NEED, [T "++"];
      NEED, [T "--"];
      NEED, [T "+"];
      NEED, [T "-+"]])

let my_test4 = filter_reachable my_grammar

type more_nonterminals =
  | Conversation | Sentence | Grunt | Snore | Shout | Quiet | Bunny | Bubble

let more_grammar =
  Conversation,
  [Snore, [T"ZZZ"];
   Quiet, [];
   Grunt, [T"khrgh"];
   Shout, [T"aooogah!"];
   Sentence, [N Quiet];
   Bubble, [T"Hi"];
   Bubble, [T"ImANonterminal"];
   Sentence, [N Grunt];
   Sentence, [N Shout];
   Conversation, [N Snore];
   Conversation, [N Sentence; T","; N Conversation];
   Bunny, [T"Illegal"];
   Bubble, [T"cs131IsHard"]]
   

let more_test0 =
  filter_reachable more_grammar = more_grammar

let more_test1 =
  filter_reachable (Sentence, List.tl (snd more_grammar)) =
    (Sentence,
     [Quiet, []; Grunt, [T "khrgh"]; Shout, [T "aooogah!"];
      Sentence, [N Quiet]; Sentence, [N Grunt]; Sentence, [N Shout]])

let more_test2 =
  filter_reachable (Quiet, snd more_grammar) = (Quiet, [Quiet, []])

let more_test3 = filter_reachable more_grammar