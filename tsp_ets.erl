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
    TabE = ets:new(e_funcs,
		   [duplicate_bag, {keypos, #e.f}, private]),
    ets:insert(TabE, Es),
    TabS = ets:new(s_funcs, [duplicate_bag, private]),
    ets:insert(TabS,
	       #s{r = 1, u = ordsets:from_list(lists:seq(2, Numnodes)),
		  p = [1], c = 0}),
    explore(TabE, TabS).

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

explore(TabE, TabS) ->
    Ss = ets:lookup(TabS, s),
    % io:format("Ss: ~p~n", [Ss]),
    case ordsets:is_empty((hd(Ss))#s.u) of
      false ->
	  NewSs = lists:flatmap(fun (S) -> advanceS(TabE, S) end,
				Ss),
	  ets:select_delete(TabS,
			    [{#s{r = '_', u = '_', p = '_', c = '_'}, [],
			      [true]}]),
	  % essentially, rule 4
	  ets:insert(TabS, NewSs),
	  explore(TabE, TabS);
      true ->
	  TabZ = ets:new(z_funcs,
			 [duplicate_bag, {keypos, #z.c}, private]),
	  finishUp(TabE, TabS, TabZ)
    end.

finishUp(TabE, TabS, TabZ) ->
    Ss = ets:take(TabS, s),
    lists:foreach(fun (S) -> makeZ(TabE, TabZ, S) end, Ss),
    ets:delete(TabS),
    MinZ = findMinZ(TabE, TabZ),
    ets:delete(TabE),
    io:format("Lowest cost is ~p~nShortest route is "
	      "~p~n",
	      [MinZ#z.c, lists:reverse(MinZ#z.p)]).

advanceS(TabE, S) ->
    Us = S#s.u,
    P = hd(S#s.p),
    Es = lists:flatmap(fun (U) ->
			       ets:select(TabE,
					  [{#e{f = '$1', t = '$2', c = '$3'},
					    [{'==', '$1', P}, {'==', '$2', U}],
					    [{{'$2', '$3'}}]}])
		       end,
		       ordsets:to_list(Us)),
    [S#s{u = ordsets:del_element(T, S#s.u), p = [T | S#s.p],
	 c = S#s.c + C}
     || {T, C} <- Es].

makeZ(TabE, TabZ, S) ->
    P = hd(S#s.p),
    R = S#s.r,
    Es = ets:select(TabE,
		    [{#e{f = '$1', t = '$2', c = '$3'},
		      [{'==', '$1', P}, {'==', '$2', R}], [{{'$2', '$3'}}]}]),
    % There should be at most one, but it'll come back as a list anyway
    case Es of
      [] -> [];
      [Head | _Tail] ->
	  {T, C} = Head,
	  ets:insert(TabZ, #z{p = [T | S#s.p], c = S#s.c + C})
    end.

findMinZ(TabE, TabZ) ->
    findMinZ(TabE, TabZ,
	     ets:select(TabZ, [{#z{p = '_', c = '_'}, [], ['$_']}],
			1)).

findMinZ(TabE, TabZ, {[Smallest | _], _}) ->
    SmallestC = Smallest#z.c,
    ets:select_delete(TabZ,
		      [{#z{p = '_', c = '$1'}, [{'>', '$1', SmallestC}],
			[true]}]),
    Smaller = ets:select(TabZ,
			 [{#z{p = '_', c = '$1'}, [{'<', '$1', SmallestC}],
			   ['$_']}],
			 1),
    case Smaller of
      '$end_of_table' -> Smallest;
      _ -> findMinZ(TabE, TabZ, Smaller)
    end.
