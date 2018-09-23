%%%-------------------------------------------------------------------
%%% @author gabriele
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Dec 2017 08:05
%%%-------------------------------------------------------------------
-module(gg_s).
-author("gabriele").

-behaviour(gen_server).

%% API
-export([start_link/0, getstatus/0, append_value/1, sum/2, from_detail/0, stop_me/0, stop/0]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {mystate = [], number_of_operations = 0}).


%%%===================================================================
%%% API
%%%===================================================================

from_detail() ->
    gen_server:call(?MODULE, {from_detail}, 10000).

stop_me() ->
    gen_server:call(?MODULE, {stop_me}).

stop() ->
    gen_server:stop(?MODULE).


sum(A, B) ->
    {NumberOfOperations, Result} = gen_server:call(?MODULE, {sum, A, B}),
    io:format("Number Of Operations ~p~n ", [NumberOfOperations]),
    io:format("Result ~p~n ", [Result]),
    done.


append_value(Value) ->
    gen_server:call(?MODULE, {changes, Value}).

getstatus() ->
    gen_server:call(?MODULE, {getstatus}).


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
    io:format("gen_s PID:~w~n", [self()]),
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
handle_call({changes, Value}, _From, State = #state{mystate = S}) ->
    R = lists:append(S, [Value]),
    {reply, ok, State#state{mystate = R}};
handle_call({getstatus}, _From, State = #state{mystate = S}) ->
    {reply, S, State};
handle_call({sum, A, B}, _From, State = #state{number_of_operations = N}) ->
    NO = N + 1,
    Res = A + B,
    {reply, {NO, Res}, State#state{number_of_operations = NO}};
handle_call({from_detail}, From, State = #state{mystate = S}) ->
    {Pid, Tag} = From,
    io:format("MYPID:~p~n monitored_by pid: ~p ~n~nFromPId ~p ~n~nTag~w ~nLinks~p ~n", 
        [self(),process_info(self(), monitored_by), Pid , Tag, process_info(self(), links)]),
    timer:sleep(11000),
    {reply, S, State};
handle_call({stop_me}, _From, State) ->
    {stop, "unkonw error, ", State}.
   % {stop, {shutdown,"Stopped"}, State}. %% <-- Stop the gen_server, 
   % {stop, {shutdown,"Stopped"}, "This is fom the caller", State}. %% <-- Stop the gen_server, and sed back a message to the caller
   % {stop, "unkonw error, ", State}. %% <-- Stop the gen_server with an error, will chrash the caller 



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
handle_cast(_Request, State) ->
    {noreply, State}.

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
handle_info(Info, State) ->
    io:format("info ~w~n", [Info]),
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
    io:format("the terminate is called, reason: ~p~n", [Reason]),
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
