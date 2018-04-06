%%%-------------------------------------------------------------------
%%% @author gabriele
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. Dec 2016 16:44
%%%-------------------------------------------------------------------
-module(rest_info).
-author("gabriele").

%% API
-export([init/3, content_types_provided/2, allowed_methods/2, hello_to_html/2, hello_to_json/2, hello_to_text/2]).


init(_Transport, _Req, []) ->
    {upgrade, protocol, cowboy_rest}.

allowed_methods(Req, State) ->
    {[<<"GET">>, <<"POST">>], Req, State}.

content_types_provided(Req, State) ->
    {[
        {<<"text/html">>, hello_to_html},
        {<<"application/json">>, hello_to_json},
        {<<"text/plain">>, hello_to_text}
    ], Req, State}.

hello_to_html(Req, State) ->
    Body = cluster_info:cluster_status(),
    {Body, Req, State}.

hello_to_json(Req, State) ->
    Body = cluster_info:cluster_status(),
    {Body, Req, State}.

hello_to_text(Req, State) ->
    {cluster_info:cluster_status(), Req, State}.







   