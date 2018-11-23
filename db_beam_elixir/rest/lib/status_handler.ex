defmodule StatusHandler do
  @moduledoc false

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

  def send_request(req0, state) do
    value = Counter.status()
    Logger.info "Status: #{inspect(value)}"

    {<<"[{\"status\": #{inspect(value)}}]">>, req0, state}
  end

end
