defmodule UcatTest do
  use ExUnit.Case
  doctest Ucat

  test "greets the world" do
    assert Ucat.hello() == :world
  end
end
