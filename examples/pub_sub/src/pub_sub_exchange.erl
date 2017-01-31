%%%-------------------------------------------------------------------
%%% @author GaS
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. Jan 2017 21:49
%%%-------------------------------------------------------------------
-module(pub_sub_exchange).
-author("GaS").
-behaviour(gen_event).

-export([init/1, handle_event/2, handle_call/2, handle_info/2, code_change/3,
    terminate/2]).

init([Pid]) ->
    {ok, Pid}.

handle_event(_Event, Pid) ->
    {ok, Pid}.

handle_call(_, State) ->
    {ok, ok, State}.

handle_info(_, State) ->
    {ok, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

terminate(_Reason, _State) ->
    ok.