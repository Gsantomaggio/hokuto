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
	erlang:start_timer(1000, self(), <<"Hello!">>),
	{ok, Req, undefined_state}.

websocket_handle(_Data, Req, State) ->
	{ok, Req, State}.

format_node(Nodes) when Nodes =/= [] ->
    io_lib:format("I am: ~w, other nodes: ~w", [node(),nodes()]);
format_node(_Nodes) -> 
    io_lib:format("I am: ~w", [node()]).


websocket_info({timeout, _Ref, Msg}, Req, State) ->
  	erlang:start_timer(1000, self(), format_node(nodes())),
	{reply, {text, Msg}, Req, State};
websocket_info(_Info, Req, State) ->
	{ok, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
	ok.