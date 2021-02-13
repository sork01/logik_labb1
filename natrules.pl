andel1(and(A, /*B*/_), A). % and elimination for first variable

andel2(and(/*A*/_, B), B). % and elimination for second variable

andint(A, B, and(A, B)). % and introduction

contel(cont, _). % contradiction elimination

copy(A, A). % copy

impel(A, imp(A, B), B). % implication elimination

impint(A, B, imp(A, B)). % implication introduction

lem(or(A,neg(A))). % law of excluded middle

mt(imp(A,B),neg(B),neg(A)). % modus tollens

negel(A, neg(A), cont). % negation elimination

negint(A, cont, neg(A)). % negation introduction

negnegel(neg(neg(A)), A). % double negation elimination

negnegint(A, neg(neg(A))). % double negation introduction

orel(or(A,B), A, X, B, X, X). % or elimination

pbc(neg(A), cont, A). % proof by contradiction
