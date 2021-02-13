% For sicstus: use_module(library(lists)).  before consulting the file.

run_all_tests(ProgramToTest) :-
    catch(consult(ProgramToTest),
          B,
          (write('Could not consult \"'), write(ProgramToTest),
           write('\": '), write(B), nl, halt)),
    all_valid_ok(['tests/valid01.txt', 'tests/valid02.txt', 'tests/valid03.txt',
                  'tests/valid04.txt', 'tests/valid05.txt', 'tests/valid06.txt',
                  'tests/valid07.txt', 'tests/valid08.txt', 'tests/valid09.txt',
                  'tests/valid10.txt', 'tests/valid11.txt', 'tests/valid12.txt',
                  'tests/valid13.txt', 'tests/valid14.txt', 'tests/valid15.txt',
                  'tests/valid16.txt', 'tests/valid17.txt', 'tests/valid18.txt',
                  'tests/valid19.txt', 'tests/valid20.txt', 'tests/valid21.txt']),
    all_invalid_ok(['tests/invalid01.txt', 'tests/invalid02.txt', 'tests/invalid03.txt',
                    'tests/invalid04.txt', 'tests/invalid05.txt', 'tests/invalid06.txt',
                    'tests/invalid07.txt', 'tests/invalid08.txt', 'tests/invalid09.txt',
                    'tests/invalid10.txt', 'tests/invalid11.txt', 'tests/invalid12.txt',
                    'tests/invalid13.txt', 'tests/invalid14.txt', 'tests/invalid15.txt',
                    'tests/invalid16.txt', 'tests/invalid17.txt', 'tests/invalid18.txt',
                    'tests/invalid19.txt', 'tests/invalid20.txt', 'tests/invalid21.txt',
                    'tests/invalid22.txt', 'tests/invalid23.txt', 'tests/invalid24.txt',
                    'tests/invalid25.txt', 'tests/invalid26.txt', 'tests/invalid27.txt',
                    'tests/invalid28.txt']).
    % halt.



all_valid_ok([]).
all_valid_ok([Test | Remaining]) :-
    write(Test), 
    (verify(Test), write(' passed');
    write(' failed. The proof is valid but your program rejected it!')),
    nl, all_valid_ok(Remaining).

all_invalid_ok([]).
all_invalid_ok([Test | Remaining]) :-
    write(Test), 
    (\+verify(Test), write(' passed');
    write(' failed. The proof is invalid but your program accepted it!')),
    nl, all_invalid_ok(Remaining).
