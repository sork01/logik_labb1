:- dynamic
    open/1.

box_mark_open([Head|Tail]):-
    [LineNo, /*Statement*/_, /*Motivation*/_] = Head,
    !,
    assert(open(LineNo)),
    box_mark_open(Tail).

box_mark_open([_|Tail]):-
    box_mark_open(Tail).

box_mark_open([]).

box_mark_closed([Head|Tail]):-
    [LineNo, /*Statement*/_, /*Motivation*/_] = Head,
    !,
    retract(open(LineNo)),
    box_mark_closed(Tail).

box_mark_closed([_|Tail]):-
    box_mark_closed(Tail).

box_mark_closed([]).

% main:-
    % see('tests/valid02.txt'),
    % read(Premises),
    % read(Conclusion),
    % read(Proof),
    % box_mark_open(Proof),
    % box_mark_closed(Proof),
    % findall(X,(open(X)),L),
    % write(L).
