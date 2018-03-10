defmodule DB_BEAMTest do
  use ExUnit.Case
  doctest DB_BEAM

  test "greets the world" do
    assert DB_BEAM.hello() == :world
  end
end
