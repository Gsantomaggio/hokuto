%%%-------------------------------------------------------------------
%%% @author gabriele
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Sep 2015 09:44
%%%-------------------------------------------------------------------
-module(sup_master_monitor).
-author("gabriele").

-export([stop/1, start_link/0, init/1, async_start/0]).
-behaviour(supervisor).


async_start() ->
    spawn(?MODULE, start_link, []),
    ok.


start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

    
init(_Args) ->

    {ok, {{ one_for_one, 5, 10}, [
        {worker, {master_monitor, start_link, []}, transient, 2000, worker, [worker]}
    ]}}.

stop(Pid) ->
    gen_server:call(Pid, stop).