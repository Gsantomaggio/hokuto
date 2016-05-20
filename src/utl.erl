%%%-------------------------------------------------------------------
%%% @author GaS
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. May 2016 17:23
%%%-------------------------------------------------------------------
-module(utl).
-author("GaS").

%% API
-export([to_one/0]).


to_one() ->
    net_kernel:connect(node1@mac).
