%%%-------------------------------------------------------------------
%%% @author gabriele
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Dec 2017 18:20
%%%-------------------------------------------------------------------
-module(ds).
-author("gabriele").

%% API
-export([s/1, l/0, loop/2, busy_fun/0, r/1, run_them/1, get_status/0]).

s(Status) ->
    DecStatus = case Status of

                    w -> waiting;
                    ra -> runnable;
                    rn -> running;
                    g -> garbage_collecting
                end,
    P = erlang:processes(),            
    L = length(lists:filter(fun(X) ->
        erlang:process_info(X, [status]) == [{status, DecStatus}] end,
        P)),
    io:format("Status:~p len:~p ~n ", [Status, L]).



l() -> length(erlang:processes()).


loop(0, _) -> ok;
loop(N, F) -> F(N - 1, F).

busy_fun() -> spawn(fun() -> loop(10000000, fun loop/2) end).

spawn_them(N) -> [busy_fun() || _ <- lists:seq(1, N)].


r(N) -> R = spawn_them(N), s(rn), R.
get_status() -> lists:sort([{erlang:process_info(P, [status]), P}
    || P <- erlang:processes()]).



%% check erlang:system_info(schedulers_online).
%% length(erlang:processes()).
%% execute using +S 1 to 4 rel/vm.args
%% note about getstatus and process_info with partial result
%% describe the status

run_them(N) -> spawn_them(N), get_status().
