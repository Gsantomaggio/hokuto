%%%-------------------------------------------------------------------
%% @doc slides public API
%% @end
%%%-------------------------------------------------------------------

-module(slides_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", cowboy_static, {priv_file, slides, "index.html"}},
            {"/websocket", ws_handler, []},
            {"/[...]", cowboy_static, {priv_dir, slides, "",
                [{mimetypes, cow_mimetypes, all}]}}
       ]}
    ]),
    {ok, _} = cowboy:start_http(http, 100, [{port, 8080}], [
        {env, [{dispatch, Dispatch}]}
    ]),

    slides_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    io:format("stop", []),

    ok.

%%====================================================================
%% Internal functions
%%====================================================================
