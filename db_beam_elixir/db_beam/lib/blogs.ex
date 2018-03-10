defmodule Blogs do
  @moduledoc false
  require Logger

  def log_info(value) do
    Logger.info fn ->
      value
      #<> ":" <> "#{inspect(params)}"
    end
  end


end
