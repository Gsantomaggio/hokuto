%%%-------------------------------------------------------------------
%%% @author gabriele
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Dec 2017 09:27
%%%-------------------------------------------------------------------
-module(ds_processes).
-author("gabriele").

%% API
-export([f/0, sup_f/0, spawn_sup_f/0, sup_f_no/0, monitor_f/1, spawn_sup_f_no/0, spawn_with_dictonary/0]).


f() -> receive
           {msg, MSG} -> io:format("Got message:~p~n", [MSG]), f();
           {close} -> io:format("Good bye", [])
       end.

%% won't delete the chain, but handle the Exit flag.
sup_f() ->
    process_flag(trap_exit, true), %% can apply more than one time, it is always one
    PID = spawn_link(fun f/0),
    PID_Monitor = spawn(ds_processes, monitor_f, [PID]),
    io:format("TEE - The sup PID is: ~p and the f is PIDF:~p PID_Monitor:~p ~n", [self(), PID, PID_Monitor]), %% note the self() is always the same
    receive
        {'EXIT', B, Reason} ->
            io:format("TEE - Received 'EXIT' Message PID:~p Reason:~p~n", [B, Reason]),

            case Reason of
                normal -> io:format("TEE - Stopped normally ~n", []);
                Value ->
                    io:format("TEE - Unexpected Stop ~p going to restart it ~n", [Value]),
                    sup_f() %% This is for restart
            end;

        Value -> io:format("sup_f ~p", [Value])
    end.


%% try with exit(PID, normal)
%% and with exit(PID, my_error)
%% for example exit(list_to_pid("<0.650.0>"), my_errror).
%% The "The sup PID" is always the same 'cause of trap_exit
%% use always process info to check the status and show the links/mornitor flag
%% process_info(list_to_pid( SPANNED_PID ),monitored_by). who is monitor
%% process_info(list_to_pid( PID_Monitor  ),monitors). who is monitoring

spawn_sup_f() -> spawn(fun sup_f/0).





%% diffent between process flag and not, chain delete
%% try to kill the super here to see the chain delete
sup_f_no() ->
    PID = spawn_link(fun f/0),
    PID_Monitor = spawn(ds_processes, monitor_f, [PID]),
    io:format("TED - The sup PID is: ~p and the f is PIDF:~p PID_Monitor:~p ~n", [self(), PID, PID_Monitor]), %% note the self() is always the same
    receive
        Value -> io:format("sup_f_no ~p", [Value])
    end.



spawn_sup_f_no() -> spawn(fun sup_f_no/0).

monitor_f(Pid) ->
    Ref = erlang:monitor(process, Pid),
    io:format("Monitor Ref:~p ~n", [Ref]),
    receive
        {'DOWN', MonitorReference, process, Pid, Reason} ->
            io:format("I am a monitor PID:~p Reason:~p  MonitorReference:~p ~n", [Pid, Reason, MonitorReference])
    end.


spawn_with_dictonary() -> proc_lib:spawn(fun f/0).

