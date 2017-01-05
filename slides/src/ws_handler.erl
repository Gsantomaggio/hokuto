-module(ws_handler).
-behaviour(cowboy_websocket_handler).

-export([init/3]).
-export([websocket_init/3]).
-export([websocket_handle/3]).
-export([websocket_info/3]).
-export([websocket_terminate/3]).

init({tcp, http}, _Req, _Opts) ->
    {upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Req, _Opts) ->

    erlang:start_timer(1000, self(), <<"Init..">>),
    gen_server:abcast([node()], server_info, {new_client}),
    {ok, Req, undefined_state}.

websocket_handle(_Data, Req, State) ->
    {ok, Req, State}.


websocket_info({timeout, _Ref, Msg}, Req, State) ->

    erlang:start_timer(1000, self(), cluster_info:cluster_status()),
    {reply, {text, Msg}, Req, State};
websocket_info(_Info, Req, State) ->
    {ok, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
    gen_server:abcast([node()], server_info, {del_client}),
    ok.