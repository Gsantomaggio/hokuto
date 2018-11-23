defmodule Counter do
  @moduledoc false
  use GenServer
  require Logger
  def inc_and_get() do
    GenServer.call(__MODULE__, :count)
  end

  def status() do
    GenServer.call(__MODULE__, :status)
  end

  def report() do
    GenServer.call(__MODULE__, :internal)
  end

  def start_link(state) do
    Logger.info("Counter start link")
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def code_change(old_vsn, state, extra) do
    Logger.info(" Changing code")
  end

  @impl true
  def init(_opts) do
    Logger.info("Init counter module")
    {:ok, %{:count => 0}}
  end

  @impl true
  def handle_call(:count, _from, state) do
    {:ok, value} = Map.fetch(state, :count)
    {:reply, value, Map.put(state, :count, value + 1)}
  end

  @impl true
  def handle_call(:status, _from, state) do
    {:ok, value} = Map.fetch(state, :count)
    {:reply, value, state}
  end

  @impl true
  def handle_call(:internal, _from, state) do
    {:ok, value} = Map.fetch(state, :count)
    {:reply, {length(Process.list()), :erlang.memory(:processes)}, state}
  end
end