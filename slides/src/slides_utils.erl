%%%-------------------------------------------------------------------
%%% @author gabriele
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Feb 2017 11:07
%%%-------------------------------------------------------------------
-module(slides_utils).
-author("gabriele").

%% API
-export([as_string/1, to_binary/1, node_name/1, node_name_parse/3, node_name_parse/2, node_prefix/0]).


%%--------------------------------------------------------------------
%% @doc
%% Return the passed in value as a string.
%% @end
%%--------------------------------------------------------------------
-spec as_string(Value :: atom() | binary() | integer() | string())
        -> string().
as_string([]) -> "";
as_string(Value) when is_atom(Value) ->
    as_string(atom_to_list(Value));
as_string(Value) when is_binary(Value) ->
    as_string(binary_to_list(Value));
as_string(Value) when is_integer(Value) ->
    as_string(integer_to_list(Value));
as_string(Value) when is_list(Value) ->
    lists:flatten(Value);
as_string(Value) ->
    io:format("Unexpected data type for list value: ~p~n",
        [Value]),
    Value.


-spec to_binary(Val :: binary() | list() | atom() | integer()) -> binary().
to_binary(Val) when is_list(Val)    -> list_to_binary(Val);
to_binary(Val) when is_atom(Val)    -> atom_to_binary(Val, utf8);
to_binary(Val) when is_integer(Val) -> integer_to_binary(Val);
to_binary(Val)                      -> Val.



%%--------------------------------------------------------------------
%% @doc
%% Return the proper node name for clustering purposes
%% @end
%%--------------------------------------------------------------------
-spec node_name(Value :: atom() | binary() | string()) -> atom().
node_name(Value) when is_atom(Value) ->
    node_name(atom_to_list(Value));
node_name(Value) when is_binary(Value) ->
    node_name(binary_to_list(Value));
node_name(Value) when is_list(Value) ->
    case lists:member($@, Value) of
        true ->
            list_to_atom(Value);
        false -> io:format("FAAAALSEEE")
    end.




-spec node_prefix() -> string().
node_prefix() ->
    Value = node(),
    lists:nth(1, string:tokens(Value, "@")).


%%--------------------------------------------------------------------
%% @doc
%% Properly deal with returning the hostname if it's made up of
%% multiple segments like www.rabbitmq.com, returning www, or if it's
%% only a single segment, return that.
%% @end
%%--------------------------------------------------------------------
-spec node_name_parse(Segments :: integer(),
    Value :: string(),
    Parts :: [string()])
        -> string().
node_name_parse(1, Value, _) -> Value;
node_name_parse(_, _, Parts) ->
    as_string(lists:nth(1, Parts)).


%%--------------------------------------------------------------------
%% @doc
%% Continue the parsing logic from node_name_parse/1. This is where
%% result of the IPv4 check is processed.
%% @end
%%--------------------------------------------------------------------
-spec node_name_parse(IsIPv4 :: true | false, Value :: string())
        -> string().
node_name_parse(true, Value) -> Value;
node_name_parse(false, Value) ->
    Parts = string:tokens(Value, "."),
    node_name_parse(length(Parts), Value, Parts).