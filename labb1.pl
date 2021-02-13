:- initialization
    consult('natrules.pl'),
    consult('proofs.pl').

verify(Filename):- %obs anvand single quote for filename
    see(Filename),
    read(Premises),
    read(Conclusion),
    read(Proof),
    seen,
    box_mark_open(Proof),
    (valid_proof(Premises, Conclusion, Proof) ->
        write('yes'), nl, box_mark_closed(Proof);
        write('no'), nl, box_mark_closed(Proof), fail).

valid_proof(Premises, Conclusion, Proof):-
    validate(Proof, Premises, Proof),
    last(Proof, [_, Conclusion, _]).

validate(Proof, Premises, [[LineNo, Statement, premise]|Tail]):-
    !,
    open(LineNo),
    memberchk(Statement, Premises),
    validate(Proof, Premises, Tail).

validate(Proof, Premises, [[LineNo, /*Statement*/_, assumption]|Tail]):-
    !,
    open(LineNo),
    line_opens_box(Proof, LineNo),
    validate(Proof, Premises, Tail).

validate(Proof, Premises, [[LineNo, Statement, copy(K)]|Tail]):-
    !,
    K < LineNo,
    all_open(LineNo,K),
    proof_nth_statement(Proof, K, StatementK),
    copy(StatementK, Statement),
    validate(Proof, Premises, Tail).

validate(Proof, Premises, [[LineNo, cont, negel(K,M)]|Tail]):-
    !,
    K < LineNo,
    M < LineNo,
    all_open(LineNo, K, M),
    proof_nth_statement(Proof, K, StatementK),
    proof_nth_statement(Proof, M, StatementM),
    negel(StatementK, StatementM, cont),
    validate(Proof, Premises, Tail).

validate(Proof, Premises, [[LineNo, Statement, orel(O, BS1, BE1, BS2, BE2)]|Tail]):-
    !,
    O < LineNo,
    BS1 < LineNo,
    BE1 < LineNo,
    BS2 < LineNo,
    BE2 < LineNo,
    all_open(LineNo, O),
    lines_delimit_box(Proof, BS1, BE1),
    lines_delimit_box(Proof, BS2, BE2),
    none_open(BS1, BE1),
    none_open(BS2, BE2),
    proof_nth_statement(Proof, O, StatementO),
    proof_nth_statement(Proof, BS1, StatementBS1),
    proof_nth_statement(Proof, BE1, StatementBE1),
    proof_nth_statement(Proof, BS2, StatementBS2),
    proof_nth_statement(Proof, BE2, StatementBE2),
    orel(StatementO, StatementBS1, StatementBE1, StatementBS2, StatementBE2, Statement),
    validate(Proof, Premises, Tail).

validate(Proof, Premises, [[LineNo, Statement, pbc(K,M)]|Tail]):-
    !,
    most_recently_closed_box(Proof, LineNo, BoxNo),
    box_min_line(Proof, BoxNo, K),
    box_max_line(Proof, BoxNo, M),
    open(LineNo),
    none_open(K, M),
    lines_delimit_box(Proof, K, M),
    proof_nth_statement(Proof, K, StatementK),
    proof_nth_statement(Proof, M, StatementM),
    pbc(StatementK, StatementM, Statement),
    validate(Proof, Premises, Tail).

validate(Proof, Premises, [[LineNo, Statement, contel(K)]|Tail]):-
    !,
    K < LineNo,
    all_open(LineNo, K),
    proof_nth_statement(Proof, K, StatementK),
    contel(StatementK, Statement),
    validate(Proof, Premises, Tail).

validate(Proof, Premises, [[LineNo, Statement, negnegint(K)]|Tail]):-
    !,
    K < LineNo,
    all_open(LineNo, K),
    proof_nth_statement(Proof, K, StatementK),
    negnegint(StatementK, Statement),
    validate(Proof, Premises, Tail).

validate(Proof, Premises, [[LineNo, Statement, lem]|Tail]):-
    !,
    open(LineNo),
    lem(Statement),
    validate(Proof, Premises, Tail).

validate(Proof, Premises, [[LineNo, Statement, mt(K,M)]|Tail]):-
    !,
    K < LineNo,
    M < LineNo,
    all_open(LineNo, K, M),
    proof_nth_statement(Proof, K, StatementK),
    proof_nth_statement(Proof, M, StatementM),
    mt(StatementK, StatementM, Statement),
    validate(Proof, Premises, Tail).

validate(Proof, Premises, [[LineNo, Statement, impint(K,M)]|Tail]):-
    !,
    most_recently_closed_box(Proof, LineNo, BoxNo),
    box_min_line(Proof, BoxNo, K),
    box_max_line(Proof, BoxNo, M),
    open(LineNo),
    none_open(K, M),
    proof_nth_statement(Proof, K, StatementK),
    proof_nth_statement(Proof, M, StatementM),
    /*same_box(K,M),*/
    impint(StatementK, StatementM, Statement),
    validate(Proof, Premises, Tail).

validate(Proof, Premises, [[LineNo, Statement, impel(K,M)]|Tail]):-
    !,
    K < LineNo,
    M < LineNo,
    open(LineNo),
    proof_nth_statement(Proof, K, StatementK),
    proof_nth_statement(Proof, M, StatementM),
    impel(StatementK, StatementM, Statement),
    validate(Proof, Premises, Tail).
    
validate(Proof, Premises, [[LineNo, Statement, andel1(K)]|Tail]):-
    !,
    K < LineNo,
    open(LineNo),
    proof_nth_statement(Proof, K, StatementK),
    andel1(StatementK, Statement),
    validate(Proof, Premises, Tail).

validate(Proof, Premises, [[LineNo, Statement, andel2(K)]|Tail]):-
    !,
    K < LineNo,
    open(LineNo),
    proof_nth_statement(Proof, K, StatementK),
    andel2(StatementK, Statement),
    validate(Proof, Premises, Tail).
    
validate(Proof, Premises, [[LineNo, Statement, andint(K,M)]|Tail]):-
    !,
    K < LineNo,
    M < LineNo,
    all_open(LineNo, K, M),
    proof_nth_statement(Proof, K, StatementK),
    proof_nth_statement(Proof, M, StatementM),
    /*same_box(K,M),*/
    andint(StatementK, StatementM, Statement),
    validate(Proof, Premises, Tail).

validate(Proof, Premises, [[LineNo, Statement, negint(K,M)]|Tail]):-
    !,
    most_recently_closed_box(Proof, LineNo, BoxNo),
    box_min_line(Proof, BoxNo, K),
    box_max_line(Proof, BoxNo, M),
    open(LineNo),
    none_open(K, M),
    lines_delimit_box(Proof, K, M),
    proof_nth_statement(Proof, K, StatementK),
    proof_nth_statement(Proof, M, cont),
    negint(StatementK, cont, Statement),
    validate(Proof, Premises, Tail).

validate(Proof, Premises, [[LineNo, Statement, negnegel(K)]|Tail]):-
    !,
    K < LineNo,
    open(LineNo),
    proof_nth_statement(Proof, K, StatementK),
    negnegel(StatementK, Statement),
    validate(Proof, Premises, Tail).

validate(Proof, Premises, [Head|Tail]):-
    !,
    [[_,_,assumption]|_] = Head,
    box_mark_open(Head),
    validate(Proof, Premises, Head),
    box_mark_closed(Head),
    validate(Proof, Premises, Tail).

validate(/*Proof*/_, /*Premises*/_, []).

% main:-verify('tests/testvalid.txt').
main(X):-
    verify(X).
