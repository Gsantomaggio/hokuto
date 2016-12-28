%%%-------------------------------------------------------------------
%% @doc search top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(search_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    RestartStrategy = {one_for_one, 10, 60},
    Server_Info = {server_info, {server_info, start_link, []},
          permanent, brutal_kill, worker, [server_info]},
    Mod_Search = {mod_search, {mod_search, start_link, []},
          permanent, brutal_kill, worker, [mod_search]},
    
     Children = [Server_Info,Mod_Search],
     {ok, {RestartStrategy, Children}}.

%%====================================================================
%% Internal functions
%%====================================================================
