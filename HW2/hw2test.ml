let accept_all string = Some string
let accept_empty_suffix = function
   | _::_ -> None
   | x -> Some x


type words_nonterminals =
  | This | Class | Is | So | Very | Hard

let words_grammar =
  (This,
	 [Class, [T"AAA"];
	 Is, [T"CCC"];
	 Very, [T"BBB"];
	 So, [];
	 Hard, [N So];
	 Hard, [N Very];
	 Hard, [N Is];
	 This, [N Class];
	 This, [N Hard; T"DDD"; N This]])


let this_grammar = convert_grammar words_grammar
let frag = (["CCC"; "DDD"; "CCC"; "DDD"; "AAA"])

(*We expect the next two boolean values to return true*)
let make_matcher_test =
  ((make_matcher this_grammar accept_all frag)= Some [])

let make_parser_test =
  ((make_parser this_grammar frag) = Some
   (Node (This,
     [Node (Hard, [Node (Is, [Leaf "CCC"])]); Leaf "DDD";
      Node (This,
       [Node (Hard, [Node (Is, [Leaf "CCC"])]); Leaf "DDD";
        Node (This, [Node (Class, [Leaf "AAA"])])])])))
