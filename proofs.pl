:- dynamic
    open/1.

% space-saving macros for open/1
all_open(A,B):-open(A),open(B).
all_open(A,B,C):-open(A),open(B),open(C).
none_open(A,B):-not(open(A)),not(open(B)).
none_open(A,B,C):-not(open(A)),not(open(B)),not(open(C)).

% box_mark_open/1 (+List)
% marks the line numbers of each non-box entry in List as open
box_mark_open([Head|Tail]):-
    [LineNo, /*Statement*/_, /*Motivation*/_] = Head,
    !,
    assert(open(LineNo)),
    box_mark_open(Tail).

% skip boxes
box_mark_open([_|Tail]):-
    box_mark_open(Tail).

% end recursion
box_mark_open([]).

% box_mark_closed/1 (+List)
% marks the line numbers of each non-box entry in List as closed
box_mark_closed([Head|Tail]):-
    [LineNo, /*Statement*/_, /*Motivation*/_] = Head,
    !,
    retract(open(LineNo)),
    box_mark_closed(Tail).

% skip boxes
box_mark_closed([_|Tail]):-
    box_mark_closed(Tail).

% end recursion
box_mark_closed([]).

% maxbox/2 (+List, -Result)
% helper for lines_collect_info/4
% finds the greatest "box id" in a (potentially partial) list as
% computed by lines_collect_info/4
maxbox([[_,B,_]|Tail], Y):-
    maxbox(Tail, B1),
    (B1 > B -> Y = B1; Y = B).

maxbox([], 0).

% lines_collect_info/2 (+Proof, -Result)
% defers to lines_collect_info/4
% 
% given a proof tree, computes a flat list with elements of the form
% [linenumber, boxnumber, boxlinenumber]
%
% example: [[1,0,0], [[2,0,0]], [3,0,0]] -> [1,0,0],[2,1,0],[3,0,1]
lines_collect_info(Proof, Result):-
    lines_collect_info(Proof, 0, 0, 0, Result).

% lines_collect_info/4, see lines_collect_info/2
lines_collect_info([[Head|_]|Tail], BoxLevel, BoxCount, N, [[Head,BoxLevel,N]|More]):-
    not(is_list(Head)),
    !,
    Next is N + 1,
    lines_collect_info(Tail, BoxLevel, BoxCount, Next, More).

lines_collect_info([Head|Tail], BoxLevel, BoxCount, N, More):-
    NewLevel is BoxCount + 1,
    lines_collect_info(Head, NewLevel, NewLevel, 0, More1),
    maxbox(More1, NewCount),
    lines_collect_info(Tail, BoxLevel, NewCount, N, More2),
    append(More1, More2, More).

lines_collect_info([], /*BoxLevel*/_, /*BoxCount*/_, /*N*/_, []).

% line_in_box/3 (+Proof, +LineNo, ?Box)
% 
% given a proof tree and a linenumber, determine whether or not
% the linenumber is contained within a certain box
line_in_box(Proof, LineNo, Box):-
    lines_collect_info(Proof, Lines),
    member(Line, Lines),
    Line = [LineNo, Box, /*Nth*/_].

% linenumbers/2 (+Proof, -Result)
%
% given a proof tree, computes a list of all the line numbers
% that appear in the tree
linenumbers([[Head|_]|Tail], [Head|More]):-
    not(is_list(Head)),
    !,
    linenumbers(Tail, More).

linenumbers([Head|Tail], More):-
    linenumbers(Head, More1),
    linenumbers(Tail, More2),
    append(More1, More2, More).

linenumbers([], []).

% increasing/1 (+List)
%
% true if the items in the list are (non-strictly) increasing
increasing([A,B|Tail]):-
    A =< B,
    increasing(Tail).

increasing([_|[]]).
increasing([]).

% lines_find_info/3 (+List, +LineNo, -Result)
% helper for line_get_info/3. extracts the data for a single line
% number from a list as computed by lines_collect_info/4.

% found the line
lines_find_info([[LineNo, BoxNo, BoxNth]|_], LineNo, [LineNo, BoxNo, BoxNth]).

% skip to next
lines_find_info([_|Tail], LineNo, Result):-
    lines_find_info(Tail, LineNo, Result).

% line_get_info/3 (+Proof, +LineNo, -Result)
% extracts the data for a given line number in a given proof.
line_get_info(Proof, LineNo, Result):-
    lines_collect_info(Proof, Lines),
    lines_find_info(Lines, LineNo, Result).

% box_max_line/3 (+Proof, +Box, -Result)
% finds the largest line number contained in a given "box id"
box_max_line(Proof, Box, Result):-
    lines_collect_info(Proof, Lines),
    box_max_line(Lines, Box, 0, Result),!.

% box_max_line/4 (+List, +Box, ?Max, -Result)
% given a list as computed by lines_collect_info/4, finds the
% largest line number contained in a given "box id"

% in requested box, update result
box_max_line([Head|Tail], Box, Max, Result):-
    [LineNo, Box, _] = Head,
    (integer(Max) -> NewMax is max(LineNo, Max); NewMax is LineNo),
    box_max_line(Tail, Box, NewMax, Result),!.

% in some other box, skip and keep going
box_max_line([_|Tail], Box, Max, Result):-
    box_max_line(Tail, Box, Max, Result),!.

% end of recursion
box_max_line([], _, Max, Max).

% box_min_line/3 (+Proof, +Box, -Result)
% finds the smallest line number contained in a given "box id"
box_min_line(Proof, Box, Result):-
    lines_collect_info(Proof, Lines),
    box_min_line(Lines, Box, 9999999999999, Result),!.

% box_min_line/4 (+List, +Box, ?Min, -Result)
% given a list as computed by lines_collect_info/4, finds the
% smallest line number contained in a given "box id"

% in requested box, update result
box_min_line([Head|Tail], Box, Min, Result):-
    [LineNo, Box, _] = Head,
    (integer(Min) -> NewMin is min(LineNo, Min); NewMin is LineNo),
    box_min_line(Tail, Box, NewMin, Result),!.

% in some other box, skip and keep going
box_min_line([_|Tail], Box, Min, Result):-
    box_min_line(Tail, Box, Min, Result),!.

% end of recursion
box_min_line([], _, Min, Min).

% line_opens_box/2 (+Proof, +LineNo)
% true if a given line number opens a box in a given proof
line_opens_box(Proof, LineNo):-
    line_get_info(Proof, LineNo, Info),
    [LineNo, Box, 0] = Info,
    Box > 0.

% line_closes_box/2 (+Proof, +LineNo)
% true if a given line closes a box in a given proof
line_closes_box(Proof, LineNo):-
    lines_collect_info(Proof, Lines),
    line_get_info(Proof, LineNo, Info),
    [LineNo, Box, _] = Info,
    Box > 0,
    box_max_line(Lines, Box, LineNo).

% lines_delimit_box/3 (+Proof, +Line1, +Line2)
% true if two given lines are the starting and ending lines of
% some box in a given proof
lines_delimit_box(Proof, Line1, Line2):-
    line_get_info(Proof, Line1, Info1),
    line_get_info(Proof, Line2, /*Info2*/_),
    [Line1, Box, 0] = Info1,
    box_max_line(Proof, Box, Line2).

% first_opened_box_in_box/3 (+List, +OwnBox, -BoxNo)
% given a list as computed by lines_collect_info/4, finds the
% "box id" of the first box that is opened inside a given "box id"
% todo: is this broken? how about boxes containing no boxes?

% skip items at start of list until finding a box id larger than
% the requested box id
first_opened_box_in_box([[/*LineNo*/_, BoxNr, /*BoxLineNr*/_]|Tail], OwnBox, BoxNo):-
    BoxNr =< OwnBox,
    !,
    first_opened_box_in_box(Tail, OwnBox, BoxNo).

% first variant of predicate failed, so we found what we're looking for
first_opened_box_in_box([[_, BoxNr, _]|/*Tail*/_], _, BoxNr).

% most_recently_closed_box/3 (+Proof, +LineNo, -BoxNo)
% given a proof and a line number, finds which "box id" was most
% recently closed prior to the appearance of the given line number
most_recently_closed_box(Proof, LineNo, BoxNo):-
    line_in_box(Proof, LineNo, OwnBox),
    lines_collect_info(Proof, Lines),
    first_opened_box_in_box(Lines, OwnBox, BoxNo).

% proof_nth_line/3 (+Proof, +N, -Line)
% given a proof and a line number N, finds the data for the
% item with line number N if it exists

% found it
proof_nth_line([Head|_], N, Line):-
    [N, Statement, Motivation] = Head,
    !,
    Line = [N, Statement, Motivation].

% found a box, dig deeper
proof_nth_line([Head|_], N, Line):-
    Head = X,
    proof_nth_line(X, N, Line).

% keep going
proof_nth_line([_|Tail], N, Line):-
    proof_nth_line(Tail, N, Line).

% proof_nth_statement/3 (+Proof, +N, -Statement)
% given a proof and a line number N, finds the statement part
% of the item with line number N if it exists
proof_nth_statement(Proof, N, Statement):-
    proof_nth_line(Proof, N, LineN),
    [_, Statement, _] = LineN.
