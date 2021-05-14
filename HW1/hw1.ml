let rec subset a b = match a, b with
	| [], _ -> true
	| _, [] -> false
	| [a], [b] -> if a == b then true else false
	| head1::tail1, head2::tail2 -> if (if head1 = head2 then true else subset [head1] tail2) then subset tail1 b else false;; 
	
	

let equal_sets a b = subset a b && subset b a;;


let rec inside c d = match d with
| [] -> false
| head::tail -> if head = c then true else (inside c tail);;



let rec set_union a b = match a with
| [] -> b
| head::tail -> if (inside head b) then (set_union tail b) else head::(set_union tail b);;


let rec set_all_union a = match a with
| [] -> []
| head::tail -> set_union (set_all_union tail) (head);;



let rec computed_fixed_point eq f x = if (eq (f x) x) 
then x else (computed_fixed_point eq f (f x));; 



type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal;;

(*this gets the rules for nonterminals*)
let rec nonterminals nt = match nt with
    | [] -> []
    | T head::tail -> nonterminals tail
    | N head::tail -> head::(nonterminals tail);;


(*takes in a list of expressions and the rules for nonterminals
set1 is a temporary set and set2 is the final set*)
let rec current_reachable ex nt = match nt with
    | [] -> ex
    | head::tail -> if List.mem (fst head) ex then
                      let set1 = nonterminals(snd head) in
                      let set2 = set_union set1 ex in current_reachable set2 tail
                    else current_reachable ex tail;;

let lists ex nt =
    computed_fixed_point equal_sets (fun list -> current_reachable list nt) ex;;

let unreachable expression nt =
  let reachable = lists [expression] nt in
  List.filter (fun a -> (List.mem (fst a) reachable)) nt;;

let filter_reachable g =
  let expression = fst g in
  let nt      = snd g in
  (expression, unreachable expression nt);;





