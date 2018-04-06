%%%-------------------------------------------------------------------
%%% @author GaS
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Mar 2018 14:21
%%%-------------------------------------------------------------------
-module(dp_pattern_m).
-author("GaS").

%% API
-export([parse_year/1, list_to_int_hash/1, parse_protocol/1, new_v3_url/1]).


%%  dp_pattern_m:parse(<<"2018-01-02T13:06:02">>).

parse_year(<<Year:4/bytes,
    "-",
    Month:2/bytes,
    "-",
    Date:2/bytes,
    "T",
    Hour:2/bytes,
    ":",
    Minute:2/bytes,
    ":",
    Second:2/bytes,
    "">>) ->
    to_date(Year, Month, Date, Hour, Minute, Second).

to_date(Year, Month, Date, Hour, Minute, Second) ->
    {{binary_to_integer(Year),
        binary_to_integer(Month),
        binary_to_integer(Date)},
        {binary_to_integer(Hour),
            binary_to_integer(Minute),
            binary_to_integer(Second)}}.




%% protocol
%% 2 bytes version
%% 10 bytes header
%% undef body

%% <<"01:header_010:the body">>
parse_protocol(<<Version:2/bytes, ":", Header:10/bytes, ":", Body/binary>> = P) ->
    io:format("The full protocol is: ~p ~n", [P]),
    io:format("Version  ~p, Header: ~p, body: ~p", [Version, Header, Body]);
%% <<"01:header_0011:the body">>
parse_protocol(<<Version:2/bytes, ":", Header:11/bytes, ":", Body/binary>>) ->
    io:format(" 11 bytes headers !Version  ~p, Header: ~p, body: ~p", [Version, Header, Body]);
parse_protocol(Unknown) ->
    io:format(" Unkonw protocol: ~p", [Unknown]).





list_to_int_hash(Value) ->
    <<B:128>> = crypto:hash(md5, Value),
    B.


new_v3_url(Data) ->
    new_v3_url(Data, binary_standard).

new_v3_url(Data, Option) ->
    uuid:uuid_to_string(uuid:get_v3_compat(url, Data), Option).


