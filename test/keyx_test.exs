defmodule KeyxTest do
  use ExUnit.Case
  doctest Keyx

  test "greets the world" do
    assert Keyx.hello() == :world
  end
end
