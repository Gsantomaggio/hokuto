%%%-------------------------------------------------------------------
%%% @author GaS
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Sep 2018 17:12
%%%-------------------------------------------------------------------
-module(da_get_handler).
-author("GaS").

-export([init/2, content_types_provided/2, allowed_methods/2, get_data/2]).

%%% recon_trace:calls({da_get_handler, '_', [{'_', [], []}]}, 100).

%%% recon_trace:calls({da_get_handler, '_', [{'_', [], []}]}, 100, [{scope, local}]).
%%% see the different

%%% recon_trace:calls({da_get_handler, '_', [{'_', [], [{return_trace}]}]}, 100, [{scope, local}]).




init(Req, Opts) ->
    error_logger:info_report([{"da_get_handler PID", self()}]),
    error_logger:info_report([{"info", process_info(self())}]),
    {cowboy_rest, Req, Opts}.

content_types_provided(Req, State) ->
    {[{<<"application/json">>, get_data}], Req, State}.

allowed_methods(Req0, State) ->
    error_logger:info_report([{hello, ciao}]),
    Req = cowboy_req:set_resp_header(<<"access-control-allow-origin">>, <<"*">>, Req0),
    {[<<"GET">>], Req, State}.

first() ->
    second().

get_data(Req, State) ->
    V = first(),
    R = io_lib:format("[{\"hello\": \"world ~B\"}]", [V]),
    {list_to_binary(R), Req, State}.

second() ->
    timer:sleep(200),
    1 + third().

third() ->
    1.
