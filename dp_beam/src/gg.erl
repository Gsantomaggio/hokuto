%%%-------------------------------------------------------------------
%%% @author gabriele
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Dec 2017 20:40
%%%-------------------------------------------------------------------
-module(gg).
-author("gabriele").

-behaviour(gen_server).

%% API
-export([start_link/0, call/1, cast/1, calls/1, casts/1, my_call/1, does_not_match_call/1]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {number_of_async = 0, number_of_sync = 0}).

%%%===================================================================
%%% API
%%%===================================================================

%% note about process info and dictornary
%% back to ds_processes:spawn_with_dictonary


calls(N) ->
    [call(X) || X <- lists:seq(1, N)].

casts(N) ->
    [cast(X) || X <- lists:seq(1, N)].



call(N) ->
    gen_server:call(?MODULE, {sync, N}, 20000).


cast(N) ->
    gen_server:cast(?MODULE, {async, N}).



my_call(N) ->
    gen_server:call(?MODULE, {mycall, N}, 20000).



%%% different between this and the standard message passing ( this won't leak)
does_not_match_call(N) ->
    gen_server:call(?MODULE, {does_not_match, N}, 1000).


%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
    {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
    {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term()} | ignore).
init([]) ->
    io:format("My gg PID is: ~p~n", [self()]),
    {ok, #state{}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
    {reply, Reply :: term(), NewState :: #state{}} |
    {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_call({sync, Tasks}, _From, State = #state{number_of_sync = NS}) ->
    io:format("CALL - doing call n:~p ~n", [Tasks]),
    timer:sleep(2000),
    io:format("CALL -finished call n:~p ~n", [Tasks]),
    R = NS + 1,
    io:format("Total SYNC:~p ~n", [R]),
    {reply, ok, State#state{number_of_sync = R}};
handle_call({mycall, MyValue}, _From, State = #state{number_of_sync = NS}) ->
    io:format("mycall - doing MYCALL n:~p ~n", [MyValue]),
    timer:sleep(2000),
    io:format("mycall - doing MYCALL n:~p ~n", [MyValue]),
    {reply, ok, State}.


%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_cast({async, Tasks}, State = #state{number_of_async  = NA}) ->
    io:format("CAST- doing cast n:~p ~n", [Tasks]),
    timer:sleep(1000),
    io:format("CAST- finished cast n:~p ~n", [Tasks]),
    R = NA + 1,
    io:format("Total ASYNC:~p ~n", [R]),
%% note about noreply !
    {noreply, State#state{number_of_async = R}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_info(_Info, State) ->

    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(Reason, _State) ->
    io:format("gg treminate reason:~w ~n",[Reason]),
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
    {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
