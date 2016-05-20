%%%-------------------------------------------------------------------
%%% @author GaS
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Apr 2016 20:46
%%%-------------------------------------------------------------------
-module(task_executor).
-author("GaS").

-behaviour(gen_server).

%% API
-export([start_link/0, start_task/0,
    abcast/0, do_work/1, status/0, start_task_s/1]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).
-define(MAX_TASKS, 3).

-record(state, {status = idle, running_task = 0, max_tasks = ?MAX_TASKS}).

%%-record(user, {name, surname}).


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




start_task_s(TimeOut) ->
    {Replies, BadNodes} = gen_server:multi_call(nodes(), ?SERVER, {command, execute_task_s, node()}, TimeOut),
    io:format("Node Replies ~p - Bad Nodes ~p ~n", [Replies, BadNodes]),
    ok.



start_task() ->
    {Replies, BadNodes} = gen_server:multi_call(nodes(), ?SERVER, {command, execute_task, node()}, 20000),
    io:format("Node Replies ~p - Bad Nodes ~p ~n", [Replies, BadNodes]),
    ok.

status() ->
    {Replies, BadNodes} = gen_server:multi_call(nodes(), ?SERVER, {command, status}, 20000),
    io:format("Status, Node Replies ~p - Bad Nodes ~p ~n", [Replies, BadNodes]),
    ok.


abcast() ->
    R = gen_server:abcast(?SERVER, {command, async}),
%%    gen_server:abcast([node(), nodes()], ?SERVER, {message, async_distribution}),
    io:format("abcast  ~p ~n", [R]),
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
init([]) ->
    io:format("************** Task executors ****************** ~n"),
    _ = net_kernel:monitor_nodes(true, []),
    {ok, #state{}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------

handle_call({command, execute_task_s, NodeFrom}, _From, State = #state{running_task = _F})->
%%    {Pid, _} = From,
    io:format("**** Sync Task accepeted started! - Sender Node: ~p ********~n", [NodeFrom]),
    timer:sleep(5000),
    NewState = State#state{running_task = 0, status = finished},
    {reply, NewState, NewState};



handle_call({command, execute_task, NodeFrom}, _From, State = #state{running_task = F}) when F < ?MAX_TASKS ->
%%    {Pid, _} = From,
    io:format("**** Task accepeted started! - Sender Node: ~p ********~n", [NodeFrom]),
    spawn(?MODULE, do_work, [NodeFrom]),
    NewState = State#state{running_task = F + 1, status = task_accepted},
    {reply, NewState, NewState};
handle_call({command, execute_task, _NodeFrom}, _From, State = #state{running_task = F}) when F >= ?MAX_TASKS ->
    io:format("****  Task rejected. Running tasks ~p  ~n", [F]),
    NewState = State#state{status = task_rejected},
    {reply, NewState, NewState};
handle_call({command, finished}, From, State = #state{running_task = F}) ->
    {Pid, _} = From,
    io:format("**** Task finished: ~p  ~n", [Pid]),
    NewState = State#state{running_task = F - 1},
    {reply, NewState, NewState};
handle_call({command, status}, _From, State) ->
    NewReply = State#state{status = status},
    {reply, NewReply, State}.


simulate_search([], _NodeFrom) -> [];
simulate_search([H | T], NodeFrom) when length(T) > 0 ->
    [timer:sleep(1000), io:format("**** Working... ~p ~n ", [H]),
        gen_server:abcast([NodeFrom], ?SERVER, {command, progress, node(), H}) | [X || X <- simulate_search(T, NodeFrom)]];
simulate_search([H | T], NodeFrom) ->
    [timer:sleep(1000), io:format("**** Last Step... ~p ~n ", [H]),
        gen_server:abcast([NodeFrom], ?SERVER, {command, finished, node(), H}) | [X || X <- simulate_search(T, NodeFrom)]].



do_work(NodeFrom) ->
    simulate_search([1, 2, 3, 4, 5], NodeFrom),
    gen_server:call(?MODULE, {command, finished}),
    ok.


print_nodes() ->
    io:format("Cluster status:~p ~p ~n", [node(), nodes()]),
    ok.

handle_info({nodeup, Node}, State) ->
    io:format("Node ~p is up ~n", [Node]),
    print_nodes(),
    {noreply, State};


handle_info({nodedown, Node}, State) ->
    io:format("Node ~p  is down ~n", [Node]),
    print_nodes(),
    {noreply, State}.


%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
handle_cast({command, Status, Task_Node, H}, State) ->
%%    io:format("Received status: ~p from node: ~p  value: ~p ~n", [Status, Task_Node, H]),
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
