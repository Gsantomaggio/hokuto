%%%-------------------------------------------------------------------
%%% @author gabriele
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Jan 2017 18:49
%%%-------------------------------------------------------------------
-module(cluster_info).
-author("gabriele").

%% API
-export([to_json/2, cluster_status/0]).



to_json_item(Item) ->
    {Node, Detail} = Item,
    case Detail of
        {_State, Memory, Processes, Ws, Total_Ws} ->
            jsx:encode([{<<"node">>, Node}, {<<"memory">>, Memory}, {<<"processes">>, Processes},
                {<<"web_socket_connected">>, Ws}, {<<"total_web_sockets">>, Total_Ws}]);
        {_State, Memory, Processes} ->
            jsx:encode([{<<"node">>, Node}, {<<"memory">>, Memory}, {<<"processes">>, Processes}])
    end.


to_json(Replies, _BadNodes) ->
    io_lib:format("[~s]", [json_utils:to_json_array(Replies, fun to_json_item/1)]).


cluster_status() ->
    % Distributed call
    {Replies, BadNodes} = gen_server:multi_call([node() | nodes()],
        server_info, {command, info, node()}, 5000),
    to_json(Replies, BadNodes).


    % lists:foldr(fun({_, {state, _, _, WC, WT}}, {WCSum, WTSum}) ->
    %     {(WC + WCSum), (WT + WTSum)} end, {0, 0}, Replies),

    % {WCs,WTs} = lists:unzip([{WC, WT} || {_, {state, _, _, WC, WT}} <- L]),
    % {lists:sum(WCs), lists:sum(WTs)}.



