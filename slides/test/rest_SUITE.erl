%%%-------------------------------------------------------------------
%%% @author GaS
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Feb 2017 11:07
%%%-------------------------------------------------------------------
-module(rest_SUITE).
-author("GaS").

-include_lib("eunit/include/eunit.hrl").

-compile(export_all).

all() ->
    [
        {group, non_parallel_tests}
    ].

groups() ->
    [
        {non_parallel_tests, [], [
            simple_test]}
    ].

%% -------------------------------------------------------------------
%% Testsuite setup/teardown.
%% -------------------------------------------------------------------
init_per_suite(Config) ->
    Config.

end_per_suite(_Config) ->
    ok.

init_per_group(_, Config) ->
    Config.

end_per_group(_, _Config) ->
    ok.

init_per_testcase(_, Config) ->
    Config.

end_per_testcase(_, _Config) ->
    ok.


simple_test(_Config) ->
    true.