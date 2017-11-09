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
    {_Status, Port} = application:get_env(slides, port),
    io:format("****************************************************~n", []),
    io:format("********************* Slides ***********************~n", []),
    io:format("********************* Node Name: ~w ~n", [node()]),
    io:format("********************* HTTP Port: ~b ~n", [list_to_integer(Port)]),
    io:format("****************************************************~n", []),


    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", cowboy_static, {priv_file, slides, "index.html"}},
            {"/wsinfo", ws_handler, []},
            {"/wsmonitor", ws_monitor, []},
            {"/rest/search", rest_search, []},
            {"/rest/publish", rest_rabbitmq, []},
            {"/rest/info", rest_info, []},

            
            {"/[...]", cowboy_static, {priv_dir, slides, "",
                [{mimetypes, cow_mimetypes, all}]}}
        ]}
    ]),
    {ok, _} = cowboy:start_http(http, 100, [{port, list_to_integer(Port)}], [
        {env, [{dispatch, Dispatch}]}
    ]),

    slides_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    io:format("Application Stopped ~n", []),
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
