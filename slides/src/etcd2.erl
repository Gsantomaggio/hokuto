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


register_node() ->
    ok.


get_nodes() ->
    http_utils:get(getenv("ETCD2_SCHEMA", "etcd_scheme"),
        getenv("ETCD2_HOST", "127.0.0.1"),
        getenv("ETCD2_PORT", 2379),
        "slides",
        [{recursive, true}]).


maybe_join() ->
    case get_nodes() of
        false -> register_node()
    end,
    ok.


join() ->
    maybe_join(),
    ok.
