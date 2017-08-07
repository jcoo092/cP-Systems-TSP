/* Written by Radu Nicolescu, University of Auckland, August 2017 */

e(1, 2, 1).
e(1, 3, 3).
e(1, 5, 2).
e(2, 1, 1).
e(2, 4, 6).
e(2, 5, 4).
e(3, 1, 3).
e(3, 4, 8).
e(3, 5, 5).
e(4, 2, 6).
e(4, 3, 8).
e(4, 5, 7).
e(5, 1, 2).
e(5, 2, 4).
e(5, 3, 5).
e(5, 4, 7).
v([1, 2, 3, 4, 5]).
n(5).

s(R, [], [F| P], C, Ph, Ch) :- e(F, R, W), CW is C + W, Ph = [R, F| P], Ch = CW.

s(R, Y, [F| P], C, Ph, Ch) :- member(T, Y), delete(Y, T, Z), e(F, T, W), CW is C + W, s(R, Z, [T, F| P], CW, Ph, Ch).

h(R, Y, H) :- findall(z(Ph,Ch), s(R, Y,[R],0,Ph,Ch), H).

minh([z(P1,C1)], [z(P1,C1)]).
minh([z(P1,C1), z(_P2,C2)| H], M) :- C1 =< C2, !, minh([z(P1,C1)| H], M).
minh([z(_P1,_C1), z(P2,C2)| H], M) :- minh([z(P2,C2)| H], M).
 
go(M) :- v(X), member(R, X), delete(X, R, Y), !, h(R, Y, H), minh(H, M).
