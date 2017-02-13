%%%-------------------------------------------------------------------
%%% @author gabriele
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. Feb 2017 11:47
%%%-------------------------------------------------------------------
-module(etcd2).
-author("gabriele").

%% API
-export([join/0]).



getenv(OSKey, Default) ->
    case os:getenv(OSKey) of
        false -> Default;
        Value -> Value
    end.


%% @spec create_etcd_dir() -> list()
%% @doc Ensure that the directory key for the cluster exists in etcd
%% @end
%%
create_etcd_dir() ->
    io:format("Creating etcd base path~n"),
    case http_utils:put(getenv("ETCD2_SCHEMA", "http"),
        getenv("ETCD2_HOST", "127.0.0.1"),
        getenv("ETCD2_PORT", 2379),
        base_path(), [{dir, true}], []) of
        {ok, _} -> ok;
        Error -> Error
    end.


%% @spec base_path() -> list()
%% @doc Return a list of path segments that are the base path for etcd key actions
%% @end
%%
base_path() ->
    [v2, keys, "slides", "default"].

get_nodes() ->
    R = http_utils:get(getenv("ETCD2_SCHEMA", "http"),
        getenv("ETCD2_HOST", "127.0.0.1"),
        getenv("ETCD2_PORT", 2379),
        base_path(),
        [{recursive, true}]),
    R.

%% @spec extract_nodes(list(), list()) -> list()
%% @doc Return the list of erlang nodes
%% @end
%%
extract_nodes([], Nodes) -> Nodes;
extract_nodes([H | T], Nodes) ->
    extract_nodes(T, lists:append(Nodes, [get_node_from_key(proplists:get_value(<<"key">>, H))])).


%% @spec extract_nodes(list()) -> list()
%% @doc Return the list of erlang nodes
%% @end
%%
extract_nodes([]) -> [];
extract_nodes(Nodes) ->
    Dir = proplists:get_value(<<"node">>, Nodes),
    case proplists:get_value(<<"nodes">>, Dir) of
        undefined -> [];
        Values -> extract_nodes(Values, [])
    end.


%% @spec get_node_from_key(string()) -> string()
%% @doc Given an etcd key, return the erlang node name
%% @end
%%
get_node_from_key(<<"/", V/binary>>) -> get_node_from_key(V);
get_node_from_key(V) ->
    Path = string:concat(http_utils:build_path(lists:sublist(base_path(), 3, 2)), "/"),
    slides_utils:node_name(string:substr(binary_to_list(V), length(Path))).

list_nodes() ->
    case get_nodes() of
        {ok, Nodes} ->
            NodeList = extract_nodes(Nodes),
            {ok, NodeList};
        {error, "404"} -> create_etcd_dir(),
            list_nodes()
    end.

join() ->
    Nodes = list_nodes(),
    set_etcd_node_key(),
    ok.


%% @spec set_etcd_node_key() -> ok.
%% @doc Update etcd, setting a key for this node with a TTL of etcd_node_ttl
%% @end
%%
set_etcd_node_key() ->
    Interval = 10,
    case http_utils:put(getenv("ETCD2_SCHEMA", "http"),
        getenv("ETCD2_HOST", "127.0.0.1"),
        getenv("ETCD2_PORT", 2379),
        node_path(), [{ttl, Interval}],
        "value=enabled") of
        {ok, _} ->
            io:format("Updated node registration with etcd");
        {error, Error}   ->
            io:format("Failed to update node registration with etcd - ~s", [Error])
    end,
    ok.



node_path() ->
    base_path() ++ [atom_to_list(node())].