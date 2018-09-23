%%%-------------------------------------------------------------------
%%% @author GaS
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. Sep 2018 14:19
%%%-------------------------------------------------------------------
-module(da_process).
-author("GaS").

-behaviour(gen_statem).

%% API
-export([start_link/0, send_task/0]).

%% gen_statem callbacks
-export([
    init/1,
    handle_event/4,
    terminate/3,
    code_change/4
    , callback_mode/0]).

-define(SERVER, ?MODULE).

-record(state, {}).



send_task() ->
    gen_statem:cast(?MODULE, do_stuff).

start_link() ->
    gen_statem:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
    {ok, ready, #state{}}.

callback_mode() ->
    handle_event_function.


handle_event(EventType, _EventContent, ready, State) ->
    error_logger:info_report([{handle_event, EventType}]),
    process_data(State),
    keep_state_and_data.

terminate(_Reason, _StateName, _State) ->
    ok.

code_change(_OldVsn, StateName, State, _Extra) ->
    {ok, StateName, State}.


process_data(State) ->
    process_data(State, erlang:system_time()).


process_data(_State, _ErlangsystemTime) ->
    timer:sleep(5000).

%%    create_file_slow(junk, 1024).
%%
%%
%%create_file_slow(Name, N) when is_integer(N), N >= 0 ->
%%    {ok, FD} =
%%        file:open(Name, [raw, write, delayed_write, binary]),
%%    if N > 256 ->
%%        ok = file:write(FD,
%%            lists:map(fun(X) -> <<X:32/unsigned>> end,
%%                lists:seq(0, 255))),
%%        ok = create_file_slow(FD, 256, N);
%%        true ->
%%            ok = create_file_slow(FD, 0, N)
%%    end,
%%    ok = file:close(FD).
%%
%%create_file_slow(_FD, 0, _N) ->
%%    ok;
%%create_file_slow(FD, M, N) ->
%%    ok = file:write(FD, <<M:32/unsigned>>),
%%    create_file_slow(FD, M + 1, N).