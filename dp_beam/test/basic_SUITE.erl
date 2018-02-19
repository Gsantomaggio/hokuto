%%%-------------------------------------------------------------------
%%% @author gabriele
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Dec 2017 14:28
%%%-------------------------------------------------------------------
-module(basic_SUITE).
-include_lib("common_test/include/ct.hrl").
-include_lib("eqc/include/eqc.hrl").
-export([all/0]).
-export([even_nat/0]).

all() -> [even_nat].

even_nat() ->
    ?SUCHTHAT(N, nat(),
        N rem 2 == 0).
