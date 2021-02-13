% maxbox/2, (+List, -Result)
% helper for lines_collect_info/4
maxbox([[_,B,_]|Tail], Y):-
    maxbox(Tail, B1),
    (B1 > B -> Y = B1; Y = B).

maxbox([], 0).

% lines_collect_info/2, (+Proof, -Result)
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

% line_in_box/3, (+Proof, +LineNo, ?Box)
% 
% given a proof tree and a linenumber, determine whether or not
% the linenumber is contained within a certain box
line_in_box(Proof, LineNo, Box):-
    lines_collect_info(Proof, Lines),
    member(Line, Lines),
    Line = [LineNo, Box, /*Nth*/_].

% linenumbers/2, (+Proof, -Result)
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

% increasing/1, (+List)
%
% true if the items in the list are (non-strictly) increasing
increasing([A,B|Tail]):-
    A =< B,
    increasing(Tail).

increasing([_|[]]).
increasing([]).

% lines_find_info/3
lines_find_info([[LineNo, BoxNo, BoxNth]|_], LineNo, [LineNo, BoxNo, BoxNth]).

lines_find_info([_|Tail], LineNo, Result):-
    lines_find_info(Tail, LineNo, Result).

line_get_info(Proof, LineNo, Result):-
    lines_collect_info(Proof, Lines),
    lines_find_info(Lines, LineNo, Result).

box_max_line(Proof, Box, Result):-
    lines_collect_info(Proof, Lines),
    box_max_line(Lines, Box, 0, Result),!.

box_max_line([Head|Tail], Box, Max, Result):-
    [LineNo, Box, _] = Head,
    (integer(Max) -> NewMax is max(LineNo, Max); NewMax is LineNo),
    box_max_line(Tail, Box, NewMax, Result),!.

box_max_line([_|Tail], Box, Max, Result):-
    box_max_line(Tail, Box, Max, Result),!.

box_max_line([], _, Max, Max).

box_min_line(Proof, Box, Result):-
    lines_collect_info(Proof, Lines),
    box_min_line(Lines, Box, 9999999999999, Result),!.

box_min_line([Head|Tail], Box, Min, Result):-
    [LineNo, Box, _] = Head,
    (integer(Min) -> NewMin is min(LineNo, Min); NewMin is LineNo),
    box_min_line(Tail, Box, NewMin, Result),!.

box_min_line([_|Tail], Box, Min, Result):-
    box_min_line(Tail, Box, Min, Result),!.

box_min_line([], _, Min, Min).

line_opens_box(Proof, LineNo):-
    line_get_info(Proof, LineNo, Info),
    [LineNo, Box, 0] = Info,
    Box > 0.

line_closes_box(Proof, LineNo):-
    lines_collect_info(Proof, Lines),
    line_get_info(Proof, LineNo, Info),
    [LineNo, Box, _] = Info,
    Box > 0,
    box_max_line(Lines, Box, LineNo).

lines_delimit_box(Proof, Line1, Line2):-
    line_get_info(Proof, Line1, Info1),
    line_get_info(Proof, Line2, Info2),
    [Line1, Box, 0] = Info1,
    box_max_line(Proof, Box, Line2).

first_opened_box_in_box([[LineNo, BoxNr, BoxLineNr]|Tail], OwnBox, BoxNo):-
    BoxNr =< OwnBox,
    !,
    foo(Tail, OwnBox, BoxNo).

first_opened_box_in_box([[_, BoxNr, _]|Tail], _, BoxNr).

most_recently_closed_box(Proof, LineNo, BoxNo):-
    line_in_box(Proof, LineNo, OwnBox),
    lines_collect_info(Proof, Lines),
    first_opened_box_in_box(Lines, OwnBox, BoxNo).

% main:-
    % consult('util.pl'),
    % L=[
        % [1,0,0],
        % [2,0,0],
        % [
            % [3,0,0],
            % [
                % [4,0,0],
                % [5,0,0],
                % [
                    % [6,0,0]
                % ]
            % ],
            % [7,0,0]
        % ],
        % [8,0,0],
        % [
            % [9,0,0]
        % ],
        % [
            % [10,0,0]
        % ]
    % ],
    % most_recently_closed_box(L, 7, Result),
    % write(Result).



% main:-
    % see('tests/valid20.txt'),
    % read(Premises),
    % read(Conclusion),
    % read(Proof),
    % vilken är sista stängda boxen, vilken är dess sista rad
    % most_recently_closed_box(Proof, 4, BoxNo),
    % box_min_line(Proof, BoxNo, Result),
    % write(Result),nl.
