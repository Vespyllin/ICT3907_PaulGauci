defmodule DummyTargetTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  require Weaver
  require Dummy.Client
  # require Dummy.Server

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
    Dummy.Server.start(1)
  end

  # test "monitor unfolds on valid operation" do
  #   monitor_output =
  #     capture_io(fn ->
  #       send(self(), Dummy.Client.rpc(Dummy.Server.start(0), {:add, 1, 2}))

  #       :timer.sleep(100)
  #     end)

  #   assert_receive {:ok, 3}

  #   assert String.contains?(String.downcase(monitor_output), "unfolding")
  # end

  # test "monitor reaches \"no\" verdict when result invalidates {:add, a, b} -> {:ok, a + b} rule" do
  #   monitor_output =
  #     capture_io(fn ->
  #       send(self(), Dummy.Client.rpc(Dummy.Server.start(0), {:add, 0, 1}))

  #       :timer.sleep(100)
  #     end)

  #   assert_receive {:ok, 2}

  #   assert String.contains?(String.downcase(monitor_output), "reached verdict 'no'")
  # end
end
