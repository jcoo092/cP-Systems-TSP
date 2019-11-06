-module(tsp_ets).

-include("ets_h.hrl").

-include_lib("stdlib/include/ms_transform.hrl").

-export([run/1]).

run(Selector) ->
    Es = case Selector of
	   1 -> optionOne();
	   2 -> optionTwo()
	 end,
    Tab = ets:new(tsp,
		  [duplicate_bag, {keypos, #e.f}, private]),
    ets:insert(Tab, Es),
    start(Tab, [1, 2, 3, 4, 5]).

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
	  %   io:format("NewSs:~n~p~n", [NewSs]),
	  ets:select_delete(Tab,
			    % [{[#s{_ = '_'}], [],
			    %   [{true}]}]), % essentially, rule 4
			    ets:fun2ms(fun (#s{}) -> true end)),
	  ets:insert(Tab, NewSs),
	  explore(Tab);
      true -> finishUp(Tab, Ss)
    end.

finishUp(Tab, Ss) ->
    Zs = lists:flatmap(fun (S) -> returnToStart(Tab, S) end,
		       Ss),
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
					  %   [{#e{f = '$1', t = '$2', c = '$3'},
					  %     [{'==', P, '$1'}, {'==', U, '$2'}],
					  %     % [{#e{f = '$1', t = '$2', _ = '_'}, [{'=:=', P, '$1'}],
					  %     [{'$2', '$3'}]}])
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
     || {T, C}
	    <- Es]. % Need to filter out the 'u's for which there is no e that goes from P to U

                   % lists:map(fun ({T, C}) -> S#s{t = T, c = C} end, Es).

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
