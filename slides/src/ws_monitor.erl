%%%-------------------------------------------------------------------
%%% @author gabriele
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Jan 2017 11:04
%%%-------------------------------------------------------------------
-module(ws_monitor).
-behaviour(cowboy_websocket_handler).
-author("gabriele").
-include("slides.hrl").


%% API
-export([init/3,
    websocket_init/3,
    websocket_handle/3,
    websocket_info/3,
    websocket_terminate/3]).

init({tcp, http}, _Req, _Opts) ->
    {upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Req, _Opts) ->
    gproc:reg({p, l, ?WSKey}),
    {ok, Req, undefined_state}.


websocket_handle({nodes, Msg}, Req, State) ->
    gproc:reg({p, l, ?WSKey}),
    {reply, {text, Msg}, Req, State};
websocket_handle(_Data, Req, State) ->
    {ok, Req, State}.

websocket_info(Info, Req, State) ->
    case Info of
        {_PID, ?WSKey, Msg} ->
            {reply, {text, Msg}, Req, State};
        _ ->
            {ok, Req, State, hibernate}
    end.

websocket_terminate(_Reason, _Req, _State) ->
    gproc:unreg({p, l, ?WSKey}),
    ok.
