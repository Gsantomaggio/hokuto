defmodule RabbitmqSup.Supervisor do
  @moduledoc false



  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(RabbitmqInt, [], restart: :permanent, shutdown: :infinity),
      worker(RabbitmqIntRetry, [], restart: :permanent, shutdown: :infinity)
    ]

    supervise(children, strategy: :one_for_one, max_restarts: 10, max_seconds: 60)
  end
end