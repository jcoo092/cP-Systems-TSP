-module(tsp_ets).

-include("ets_h.hrl").

-export([optionOne/0, run/1]).

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
    ets:insert(Tab, #s{r = H, u = T, p = [H], c = 0}),
    explore(Tab).

explore(Tab) ->
    Ss = ets:select(Tab,
		    [{#s{_ = '_'}, [],
		      ['$_']}]),    % actually probably want to use select replace on them...
    case (hd(Ss))#s.u of
      [] -> makeZs(Tab);
      _ ->
	  NewSs = lists:flatmap(fun (S) -> advanceS(Tab, S) end,
				Ss),
	  ets:insert(Tab, NewSs)
    end,
    explore(Tab).

makeZs(Tab) -> 5.

advanceS(Tab, S) ->
    Us = S#s.u,
    P = hd(S#s.p),
    Es = lists:flatmap(fun (U) ->
			       ets:select(Tab,
					  [{#e{f = '$1', t = '$2', c = '$3'},
					    [{'==', P, '$1'}, {'==', U, '$2'}],
					    % [{#e{f = '$1', t = '$2', _ = '_'}, [{'=:=', P, '$1'}],
					    [{'$2', '$3'}]}])
		       end,
		       Us),
    [S#s{u = lists:delete(T, S#s.u), p = [T | S#s.p],
	 c = S#s.c + C}
     || {T, C}
	    <- Es]. % Need to filter out the 'u's for which there is no e that goes from P to U
		       % lists:map(fun ({T, C}) -> S#s{t = T, c = C} end, Es).
