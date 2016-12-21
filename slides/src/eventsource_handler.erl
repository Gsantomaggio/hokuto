-module(eventsource_handler).

-export([init/3]).
-export([info/3]).
-export([terminate/3]).

init(_Transport, Req, []) ->
    Headers = [{<<"content-type">>, <<"text/event-stream">>}],
    {ok, Req2} = cowboy_req:chunked_reply(200, Headers, Req),
    erlang:send_after(1000, self(), {message, "Tick"}),
    {loop, Req2, undefined, 5000}.

info({message, _Msg}, Req, State) ->
    % ok = cowboy_req:chunk(["id: ", id(), "\ndata: ", Msg, "\n\n"], Req),
    erlang:send_after(1000, self(), {message, [node() | nodes()]}),
    {loop, Req, State}.

terminate(_Reason, _Req, _State) ->
    ok.

