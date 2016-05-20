%%%-------------------------------------------------------------------
%%% @author GaS
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Apr 2016 20:46
%%%-------------------------------------------------------------------
-module(ex_distr).
-author("GaS").

-behaviour(gen_server).

%% API
-export([start_link/0, multi_call/0, multi_call/1, multi_call_f/1, 
    abcast/0, spwan_multi_call/1]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {ciao}).

%%%===================================================================
%%% API
%%%===================================================================

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


multi_call() ->
    multi_call(1500),
    ok.

multi_call(Wait) ->
%%   Replies = gen_server:multi_call(?SERVER, {message, hello}),
    {Replies, BadNodes} = gen_server:multi_call([node() | nodes()], ?SERVER, {message, multicall, Wait, node()}, 2000),
    io:format("Node Replies ~p - Bad Nodes ~p ~n", [Replies, BadNodes]),
    ok.

multi_call_f(Wait) ->
%%   Replies = gen_server:multi_call(?SERVER, {message, hello}),
    {Replies, BadNodes} = gen_server:multi_call([node() | nodes()], ?SERVER, {message, fnc, fun
        ()   ->
            timer:sleep(Wait)
    end, node()}, 2000),
    io:format("Node Replies ~p - Bad Nodes ~p ~n", [Replies, BadNodes]),
    ok.






abcast() ->
    R = gen_server:abcast(?SERVER, {message, async}),
%%    gen_server:abcast([node(), nodes()], ?SERVER, {message, async_distribution}),
    io:format("abcast  ~p ~n", [R]),
    ok.


spwan_multi_call(Wait) ->
    spawn(?MODULE, multi_call, [Wait]),
    ok.


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
    io:format("Init done ~n"),
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
handle_call({message, multicall, Wait, NodeFrom}, From, State) ->
    {Pid, _} = From,
    timer:sleep(Wait),
    io:format("Got a message from  Pid: ~p NodeFrom: ~p  Wait: ~p ~n", [Pid, NodeFrom, Wait]),
    {reply, self(), State};
handle_call({message, fnc, Fnc, NodeFrom}, From, State) ->
    {Pid, _} = From,
    io:format("Got a function from  Pid: ~p NodeFrom: ~p  ~n", [Pid, NodeFrom]),
    Fnc(),
    {reply, self(), State};


handle_call({message, gotmessage}, From, State) ->
    io:format("Thank you I got message from  ~p ~n", [From]),
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
handle_cast(Request, State) ->
    io:format("cast ~p ~n", [Request]),
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
handle_info(_Info, State) ->
    io:format("info"),
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
terminate(_Reason, _State) ->
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
