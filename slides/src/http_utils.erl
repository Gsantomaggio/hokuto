%%%-------------------------------------------------------------------
%%% @author gabriele
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. Feb 2017 16:05
%% COPIED FROM https://github.com/aweber/rabbitmq-autocluster/blob/master/src/autocluster_httpc.erl
%%%-------------------------------------------------------------------
-module(http_utils).
-author("gabriele").


%% API
-export([build_query/1,
    build_path/1,
    build_uri/5,
    delete/6,
    get/5,
    get/7,
    post/6,
    put/6]).

%% Export all for unit tests
-ifdef(TEST).
-compile(export_all).
-endif.


-define(CONTENT_JSON, "application/json").
-define(CONTENT_URLENCODED, "application/x-www-form-urlencoded").

-type path_component() :: atom() | binary() | integer() | string().
-export_type([path_component/0]).

%% @public
%% @doc Build the path from a list of segments
%% @end
%%
-spec build_path([path_component()]) -> string().
build_path(Args) ->
    build_path(Args, []).


%% @public
%% @spec build_path(string(), string()) -> string()
%% @doc Build the path from a list of segments
%% @end
%%
build_path([Part|Parts], Path) ->
    build_path(Parts, string:join([Path, percent_encode(Part)], "/"));
build_path([], Path) -> Path.


%% @public
%% @spec build_uri(Scheme, Host, Port, Path, QArgs) -> string()
%% where Scheme = string()
%%       Host = string()
%%       Port = integer()
%%       Path = string()
%%       QArgs = proplist()
%% @doc Build the request URI
%% @end
%%
build_uri(Scheme, Host, Port, Path, QArgs) ->
    build_uri(string:join([Scheme, "://", Host, ":", as_string(Port)], ""), Path, QArgs).


%% @public
%% @spec build_uri(string(), string(), proplist()) -> string()
%% @doc Build the requst URI for the given base URI, path and query args
%% @end
%%
build_uri(Base, Path, []) ->
    string:join([Base, build_path(Path)], "");
build_uri(Base, Path, QArgs) ->
    string:join([Base, string:join([build_path(Path),
        build_query(QArgs)], "?")], "").


%% @public
%% @spec build_query(proplist()) -> string()
%% @doc Build the query parameters string from a proplist
%% @end
%%
build_query(Args) ->
    build_query(Args, []).


%% @public
%% @spec build_query(proplist(), string()) -> string()
%% @doc Build the query parameters string from a proplist
%% @end
%%
build_query([{Key,Value}|Args], Parts) when is_atom(Key) =:= true ->
    build_query(Args, lists:merge(Parts, [string:join([percent_encode(Key),
        percent_encode(Value)], "=")]));
build_query([{Key,Value}|Args], Parts) ->
    build_query(Args, lists:merge(Parts, [string:join([percent_encode(Key),
        percent_encode(Value)], "=")]));
build_query([Key|Args], Parts) ->
    build_query(Args, lists:merge(Parts, [percent_encode(Key)]));
build_query([], Parts) ->
    string:join(Parts, "&").


%% @public
%% @spec get(Scheme, Host, Port, Path, Args) -> Result
%% @where Scheme = string(),
%%        Host   = string(),
%%        Port   = integer(),
%%        Path   = string(),
%%        Args   = proplist(),
%%        Result = {ok, mixed}|{error, Reason::string()}
%% @doc Perform a HTTP GET request
%% @end
%%
get(Scheme, Host, Port, Path, Args) ->
    get(Scheme, Host, Port, Path, Args, [], []).


%% @public
%% @spec get(Scheme, Host, Port, Path, Args, Headers) -> Result
%% @where Scheme  = string(),
%%        Host    = string(),
%%        Port    = integer(),
%%        Path    = string(),
%%        Args    = proplist(),
%%        Headers = proplist(),
%%        HttpOpts = proplist(),
%%        Result  = {ok, mixed}|{error, Reason::string()}
%% @doc Perform a HTTP GET request
%% @end
%%
get(Scheme, Host, Port, Path, Args, Headers, HttpOpts) ->
    URL = build_uri(Scheme, Host, Port, Path, Args),
    Response = httpc:request(get, {URL, Headers}, HttpOpts, []),
    parse_response(Response).


%% @public
%% @spec post(Scheme, Host, Port, Path, Args, Body) -> Result
%% @where Scheme = string(),
%%        Host   = string(),
%%        Port   = integer(),
%%        Path   = string(),
%%        Args   = proplist(),
%%        Body   = string(),
%%        Result = {ok, mixed}|{error, Reason::string()}
%% @doc Perform a HTTP POST request
%% @end
%%
post(Scheme, Host, Port, Path, Args, Body) ->
    URL = build_uri(Scheme, Host, Port, Path, Args),
    Response = httpc:request(post, {URL, [], ?CONTENT_JSON, Body}, [], []),
    parse_response(Response).


%% @public
%% @spec put(Scheme, Host, Port, Path, Args, Body) -> Result
%% @where Scheme = string(),
%%        Host   = string(),
%%        Port   = integer(),
%%        Path   = string(),
%%        Args   = proplist(),
%%        Body   = string(),
%%        Result = {ok, mixed}|{error, Reason::string()}
%% @doc Perform a HTTP PUT request
%% @end
%%
put(Scheme, Host, Port, Path, Args, Body) ->
    URL = build_uri(Scheme, Host, Port, Path, Args),
    Response = httpc:request(put, {URL, [], ?CONTENT_URLENCODED, Body}, [], []),
    parse_response(Response).


%% @public
%% @spec delete(Scheme, Host, Port, Path, Args, Body) -> Result
%% @where Scheme = string(),
%%        Host   = string(),
%%        Port   = integer(),
%%        Path   = string(),
%%        Args   = proplist(),
%%        Body   = string(),
%%        Result = {ok, mixed}|{error, Reason::string()}
%% @doc Perform a HTTP DELETE request
%% @end
%%
delete(Scheme, Host, Port, Path, Args, Body) ->
    URL = build_uri(Scheme, Host, Port, Path, Args),
    Response = httpc:request(delete, {URL, [], ?CONTENT_URLENCODED, Body}, [], []),
    parse_response(Response).


%% @private
%% @spec decode_body(mixed) -> list()
%% @doc Decode the response body and return a list
%% @end
%%
decode_body(_, []) -> [];
decode_body(?CONTENT_JSON, Body) ->
    case rabbit_json:try_decode(rabbit_data_coercion:to_binary(Body), []) of
        {ok, Value} -> Value;
        {error,_}   -> []
    end.


%% @private
%% @spec parse_response(Response) -> {ok, string()} | {error, mixed}
%% @where Response = {status_line(), headers(), Body} | {status_code(), Body}
%% @doc Decode the response body and return a list
%% @end
%%
parse_response({error, Reason}) ->
    {error, Reason};

parse_response({ok, 200, Body})  -> {ok, decode_body(?CONTENT_JSON, Body)};
parse_response({ok, 201, Body})  -> {ok, decode_body(?CONTENT_JSON, Body)};
parse_response({ok, 204, _})     -> {ok, []};
parse_response({ok, Code, Body}) ->
    {error, integer_to_list(Code)};

parse_response({ok, {{_,200,_},Headers,Body}}) ->
    {ok, decode_body(proplists:get_value("content-type", Headers, ?CONTENT_JSON), Body)};
parse_response({ok,{{_,201,_},Headers,Body}}) ->
    {ok, decode_body(proplists:get_value("content-type", Headers, ?CONTENT_JSON), Body)};
parse_response({ok,{{_,204,_},_,_}}) -> {ok, []};
parse_response({ok,{{_Vsn,Code,_Reason},_,Body}}) ->
    {error, integer_to_list(Code)}.


%% @private
%% @spec percent_encode(Value) -> string()
%% @where
%%       Value = atom() or binary() or integer() or list()
%% @doc Percent encode the query value, automatically
%%      converting atoms, binaries, or integers
%% @end
%%
percent_encode(Value) ->
    http_uri:encode(as_string(Value)).



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


