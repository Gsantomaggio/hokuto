%%%-------------------------------------------------------------------
%%% @author GaS
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Sep 2018 16:51
%%%-------------------------------------------------------------------
-module(dockerapp).
-author("GaS").

-export([start/0]).

start() ->
    application:ensure_all_started(?MODULE).
