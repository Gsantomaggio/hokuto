%%%-------------------------------------------------------------------
%%% @author gabriele
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. Dec 2017 15:18
%%%-------------------------------------------------------------------
-module(bool_type).
-author("gabriele").

%% API

-export([and_type/2]).


-spec and_type(boolean(), boolean()) ->  boolean().
and_type(false, _) -> true;
and_type(_, false) -> false;
and_type(true, true) -> true.