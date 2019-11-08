-module(tsp_ets).

-include("ets_h.hrl").

-export([run/1]).

run(Selector) ->
    Numnodes = case Selector of
		 1 -> 5;
		 2 -> 5;
		 3 -> 10
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
    ets:insert(Tab, Es),
    ets:insert(Tab,
	       #s{r = 1, u = ordsets:from_list(lists:seq(2, Numnodes)),
		  p = [1], c = 0}),
    explore(Tab).

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
     || F <- lists:seq(1, X), T <- lists:seq(1, X), F =/= T].

explore(Tab) ->
    Ss = ets:lookup(Tab,
		    s),    % actually probably want to use select replace on them...
    case ordsets:is_empty((hd(Ss))#s.u) of
      false ->
	  NewSs = lists:flatmap(fun (S) -> advanceS(Tab, S) end,
				Ss),
	  ets:select_delete(Tab,
			    [{#s{r = '_', u = '_', p = '_', c = '_'}, [],
			      [true]}]),
	  % essentially, rule 4
	  ets:insert(Tab, NewSs),
	  explore(Tab);
      true -> finishUp(Tab)
    end.

finishUp(Tab) ->
    Ss = ets:take(Tab, s),
    lists:foreach(fun (S) -> makeZ(Tab, S) end, Ss),
    MinZ = findMinZ(Tab),
    ets:delete(Tab),
    io:format("Lowest cost is ~p~nShortest route is "
	      "~p~n",
	      [MinZ#z.c, lists:reverse(MinZ#z.p)]).

advanceS(Tab, S) ->
    Us = S#s.u,
    P = hd(S#s.p),
    Es = lists:flatmap(fun (U) ->
			       ets:select(Tab,
					  [{#e{f = '$1', t = '$2', c = '$3'},
					    [{'==', '$1', P}, {'==', '$2', U}],
					    [{{'$2', '$3'}}]}])
		       end,
		       ordsets:to_list(Us)),
    [S#s{u = ordsets:del_element(T, S#s.u), p = [T | S#s.p],
	 c = S#s.c + C}
     || {T, C} <- Es].

makeZ(Tab, S) ->
    P = hd(S#s.p),
    R = S#s.r,
    Es = ets:select(Tab,
		    [{#e{f = '$1', t = '$2', c = '$3'},
		      [{'==', '$1', P}, {'==', '$2', R}], [{{'$2', '$3'}}]}]),
    % There should be at most one, but it'll come back as a list anyway
    case Es of
      [] -> [];
      [Head | _Tail] ->
	  {T, C} = Head,
	  ets:insert(Tab, #z{p = [T | S#s.p], c = S#s.c + C})
    end.

findMinZ(Tab) ->
    findMinZ(Tab,
	     ets:select(Tab, [{#z{p = '_', c = '_'}, [], ['$_']}],
			1)).

findMinZ(Tab, {[Smallest | _], _}) ->
    SmallestC = Smallest#z.c,
    ets:select_delete(Tab,
		      [{#z{p = '_', c = '$1'}, [{'>', '$1', SmallestC}],
			[true]}]),
    Smaller = ets:select(Tab,
			 [{#z{p = '_', c = '$1'}, [{'<', '$1', SmallestC}],
			   ['$_']}],
			 1),
    case Smaller of
      '$end_of_table' -> Smallest;
      _ -> findMinZ(Tab, Smaller)
    end.
