defmodule RestSup.Supervisor do
  @moduledoc false
  use Supervisor

  require Logger



  def start_link() do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(Counter, [], restart: :permanent, shutdown: :infinity)
    ]

    supervise(children, strategy: :one_for_one, max_restarts: 10, max_seconds: 60)
  end


end