%%%-------------------------------------------------------------------
%%% @author GaS
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Sep 2018 16:52
%%%-------------------------------------------------------------------
-module(dockerapp_app).
-author("GaS").

-behaviour(application).

%% Application callbacks
-export([start/2,
    stop/1, init_ssh/0]).

%%%===================================================================
%%% Application callbacks
%%%===================================================================


init_ssh() ->
    ssh:start(),
    P = [{inet, inet},
        {subsystems, []},
        {system_dir, "/tmp/ssh_daemon"},
        {password, "password"}],
    O = [{user_dir, "/tmp/otptest_user/.ssh"},
        {auth_methods, "publickey,password"},
        {password, "password"} | P],

    ssh:daemon(8099, O).


-spec(start(StartType :: normal | {takeover, node()} | {failover, node()},
    StartArgs :: term()) ->
    {ok, pid()} |
    {ok, pid(), State :: term()} |
    {error, Reason :: term()}).
start(_StartType, _StartArgs) ->
    error_logger:info_report([{init, start}]),
    init_ssh(),
    error_logger:info_report([{ssh, started}]),
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/api/get", da_get_handler, []},
            {"/api/trace", da_get_trace, []}

        ]
        }
    ]),
    cowboy:start_clear(my_http_listener,
        [{port, 8627}],
        #{env => #{dispatch => Dispatch}}
    ),
    error_logger:info_report([{webserver, started}]),
    da_sup:start_link().
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
