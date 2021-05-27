kenken(N,C,T) :- set(N,A), board(N,T,A), fd_setter(T,N), result(C,T), fd_different(T), 
		 transpose(T,X), fd_label(T), fd_different(X).

set(N,N).
transpose([],[]).
transpose([[Head|Tail1] |Tail2], [[Head|Tail3] |Tail4]) :- 
    rowcol(Tail2, Tail3, X), transpose(X,Y), 
    rowcol(Tail4, Tail1, Y).

rowcol([],[],[]).
rowcol([[Head|Tail1]|Tail2],[Head|Column],[Tail1|Row]) :- 
    rowcol(Tail2,Column,Row).
fd_label([]).
fd_label([Head|Tail]) :- fd_labeling(Head), fd_label(Tail).

fd_setter([],_).
fd_setter([Head|Tail],N) :- fd_domain(Head,1,N), fd_setter(Tail,N).

fd_different([]).
fd_different([Head|Tail]) :- fd_all_different(Head), fd_different(Tail).


get(T,[R|C],X) :- nth(R,T,L1), nth(C,L1,X).

add(0,[],_).
add(Value,[Head|Tail],T) :- get(T,Head,X), Value #= X+Val, 
			  add(Val,Tail,T).
			  
-(Value,R,L,T) :- get(T,R,X), get(T,L,Y), 
		(X-Y #= Value ; Y-X #= Value).
		
multiply(1,[],_).
multiply(Value,[Head|Tail],T) :- get(T,Head,X), Value #= X*Val, 
			   multiply(Val,Tail,T).

/(Value,R,L,T) :- get(T,R,X), get(T,L,Y), 
		(X/Y #= Value ; Y/X #= Value).

result([],T).
result([Value+List|Tail],T) :- add(Value,List,T), result(Tail,T).
result([-(Value,C1,C2)|Tail],T) :- -(Value,C1,C2,T), result(Tail,T).
result([Value*List|Tail],T) :- multiply(Value,List,T), result(Tail,T).
result([/(Value,C1,C2)|Tail],T) :- /(Value,C1,C2,T), result(Tail,T).

board(_,[],0).
board(N,T,C) :- findall(L,length(L,N),Y),succ(X,C),
		   board(N,B,X),append(Y,B,T).
		   

plain_kenken(N,C,T) :- set(N,A), board(N,T,A), 
		       list(N,L), maplist(permutation(L),T), 
		       transpose(T,X), wrap(X), plain_result(C,T).

wrap([]).
wrap([Head|Tail]) :- crow(Head), wrap(Tail).

crow([]).
crow(List) :- sort(List,N), length(List,L), length(N,X), L#=X.

list(N,T) :- findall(X,between(1,N,X),T).


plain_add(0,[],_).
plain_add(Value,[Head|Tail],T) :- get(T,Head,X), Val is Value-X, 
			    plain_add(Val,Tail,T).
			    
plain_subtract(Value,R,L,T) :- get(T,R,X), get(T,L,Y), 
		    (Value is X-Y ; Value is Y-X).
		    
plain_multiply(1,[],_).
plain_multiply(Value,[Head|Tail],T) :- get(T,Head,X), Val is Value div X, 
			     plain_multiply(Val,Tail,T).
	
plain_divide(Value,R,L,T) :- get(T,R,X), get(T,L,Y), 
		    (Value is X div Y ; Value is Y div X).

plain_result([],T).
plain_result([Value+List|Tail],T) :- plain_add(Value,List,T), plain_result(Tail,T).
plain_result([-(Value,C1,C2)|Tail],T) :- plain_subtract(Value,C1,C2,T), plain_result(Tail,T).
plain_result([Value*List|Tail],T) :- plain_multiply(Value,List,T), plain_result(Tail,T).
plain_result([/(Value,C1,C2)|Tail],T) :- plain_divide(Value,C1,C2,T), plain_result(Tail,T).

board(_,[],0).
board(N,T,C) :- findall(L,length(L,N),Y),succ(X,C),
		   board(N,B,X),append(Y,B,T).


kenken_testcase(
  9,
  [
   *(280, [[1|1], [1|2], [1|3]]),
   +(9, [[1|4], [1|5], [1|6]]),
   /(6, [[1|7], [1|8]]),
   +(14, [[2|1], [2|2], [3|1]]),
   *(28, [[2|3], [3|3], [3|4]]),
   +(18, [[3|4], [3|5], [4|5]),
   *(60, [[2|6], [2|7], [2|8], [3|8]]),
   +(3, [[3|2]]),
   -(2, [[4|1], [5|1]]),
   +(4, [[4|2], [4|3]]),
   *(96, [[4|4], [4|5], [4|6]]),
   +(11, [[4|7], [4|8]]),
   /(3, [[5|2], [6|2]]),
   *(32, [[5|3], [6|3]]),
   +(12, [5|4], [6|4]),
   /(7, [[5|5], [6|5]]),
   -(1, [5|6], [6|6]),
   *(15, [[5|7], [6|7]]),
   -(2, [5|8], [6|8]),
   +(14, [[6|1], [6|2], [6|3]]),
   *(120, [[7|2], [7|3], [8|2]]),
   +(14, [[7|4], [7|5], [7|6]]),
   *(84, [7|7], [7|8], [8|8]),
   -(4, [8|3], [8|4]),
   *(21, [[8|5], [8|6], [8|7]])
  ]
).







