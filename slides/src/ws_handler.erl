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


to_json_item(Item) ->
    {Node, {_State, Detail, Ws}} = Item,
    jsx:encode([{<<"node">>, Node}, {<<"detail">>, Detail},
        {<<"web_socket_connected">>, Ws}]).


to_json_array([]) -> [];
to_json_array([H | T]) when T =/= [] ->
    [[to_json_item(H) | <<",">>] | to_json_array(T)];
to_json_array([H | T]) ->
    [to_json_item(H) | to_json_array(T)].


format_result(Replies, _BadNodes) ->
    io_lib:format("[~s]", [to_json_array(Replies)]).


websocket_info({timeout, _Ref, Msg}, Req, State) ->
    {Replies, BadNodes} = gen_server:multi_call([node() | nodes()], server_info, {command, info, node()}, 20000),
%%    io:format("Node Replies ~p - Bad Nodes ~p ~n", [Replies, BadNodes]),
    erlang:start_timer(1000, self(), format_result(Replies, BadNodes)),
    {reply, {text, Msg}, Req, State};
websocket_info(_Info, Req, State) ->
    {ok, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
    gen_server:abcast([node()], server_info, {del_client}),
    ok.