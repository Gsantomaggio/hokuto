-module(dp_beam_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	io:format("My supervisor id~w ~n:",[self()]),
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
	Procs = [{fake_id,
		{gg_s, start_link, []},
		permanent,
		5000,
		worker,
		[gg_s]}],
	{ok, {{one_for_one, 1, 5}, Procs}}.
