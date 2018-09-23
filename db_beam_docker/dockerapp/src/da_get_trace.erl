%%%-------------------------------------------------------------------
%%% @author GaS
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Sep 2018 17:12
%%%-------------------------------------------------------------------
-module(da_get_trace).
-author("GaS").

-export([init/2, content_types_provided/2, allowed_methods/2, get_data/2]).



%%% LOCAL TRACE
%%  dbg:start(). dbg:tracer().
%%  dbg:tpl(da_get_trace,parse, []).
%%  dbg:p(all, c).
%% http://erlang.org/doc/man/dbg.html#p-2

%% dbg:stop()
%% try again with
%% dbg:tpl(da_get_trace,parse, dbg:fun2ms(fun(_) -> return_trace() end)).
%% dbg:tpl(da_get_trace,parse, dbg:fun2ms(fun(_) -> caller() end)).

%% dbg:stop()
%% try again with
%% dbg:tpl(da_get_trace,parse, dbg:fun2ms(fun([N]) when  N > 3 ->  enable_trace(da_get_trace, parse) end)).
%% dbg:tpl(da_get_trace,parse, dbg:fun2ms(fun([N]) when  N > 3 ->  return_trace() end)).





%%% dbg:fun2ms(fun([N]) when N > 3 -> return_trace() end).
%%% recon_trace:calls({da_get_trace, parse,  fun([N]) when N > 3 -> return_trace() end}, 100, [{scope, local}]).
%%% recon_trace:calls({da_get_trace, '_', [{'_', [], [{return_trace}]}]}, 100, [{scope, local}]).

%%% recon_trace:calls({da_get_trace, parse,  fun([N]) when N > 5 -> caller() end}, 100, [{scope, local}]).
%%% recon_trace:calls({da_get_trace, parse,  fun([N]) when N > 5 -> enable_trace() end}, 100, [{scope, local}]).






init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.

content_types_provided(Req, State) ->
    {[{<<"application/json">>, get_data}], Req, State}.

allowed_methods(Req0, State) ->
    Req = cowboy_req:set_resp_header(<<"access-control-allow-origin">>, <<"*">>, Req0),
    {[<<"GET">>], Req, State}.


doing_stuff_with_param(Param) ->
    Param * 2.

parse(Param) ->
    doing_stuff_with_param(Param).

get_data(Req, State) ->
    #{param := Param} = cowboy_req:match_qs([{param, [], undefined}], Req),
    Int_Value = list_to_integer(binary_to_list(Param)),
    V = parse(Int_Value),
    da_process:send_task(),
    R = io_lib:format("[{\"hello\": \"trace: ~p\"}]", [V]),
    {list_to_binary(R), Req, State}.

