%%%-------------------------------------------------------------------
%%% @author gabriele
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. Dec 2016 18:39
%%%-------------------------------------------------------------------
-module(rest_rabbitmq).
-author("gabriele").
-include_lib("amqp_client/include/amqp_client.hrl").


%% API

-export([init/3, allowed_methods/2, terminate/3, handle/2]).

init(_Transport, Req, []) ->
    {ok, Req, undefined}.


allowed_methods(Req, State) ->
    {[[<<"HEAD">>, <<"GET">>, <<"POST">>]], Req, State}.


handle(Req, State) ->
    {Method, Req2} = cowboy_req:method(Req),
    HasBody = cowboy_req:has_body(Req2),
    {Value, Req3} = cowboy_req:qs_val(<<"value">>, Req2),
    {ok, Req4} = maybe_publish(Method, HasBody, Req3, Value),
    {ok, Req4, State}.

maybe_publish(<<"POST">>, true, Req, <<"message">>) ->
    {ok, MSG, Req2} = cowboy_req:body(Req),
    publish(MSG, Req2);
maybe_publish(<<"GET">>, false, Req, <<"cluster_info">>) ->
    MSG = cluster_info:cluster_status(),
    publish(list_to_binary(MSG), Req);
maybe_publish(<<"POST">>, false, Req, _Value) ->
    cowboy_req:reply(400, [], <<"Missing body.">>, Req);
maybe_publish(_, _, Req, _Value) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).

publish(MSG, Req) ->
    {_Status, Host} = application:get_env(slides, rabbitmq_host),
    {_Status, Port} = application:get_env(slides, rabbitmq_port),
    {ok, Connection} = amqp_connection:start(#amqp_params_network{host = Host, port = Port}),
    {ok, Channel} = amqp_connection:open_channel(Connection),
    Declare = #'queue.declare'{queue = <<"presentation_queue">>},
    #'queue.declare_ok'{} = amqp_channel:call(Channel, Declare),
    Publish = #'basic.publish'{exchange = <<"">>, routing_key = <<"presentation_queue">>},
    amqp_channel:cast(Channel, Publish, #amqp_msg{payload = MSG}),
    amqp_channel:close(Channel),
    amqp_connection:close(Connection),
    cowboy_req:reply(200, [
        {<<"content-type">>, <<"text/plain; charset=utf-8">>}
    ], "Message Sent", Req).

terminate(_Reason, _Req, _State) ->
    ok.


