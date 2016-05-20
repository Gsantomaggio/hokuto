%%%-------------------------------------------------------------------
%%% @author gabriele
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Sep 2015 09:44
%%%-------------------------------------------------------------------
-module(master_monitor).
-author("gabriele").
%% API
-export([start_link/0,
    stop/0,
    handle_call/3,
%%    handle_call/2,
    handle_info/2,
    terminate/2,
    code_change/3,
    init/1, handle_cast/2, multi_call/0]).


-behaviour(gen_server).
-define(SERVER, ?MODULE).


start_link() ->
    io:format("***** Starting monitoring ~p ~n", [?MODULE]),
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    io:format("***** Setting up net_kernel configurations, nodename:~p   ~n", [node()]),
    process_flag(trap_exit, true),
%%    net_kernel:start([master, shortnames]),
    _ = net_kernel:monitor_nodes(true, []),
    io:format("***** net_kernel configurations done, nodename:~p   ~n", [node()]),
    {ok, []}.


multi_call() ->
%%   Replies = gen_server:multi_call(?SERVER, {message, hello}),
    {Replies, BadNodes} = gen_server:multi_call([node() | nodes()], ?SERVER, {message, multicall}, 2000),
    io:format("Node Replies ~p - Bad Nodes ~p ~n", [Replies, BadNodes]),
    ok.


print_nodes() ->
    io:format("Cluster status:~p ~p ~n", [node(), nodes()]),
    ok.


% Stopping server asynchronously
stop() ->
    io:format("Stopping~n"),
    gen_server:cast(?MODULE, shutdown).



handle_call({message, multicall}, From, State) ->
    {Pid, {_Ref, _Node}} = From,
    io:format("Got a message from  Pid: ~p Node: ~p  ~n", [Pid, From]),
    {reply, ok, State}.


handle_info({nodeup, Node}, State) ->
    io:format("Node ~p is up ~n", [Node]),
    print_nodes(),
    {noreply, State};


handle_info({nodedown, Node}, State) ->
    io:format("Node ~p  is down ~n", [Node]),
    print_nodes(),
    {noreply, State}.


handle_cast(Msg, State) ->
    io:format("cast ~p   ~n", [Msg]),
    {reply, ignored, State}.


terminate(_Reason, _State) ->
    io:format("Stopping~n"),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%%
%%check_virtual_network(Virtual_Network) when is_atom(Virtual_Network) ->
%%    [];
%%check_virtual_network(Virtual_Network) ->
%%    [{ip, Virtual_Network}, {reuseaddr, false}, {active, false}].
%%
%%print_network(Virtual_Network) when is_atom(Virtual_Network) ->
%%    io:format("NO Virtual network ~p ~n ", [Virtual_Network]);
%%print_network(Virtual_Network) ->
%%    io:format("Virtual network ~p ~n ", [Virtual_Network]).
%%
%%

%%spwan_connection(_Max, Count, _P, _Pid) when Count == 0 -> done;
%%
%%spwan_connection(Max, Count, Virtual_Network, Pid) ->
%%    spawn(?MODULE, open_connection, [Max, Count, Virtual_Network, Pid]),
%%    timer:sleep(80),
%%    spwan_connection(Max, Count - 1, Virtual_Network, Pid),
%%    done.

%%
%%
%%
%%print_progress(Max, Count, Pid, Server_info) when ((Max - Count) == Max) ->
%%    Pid ! {finished, Max, Count, Server_info};
%%print_progress(Max, Count, Pid, Server_info) when ((Max - Count) rem 100) == 0 ->
%%    Pid ! {update, Max, Count, Server_info};
%%print_progress(_Max, _Count, _Pid, _Server_info) -> done.
%%
%%
%%
%%console_update() ->
%%    receive
%%        {update, Max, Count, Server_info} ->
%%            io:format("Virtual Interface ~p Version: ~p  ~n ", [Server_info#server_info.virtual_interface, Server_info#server_info.version]),
%%            io:format("Opened connections ~p from ~p  ip1: ~p count1: ~p ip2: ~p count2: ~p  ~n", [(Max - Count), Max, Server_info#server_info.ip1, Server_info#server_info.count1, Server_info#server_info.ip2, Server_info#server_info.count2]);
%%        {finished, Max, Count, _Server_info} ->
%%            io:format("Finished ~p ~n ", [Max])
%%    end,
%%    console_update().
%%
%%
%%
%%
%%test_conn(Args) ->
%%    Version = 18,
%%    io:format("******** Erlang Test Connections Version:~p ****************\n ", [Version]),
%%    io:format("Connection Params: ~p\n", [Args]),
%%%%    lists:foreach(fun(Arg) -> io:format("~p~n", [Arg]) end, Args),
%%    B = lists:nth(1, Args),
%%    io:format("Number of connections Param : ~p\n", [B]),
%%
%%
%%    Virtual_IP = lists:nth(2, Args),
%%    io:format("Virtual Network Param : ~p\n", [Virtual_IP]),
%%    print_network(Virtual_IP),
%%    timer:sleep(1000),
%%
%%    Server_info = #server_info{ip1 = "",
%%        ip2 = "",
%%        count1 = 0,
%%        count2 = 0,
%%        virtual_interface = Virtual_IP,
%%        version = Version},
%%    Pid_Console = spawn(?MODULE, console_update, []),
%%    spawn(?MODULE, open_connection, [B, B, Virtual_IP, Pid_Console, Server_info]),
%%%%    spwan_connection(B, B, Virtual_IP, Pid_Console),
%%    io:get_line("--"),
%%    ok.