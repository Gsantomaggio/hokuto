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
    {Node, Detail} = Item,
    case Detail of
        {_State, Memory, Ws, Total_Ws} ->
            jsx:encode([{<<"node">>, Node}, {<<"memory">>, Memory},
                {<<"web_socket_connected">>, Ws}, {<<"total_web_sockets">>, Total_Ws}]);
        {_State, Memory} ->
            jsx:encode([{<<"node">>, Node}, {<<"memory">>, Memory}])
    end.


to_json(Replies, _BadNodes) ->
    io_lib:format("[~s]", [json_utils:to_json_array(Replies, fun to_json_item/1)]).

websocket_info({timeout, _Ref, Msg}, Req, State) ->
    % Distributed call
    {Replies, BadNodes} = gen_server:multi_call([node() | nodes()],
        server_info, {command, info, node()}, 20000),

    erlang:start_timer(1000, self(), to_json(Replies, BadNodes)),
    {reply, {text, Msg}, Req, State};
websocket_info(_Info, Req, State) ->
    {ok, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
    gen_server:abcast([node()], server_info, {del_client}),
    ok.