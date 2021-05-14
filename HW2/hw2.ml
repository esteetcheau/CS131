type ('nonterminal, 'terminal) symbol =
    | N of 'nonterminal
    | T of 'terminal
    
type ('nonterminal, 'terminal) parse_tree =
  | Node of 'nonterminal * ('nonterminal, 'terminal) parse_tree list
  | Leaf of 'terminal


let rec convert rules nt = match rules with
    | [] -> []
    | head::tail -> if (fst head) = nt
                    then (snd head)::(convert tail nt) else convert tail nt

(*PROBLEM 1*)
let convert_grammar gram1 = ((fst gram1), convert (snd gram1))


(*This helper function cuts the root from the tree to make subtrees*)
(*traverses the parse tree left to right and yields a list of the leaves encountered.*)

let rec tree_function tree = match tree with
    | [] -> []
    | head::tail -> match head with
                    | Leaf leaf -> leaf::(tree_function tail)
                    | Node (_, subtree) -> tree_function subtree @ tree_function tail
(*PROBLEM 2*)

let parse_tree_leaves tree = tree_function [tree]


(*PROBLEM 3*)
let rec make_matcher_rules func list_rules accept frag = match list_rules with
    | [] -> None
    | head::tail -> let i = match_rule func head accept frag in
       match i with
       | None -> make_matcher_rules func tail accept frag
       | _    -> i
and match_rule func rules accept frag = match rules with
  | [] -> accept frag
  | head1::tail1 -> match head1 with
  		 |N symbol ->
  		 		let new_rules = func symbol in
     			let new_accept = match_rule func tail1 accept in
     			make_matcher_rules func new_rules new_accept frag
     	 |T symbol -> match frag with
     	 		|[] -> None
     	 		|head2::tail2 -> if head2 = symbol then match_rule func tail1 accept tail2
     	 		else None
  
let make_matcher gram = make_matcher_rules (snd gram) ((snd gram) (fst gram));;

(*Problem 4 *)

let rec start_rules nt func2 list_rules accept accept2 frag = match list_rules with
   | [] -> None
   | head::tail -> let i = parse_rules func2 head accept ((nt, head)::accept2) frag in
      match i with
        | None -> start_rules nt func2 tail accept accept2 frag
        | _ -> i
and parse_rules func2 rules accept accept2 frag= match rules with
    | [] -> accept accept2 frag
    | head1::tail1 -> match frag with
             | [] -> None
             | head2::tail2 -> match head1 with
                      | N symbol ->
                         let new_rules = func2 symbol in
                         let new_accept = parse_rules func2 tail1 accept in
                         start_rules symbol func2 new_rules new_accept accept2 frag
                      | T symbol -> if head2 = symbol then parse_rules func2 tail1 accept accept2 tail2
                      else None

(*This creates the parse tree*)
let tree path frag = let paths = path frag in
	match paths with
	|Some i ->
		let route = List.rev i in
		let rec make_tree paths = match paths with
		| [] -> 
		let a = fst (List.hd paths)in
       	let c = child paths [] in
       	let d = fst c in
       	let e = snd c in
       	d, Node (a,e)
    	| head::tail ->
      	let a = fst head in
       	let b = snd head in
       	let c = child tail b in
       	let d = fst c in
       	let e = snd c in
       	d, Node (a,e)
		and child d b = match b with
		  | [] -> d, []
		  | head::tail -> (match head with
							| N symbol ->
							   let t = make_tree d in
							   let u = fst t in
							   let v = snd t in
							   let w = child u tail in
							   let x = fst w in
							   let y = snd w in
							   x, v::y
							| T symbol ->
							   let i = child d tail in
							   let u = fst i in
							   let y = snd i in
							   u, (Leaf symbol)::y) in
			Some (snd (make_tree route))
	  |_ -> None
				
 (*This is a parse accepter*)				
let accept3 path frag = match frag with
	|[] -> Some path
	|_ -> None
			
				
let make_parser gram = 
	let path = start_rules (fst gram) (snd gram) ((snd gram) (fst gram)) accept3 [] in
	tree path
	

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  