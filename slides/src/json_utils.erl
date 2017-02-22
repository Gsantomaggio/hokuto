%%%-------------------------------------------------------------------
%%% @author gabriele
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. Dec 2016 17:19
%%%-------------------------------------------------------------------
-module(json_utils).
-author("gabriele").

%% API
-export([to_json_array/2, try_decode/1, decode/1, try_decode/2]).


to_json_array(L, Fun) ->
    [[[Fun(X) | <<",">>] || X <- L, X =/= lists:last(L)] | Fun(lists:last(L))].


try_decode(JSON) ->
    try_decode(JSON, []).


try_decode(JSON, Opts) ->
    try
        {ok, decode(JSON, Opts)}
    catch error: Reason ->
        {error, Reason}
    end.

decode(JSON) ->
    decode(JSON, []).


decode(JSON, Opts) ->
    jsx:decode(JSON, Opts).