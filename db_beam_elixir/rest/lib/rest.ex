defmodule REST do
  @moduledoc """
  Documentation for REST.
  """
  require Logger

  def init_ssh() do
    Logger.info " Starting ssh on 8099"
    :ssh.start()
    result = :ssh.daemon(8099, [{:system_dir, 'ssh_dir'}, {:user_dir, 'ssh_dir'}])
    Logger.info " shh daemon status: #{inspect(result)}"
  end

  def start(_type, _args) do
    init_ssh()
    import Supervisor.Spec
    children = [
      %{
        id: Counter,
        start: {Counter, :start_link, [:state]}
      }
    ]
    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

    Logger.info " Starting web server, port: 8080"
    dispatch_config = build_dispatch_config()
    {:ok, _} = :cowboy.start_clear(
      :my_http_listener,
      [{:port, 8080}],
      %{
        :env => %{
          :dispatch => dispatch_config
        }
      }
    )
  end

  def build_dispatch_config do
    :cowboy_router.compile(
      [
        {
          :_,
          [
            {"/counter", CounterHandler, []},
            {"/status", StatusHandler, []},
            {"/bug", BugHandler, []},
          ]
        }
      ]
    )
  end

  def enable_trace() do
    :dbg.start
    :dbg.tracer
  end

  def strop_trace() do
    :dbg.stop_clear
  end


end
