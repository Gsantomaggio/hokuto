defmodule BugHandler do
  @moduledoc false

  ##% LOCAL TRACE
  ##  :dbg.start() :dbg.tracer()
  ##  :dbg.tpl BugHandler,  :parse, []
  ##  :dbg.p(:all,[:call]) or :dbg.p(:all, [:c,:timestamp])
  ##  :dbg.stop_clear()
  ## http://erlang.org/doc/man/dbg.html#p-2
  ## :dbg.stop()
  ## try again with
  ## :dbg.tpl BugHandler, :parse, [{:_, [], [{:return_trace}]}]
  ## :dbg.tpl BugHandler, :parse, [{:_, [], [{:caller}]}]

  ## :dbg.stop()
  ## try again with
  # recon_trace:calls({'Elixir.BugHandler', parse,  []}, 100, [{scope, local}]).
  # recon_trace:calls({'Elixir.BugHandler', doing_stuff_with_param,  []}, 100, [{scope, local}]).
  # recon_trace:calls({'Elixir.BugHandler', parse,  fun([N]) when N > 3 -> return_trace() end}, 100, [{scope, local}]).
  # recon_trace:calls({'Elixir.BugHandler', parse,  fun([_]) -> return_trace() end}, 100, [{scope, local}]).

  require Logger

  def init(req, opts) do
    {:cowboy_rest, req, opts}
  end


  def allowed_methods(req0, state) do
    req = :cowboy_req.set_resp_header(<<"access-control-allow-origin">>, <<"*">>, req0)
    {[<<"GET">>], req, state}
  end

  def content_types_provided(req, state) do
    {[{{<<"application">>, <<"json">>, []}, :send_request}], req, state}
  end

  def doing_stuff_with_param(param) when param > 5 do
    param * 3
  end
  def doing_stuff_with_param(param) do
    param
  end

  def  parse(param) do
    doing_stuff_with_param(param)
  end

  def send_request(req0, state) do
    %{:param => param} = :cowboy_req.match_qs([{:param, [], :undefined}], req0)
    intvalue = :erlang.list_to_integer(:erlang.binary_to_list(param))
    Logger.info "Status: #{inspect(param)}"
    value = parse(intvalue)
    {<<"[{\"hello \": #{inspect(value)}}]">>, req0, state}
  end

end
