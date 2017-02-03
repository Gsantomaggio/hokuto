%%%-------------------------------------------------------------------
%% @doc pub_sub public API
%% @end
%%%-------------------------------------------------------------------

-module(pub_sub_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    pub_sub_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================