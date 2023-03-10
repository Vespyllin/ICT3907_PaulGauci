defmodule XevalTest do
  use ExUnit.Case
  # import ExUnit.CaptureIO
  require Weaver
  require Demo.CalcClient

  setup_all do
    src_path = "./test/resources/dummy_target.ex"
    bin_path = "./_build/test/lib/xeval/ebin"

    :hml_eval.compile('./test/resources/prop_add_rec.hml', [
      {:outdir, to_charlist(bin_path)},
      :v
    ])

    Weaver.weave(src_path)
    Weaver.weave(src_path, "./test/resources", true)

    {:ok, %{}}
  end

  test "tmp" do
    pid = Dummy.Server.start(0)
    assert Demo.CalcClient.rpc(pid, {:add, 1, 2}) == {:ok, 3}
  end
end
