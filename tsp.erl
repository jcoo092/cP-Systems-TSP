-module(tsp).
-export([go/0]).
-record(e, {f, t, c}).
-record(s, {r, u, p, c}).
-record(z, {p, c}).

go() ->
    E = [
        #e{f = 1, t = 2, c = 1},
        #e{f = 1, t = 3, c = 3},
        #e{f = 1, t = 5, c = 2},
        #e{f = 2, t = 1, c = 1},
        #e{f = 2, t = 4, c = 6},
        #e{f = 2, t = 5, c = 4},
        #e{f = 3, t = 1, c = 3},
        #e{f = 3, t = 4, c = 8},
        #e{f = 3, t = 5, c = 5},
        #e{f = 4, t = 2, c = 6},
        #e{f = 4, t = 3, c = 8},
        #e{f = 4, t = 5, c = 7},
        #e{f = 5, t = 1, c = 2},
        #e{f = 5, t = 2, c = 4},
        #e{f = 5, t = 3, c = 5},
        #e{f = 5, t = 4, c = 7}
    ],
    V = sets:from_list([1, 2, 3, 4, 5]),

    R = 1,
    [Min|_Mins] = minh(hgoal(R, V, E)),
    io:format("~p~n", [Min#z.c]),
    io:format("~p~n", [lists:reverse(Min#z.p)]).

hgoal(R, V, E) ->
    S = sgoal([#s{r = R, u = sets:del_element(R, V), p = [R], c = 0}], R, E),
    lists:map(fun (X) -> #z{p = X#s.p, c = X#s.c} end, S).

sgoal(S, R, E) ->
    First = first(S),
    case sets:size(First#s.u) > 0 of
        false -> lists:flatmap(fun (X) -> visit(X, sets:from_list([R]), E) end, S);
        true -> sgoal(lists:flatmap(fun (X) -> visit(X, X#s.u, E) end, S), R, E)
    end.

visit(S, U, E) ->
    Ef = [Q || Q <- E, Q#e.f == first(S#s.p), sets:is_element(Q#e.t, U)],
    lists:map(fun (X) ->
        #s{r = S#s.r, u = sets:del_element(X#e.t, U), p = [X#e.t|S#s.p], c = X#e.c + S#s.c}
    end, Ef).

minh(Z) ->
    MinCost = lists:foldl(fun (X, Y) -> min(X, Y) end, (first(Z))#z.c, Z),
    lists:filter(fun (X) -> X#z.c == MinCost end, Z).

first([H|_T]) ->
    H.