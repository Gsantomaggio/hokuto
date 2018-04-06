%%%-------------------------------------------------------------------
%%% @author gabriele
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. Dec 2016 16:44
%%%-------------------------------------------------------------------
-module(rest_search).
-author("gabriele").

%% API
-export([init/3, content_types_provided/2, to_json/2]).


init(_Transport, _Req, []) ->
    {upgrade, protocol, cowboy_rest}.

content_types_provided(ReqData, Context) ->
    {[{<<"application/json">>, to_json}], ReqData, Context}.


to_json_item(Item) ->
    {Node, Detail} = Item,
    case Detail of
        {_State, Data} ->
            jsx:encode([{<<"node">>, Node}, {<<"data">>, Data}])
    end.

to_json(ReqData, Context) ->
    %Search_Nodes = lists:filter(fun(K) -> string:str(lists:flatten(io_lib:format("~s",[K])), "search_") =:= 1  end, [node()|nodes()]),
    Search_Nodes = [node() | nodes()],
    {Replies, _BadNodes} = gen_server:multi_call(Search_Nodes, mod_search, 
        {command, search}, 20000),
    {check_nodes(Replies), ReqData, Context}.


check_nodes(Replies) when Replies =/= [] ->
  io_lib:format("[~s]", [json_utils:to_json_array(Replies, fun to_json_item/1)]);
check_nodes(Replies) ->
  "".

   