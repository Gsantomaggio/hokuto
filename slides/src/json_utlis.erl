%%%-------------------------------------------------------------------
%%% @author gabriele
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. Dec 2016 17:19
%%%-------------------------------------------------------------------
-module(json_utlis).
-author("gabriele").

%% API
-export([to_json_array/2]).


to_json_array([], _Fun) -> [];
to_json_array([H | T], Fun) when T =/= [] ->
    [[Fun(H) | <<",">>] | to_json_array(T, Fun)];
to_json_array([H | T], Fun) ->
    [Fun(H) | to_json_array(T, Fun)].
