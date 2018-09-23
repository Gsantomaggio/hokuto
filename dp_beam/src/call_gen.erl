%%%-------------------------------------------------------------------
%%% @author GaS
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Feb 2018 20:52
%%%-------------------------------------------------------------------
-module(call_gen).
-author("GaS").

%% API
-export([call_gen_raise_timeout/0, spawn_call/0]).


call_gen_raise_timeout() ->
    gg_s:from_detail().

spawn_call() ->
    process_flag(trap_exit, true),
    PID = spawn_link(?MODULE, call_gen_raise_timeout, []),
    io:format("Pid caller: ~w", [PID]),
    receive
        M -> io:format("GOT MESSAGE: ~w~n", [M])
    end.
