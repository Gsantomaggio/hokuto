%%%-------------------------------------------------------------------
%% @doc slides top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(slides_sup).

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
     ChildSpec = {server_info, {server_info, start_link, []},
          permanent, brutal_kill, worker, [server_info]},
     Children = [ChildSpec],
     {ok, {RestartStrategy, Children}}.


%%{ok, { {one_for_all, 0, 1}, []} }.

%%====================================================================
%% Internal functions
%%====================================================================
