% -record(e, {f, t, c}). % f, t and c are all integers
% -record(s, {r, u, p, c}). % r is an integer, u is a set (specifically, a gb_set), p is a list and c is an integer
% -record(z, {p, c}). % p is a list and c is an integer

-record(e, {f :: integer() , t :: integer(), c :: non_neg_integer()}). % f, t and c are all integers
-record(s, {r :: integer() , u, p :: list(), c :: non_neg_integer()}). % r is an integer, u is a set (specifically, a gb_set), p is a list and c is an integer
-record(z, {p :: list(), c :: non_neg_integer()}). % p is a list and c is an integer