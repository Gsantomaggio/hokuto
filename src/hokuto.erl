%%%-------------------------------------------------------------------
%%% @author GaS
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Apr 2016 09:07
%%%-------------------------------------------------------------------
-module(hokuto).
-author("GaS").

-behaviour(application).

%% Application callbacks
-export([start/2,
    stop/1]).

%%%===================================================================
%%% Application callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called whenever an application is started using
%% application:start/[1,2], and should start the processes of the
%% application. If the application is structured according to the OTP
%% design principles as a supervision tree, this means starting the
%% top supervisor of the tree.
%%
%% @end
%%--------------------------------------------------------------------
-spec(start(StartType :: normal | {takeover, node()} | {failover, node()},
    StartArgs :: term()) ->
    {ok, pid()} |
    {ok, pid(), State :: term()} |
    {error, Reason :: term()}).
%%start() ->
%%    start(nornal, master).



start_as(StartArgs) when StartArgs =:= worker ->
    io:format("***** join node ************ ~n", []),
    net_kernel:connect(master@mac),
    ok;

start_as(_StartArgs)  ->
    case sup_master_monitor:start_link() of
        {ok, Pid} ->
            io:format("***** Simulator started!! ~n"),
            {ok, Pid};
        Error ->
            io:format("Bu Bu Error:~p", [Error]),
            Error
    end.



start(_StartType, StartArgs) ->
    io:format("***** Hokuto Simulator Version 0.1 ************ ~n", []),
    io:format("***** Startup parameters: ~p ~p ************  ~n", [_StartType, StartArgs]),
    start_as(StartArgs).
%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called whenever an application has stopped. It
%% is intended to be the opposite of Module:start/2 and should do
%% any necessary cleaning up. The return value is ignored.
%%
%% @end
%%--------------------------------------------------------------------
-spec(stop(State :: term()) -> term()).
stop(_State) ->
    ok.

%%%===================================================================
%%% Internal functions
%%%===================================================================
