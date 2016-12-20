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
            {"/slides", eventsource_handler, []},
            {"/", cowboy_static, {priv_file, eventsource, "index.html"}}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http, 100, [{port, 8080}], #{
        env => #{dispatch => Dispatch}
    }),

    slides_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    io:format("stop", []),

    ok.

%%====================================================================
%% Internal functions
%%====================================================================
