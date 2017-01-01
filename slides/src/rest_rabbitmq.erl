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
    {ok, Req3} = maybe_publish(Method, HasBody, Req2),
    {ok, Req3, State}.

maybe_publish(<<"POST">>, true, Req) ->
    {ok, MSG, Req2} = cowboy_req:body(Req),
    publish(MSG, Req2);
maybe_publish(<<"POST">>, false, Req) ->
    cowboy_req:reply(400, [], <<"Missing body.">>, Req);
maybe_publish(_, _, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).

publish(MSG, Req) ->
    {_Status, Host} = application:get_env(slides, rabbitmq_host),
    {ok, Connection} = amqp_connection:start(#amqp_params_network{host = Host}),
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


