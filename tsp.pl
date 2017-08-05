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

s(0, [R], 0, Y, R) :- v(X), member(R, X), delete(X, R, Y), !.

s(L1, [T, F| P], CW, Z, R) :- 0 < L1, L is L1-1, s(L, [F| P], C, Y, R), e(F, T, W), CW is C + W, member(T, Y), delete(Y, T, Z).

s1([R, F| P], CW, R) :- n(N), N1 is N-1, s(R, N1, [F| P], C, []), e(F, R, W), CW is C + W.

h(HC) :- findall(z(P,C), s1(P,C, _R), HC).

minh([z(P1,C1)], [z(P1,C1)]). 
minh([z(P1,C1), z(_P2,C2)| HC], M) :- C1 =< C2, !, minh([z(P1,C1)| HC], M).
minh([z(_P1,_C1), z(P2,C2)| HC], M) :- minh([z(P2,C2)| HC], M).

go(M) :- h(HC), minh(HC, M).