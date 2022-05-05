:- dynamic clause/1.

:- op( 100, fy, ~ ).
:- op( 110, xfy, & ).
:- op( 120, xfy, v ).
:- op( 130, xfy, => ).

translate( F & G ) :- !,
    translate( F ),
    translate( G ).

translate(Formula) :-
    transform( Formula, NewFormula), !,
    translate( NewFormula).

translate(Formula) :-
    to_list( Formula, ListFormula),
    msort(ListFormula, SortedFormula),
    list_to_set( SortedFormula, Clauses ),
    simplify_clause( Clauses, SimplifiedClauses ),
    assert( clause( SimplifiedClauses) ).



% Simplifing
transform(X v X, X) :- !.

% Eliminating double negations

transform( ~(~X), X) :- !.

% Eliminating implications

transform( X => Y, ~X v Y) :- !.

% de Morgan

transform( ~( X & Y), ~X v ~Y) :- !.
transform( ~( X v Y), ~X & ~Y) :- !. 

% Distribution

transform( X & Y v Z, (X v Z) & ( Y v Z)) :- !.
transform( X v Y & Z, ( X v Y) & ( X v Z)) :- !.

% transforming sub-expressions:

transform( X v Y, X1 v Y) :- 
    transform( X, X1), !.

transform( X v Y, X v Y1):-
    transform( Y, Y1), !.

transform( ~X, ~X1) :-
    transform( X, X1).

% Transforming formula to List
to_list(X v Y, List) :- to_list(X, ListX), to_list(Y, ListY), append(ListX, ListY, List).
to_list(X, [X]).

%Simplifing clauses
simplify_clause([X|Clause], NewClause) :-
    =(X, ~Y),
    member(Y, Clause),
    delete([X|Clause], ~Y, NewList),
    delete(NewList, Y, ClauseDelete),
    simplify_clause(ClauseDelete, NewClause).

simplify_clause([X|Clause], NewClause) :-
    member(~X, Clause),
    delete([X|Clause], ~X, NewList),
    delete(NewList, X, ClauseDelete), 
    simplify_clause(ClauseDelete, NewClause).

simplify_clause([X|Clause], NewClause) :- verify_all([X|Clause], [X|Clause], NewClause).

simplify_clause([], []).


verify_all([Head|Clause], List, NewList) :- not(member(~Head, List)), verify_all(Clause, List, NewList).
verify_all([Head|Clause], List, Result) :- 
    member(~Head, List), 
    delete(List, ~Head, NewList), 
    delete(NewList, Head, DeletedList),
    verify_all(Clause, DeletedList, Result).

verify_all([], List, List).


%calculating resolver
resolve(C1, C2, Result) :- 
    union(C1, C2, C3),
    simplify_clause(C3, Result),
    not(empty(Result)),
    assert(clause(Result)).

resolve(C1, C2, Result) :- 
    union(C1, C2, C3),
    simplify_clause(C3, Result),
    empty(Result),
    assert(clause([])),
    print_proof,
    writeln("Formula Insatisfativel"),
    abort.



% strategy for resolution depth first search
depth_resolution([[HeadTerm|Terms]|Clauses], [HeadCopyClause|CopyClauses]) :- 
    =(HeadTerm, ~Y),
    member(Y, HeadCopyClause),
    resolve([HeadTerm|Terms], HeadCopyClause, CreatedClause),
    depth_resolution([CreatedClause|Clauses], [HeadCopyClause|CopyClauses]).

depth_resolution([[HeadTerm|Terms]|Clauses], [HeadCopyClause|CopyClauses]) :- 
    member(~HeadTerm, HeadCopyClause),
    resolve([HeadTerm|Terms], HeadCopyClause, CreatedClause),
    depth_resolution([CreatedClause|Clauses], [HeadCopyClause|CopyClauses]).

depth_resolution([[HeadTerm|Terms]|Clauses], [_|CopyClauses]) :- 
    depth_resolution([[HeadTerm|Terms]|Clauses], CopyClauses).

depth_resolution([[_|Terms]|Clauses], [HeadCopyClause|CopyClauses]) :-
    head(Terms, NewTerm),
    not(empty(NewTerm)),
    tail(Terms, NewTerms),
    depth_resolution([[NewTerm|NewTerms]|Clauses], [HeadCopyClause|CopyClauses]).

depth_resolution([_|Clauses], [HeadCopyClause|CopyClauses]) :- 
    head(Clauses, NewClause),
    not(empty(NewClause)),
    tail(Clauses, NewClauses),
    depth_resolution([NewClause|NewClauses], [HeadCopyClause|CopyClauses]).

depth_resolution(_, _) :- writeln("Formula Satisfativel").


% print proof
print_proof :- 
    writeln("========PROVA========"), 
    foreach(clause(Clause), print_clause(Clause)),
    writeln("======RESULTADO======").

print_clause(Clause) :- writeln(Clause).


%resolution
solve(Formula) :-
    retractall(clause(_)),
    translate(~Formula),
    setof(Clause, clause(Clause), Clauses),
    depth_resolution(Clauses, Clauses).



/*TODO -> Do the enumeration of each clause and put in the database and on proof*/


%utility predicates
head([Head|_], Head).
head([], []).

tail([_|Tail], Tail).
tail([], []).

empty([]).
empty(_) :- false.