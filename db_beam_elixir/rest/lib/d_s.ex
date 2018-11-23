defmodule DS do
  @moduledoc false

  require Logger

  def s(status) do
    decStatus = case status do
      :w -> :waiting
      :ra -> :runnable
      :rn -> :running
      :g -> :garbage_collecting
    end

    l =
      length(
        Enum.filter(
          :erlang.processes,
          fn (x) -> :erlang.process_info(x, [:status]) == [{:status, decStatus}] end
        )
      )

    Logger.info "Status #{decStatus}, processes #{inspect(l)}"
  end

  def loop(0, _), do:
    :ok
  def loop(n, f) do
    f.(n - 1, f) end

  def busy_fun() do
    spawn (fn -> loop(10000000, &loop/2) end)
  end


  def spawn_them(n) do
    for _ <- Enum.to_list(1..n), do: busy_fun()
  end

  def get_status() do
    Enum.sort(for x <- :erlang.processes(), do: :erlang.process_info(x, [:status]))
  end

  # check erlang:system_info(schedulers_online).
  #%% length(erlang:processes()).
  #%% execute using +S 1 to 4 rel/vm.args
  #%% note about getstatus and process_info with partial result
  #%% describe the status

  def run_them(n) do
    spawn_them(n);
    s(:rn);
    s(:ra);
    s(:w);
    s(:g)
  end

  def l() do
    Logger.info "Processes num: #{length(:erlang.processes())}"
  end

end

