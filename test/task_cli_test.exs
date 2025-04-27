defmodule TaskCliTest do
  use ExUnit.Case
  doctest TaskCli

  test "greets the world" do
    assert TaskCli.hello() == :world
  end
end
