-module(tsp_ets).

-include("ets_h.hrl").

-include_lib("stdlib/include/ms_transform.hrl").

-export([run/1]).

run(Selector) ->
    Numnodes = case Selector of
		 1 -> 5;
		 2 -> 5;
		 3 -> 5
	       end,
    run(Selector, Numnodes).

run(Selector, Numnodes) ->
    Es = case Selector of
	   1 -> optionOne();
	   2 -> optionTwo();
	   3 -> optionThree(Numnodes)
	 end,
    Tab = ets:new(tsp,
		  [duplicate_bag, {keypos, 1}, private]),
    % io:format("Tab is ~p~n", [Tab]),
    ets:insert(Tab, Es),
    start(Tab, lists:seq(1, Numnodes)).

optionOne() ->
    [#e{f = 1, t = 2, c = 1}, #e{f = 1, t = 3, c = 3},
     #e{f = 1, t = 5, c = 2}, #e{f = 2, t = 1, c = 1},
     #e{f = 2, t = 4, c = 6}, #e{f = 2, t = 5, c = 4},
     #e{f = 3, t = 1, c = 3}, #e{f = 3, t = 4, c = 8},
     #e{f = 3, t = 5, c = 5}, #e{f = 4, t = 2, c = 6},
     #e{f = 4, t = 3, c = 8}, #e{f = 4, t = 5, c = 7},
     #e{f = 5, t = 1, c = 2}, #e{f = 5, t = 2, c = 4},
     #e{f = 5, t = 3, c = 5}, #e{f = 5, t = 4, c = 7}].

optionTwo() ->
    [#e{f = 1, t = 3, c = 5}, #e{f = 1, t = 5, c = 2},
     #e{f = 2, t = 1, c = 1}, #e{f = 2, t = 4, c = 6},
     #e{f = 2, t = 5, c = 4}, #e{f = 3, t = 1, c = 3},
     #e{f = 3, t = 4, c = 8}, #e{f = 3, t = 5, c = 5},
     #e{f = 4, t = 2, c = 6}, #e{f = 4, t = 3, c = 8},
     #e{f = 4, t = 5, c = 7}, #e{f = 5, t = 1, c = 2},
     #e{f = 5, t = 2, c = 4}, #e{f = 5, t = 3, c = 5},
     #e{f = 5, t = 4, c = 9}].

optionThree(X) ->
    [#e{f = F, t = T, c = rand:uniform(10)}
     || F <- lists:seq(1, X), T <- lists:seq(1, X), F /= T].

start(Tab, [H | T]) ->
    ets:insert(Tab,
	       #s{r = H, u = ordsets:from_list(T), p = [H], c = 0}),
    explore(Tab).

explore(Tab) ->
    Ss = ets:select(Tab,
		    [{#s{_ = '_'}, [],
		      ['$_']}]),    % actually probably want to use select replace on them...
    case ordsets:is_empty((hd(Ss))#s.u) of
      false ->
	  NewSs = lists:flatmap(fun (S) -> advanceS(Tab, S) end,
				Ss),
	  ets:select_delete(Tab,
			    ets:fun2ms(fun (#s{}) -> true end)),
	  % essentially, rule 4
	  ets:insert(Tab, NewSs),
	  explore(Tab);
      true -> finishUp(Tab, Ss)
    end.

finishUp(Tab, Ss) ->
    Zs = lists:flatmap(fun (S) -> returnToStart(Tab, S) end,
		       Ss),
    % io:format("Tab deleted? ~p~n", [ets:delete(Tab)]),
    ets:delete(Tab),
    MinZ = findMinZ(Zs),
    io:format("Lowest cost is ~p~nShortest route is "
	      "~p~n",
	      [MinZ#z.c, lists:reverse(MinZ#z.p)]).

advanceS(Tab, S) ->
    Us = S#s.u,
    P = hd(S#s.p),
    Es = lists:flatmap(fun (U) ->
			       ets:select(Tab,
					  ets:fun2ms(fun (#e{f = F, t = T,
							     c = C})
							     when F == P,
								  T == U ->
							     {T, C}
						     end))
		       end,
		       ordsets:from_list(Us)),
    [S#s{u = ordsets:del_element(T, S#s.u), p = [T | S#s.p],
	 c = S#s.c + C}
     || {T, C} <- Es].

returnToStart(Tab, S) ->
    P = hd(S#s.p),
    R = S#s.r,
    Es = ets:select(Tab,
		    ets:fun2ms(fun (#e{f = F, t = T, c = C})
				       when F == P, T == R ->
				       {T, C}
			       end)),
    % There should be only one, but it'll come back as a list anyway
    case Es of
      [] -> [];
      [Head | _Tail] ->
	  {T, C} = Head, [#z{p = [T | S#s.p], c = S#s.c + C}]
    end.

findMinZ(Zs) ->
    lists:foldl(fun (Z, Acc) -> findMinZ(Z, Acc) end,
		hd(Zs), Zs).

findMinZ(X, Y) when X#z.c > Y#z.c -> Y;
findMinZ(X, _Y) -> X.
