defmodule XevalTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "greets the world" do
    assert Xeval.hello() == :world
  end
end
