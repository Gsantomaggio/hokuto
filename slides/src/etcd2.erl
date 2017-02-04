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



getenv(OSKey) ->
    os:getenv(OSKey).


register_node() ->
    ok.


get_nodes() ->
    R = getenv("ETCD2_HOST"),
    io:format("~s",[R]),
    false.

%%   httpc:get(get(etcd_scheme),
%%        get(etcd_host),
%%        get(etcd_port),
%%        base_path(),
%%        [{recursive, true}]).


maybe_join() ->
    case get_nodes() of
        false -> register_node()
    end,
    ok.


join() ->
    maybe_join(),
    ok.
