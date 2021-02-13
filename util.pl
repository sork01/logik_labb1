puts([nl|Tail]):-
    nl, !, puts(Tail).

puts([Head|Tail]):-
    write(Head), puts(Tail).

puts([]).

putsn(List):-
    append(List, [nl], NewList),
    puts(NewList).
