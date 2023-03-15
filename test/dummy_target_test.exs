defmodule DummyTargetTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  require Weaver
  require Dummy.Client

  @src_path "./test/resources"
  @bin_path "./_build/test/lib/xeval/ebin"
  @mon "./prop_add_rec.hml"

  def load_monitor(file_name) do
    File.write!(@mon, File.read!("#{@src_path}/#{file_name}"))

    res =
      capture_io(fn ->
        :hml_eval.compile(to_charlist(@mon), [{:outdir, to_charlist(@bin_path)}, :v])
      end)

    if(String.contains?(String.downcase(res), "error")) do
      raise("Bad monitor syntax in \"#{file_name}\"\n#{res}")
    end
  end

  setup_all do
    Weaver.weave("#{@src_path}/dummy_target.ex")
    Weaver.weave("#{@src_path}/dummy_target.ex", "./test/resources", true)

    {:ok, %{}}
  end

  @tag :skip
  test "Attaching a monitor to a function without arguments" do
    load_monitor("dummy_spawn_noarg.hml")

    io =
      capture_io(fn ->
        Dummy.Server.spawn_start()
        :timer.sleep(100)
      end)

    assert String.contains?(String.downcase(io), "instrumenting monitor")
  end

  @tag :skip
  test "Attaching a monitor to a function with arguments" do
    load_monitor("dummy_arg.hml")

    io =
      capture_io(fn ->
        Dummy.Server.spawn_arg()
        :timer.sleep(100)
      end)

    assert String.contains?(String.downcase(io), "instrumenting monitor")
  end

  @tag :todo
  test "Monitor verdicts based on conditions regarding argument" do
  end

  @tag :skip
  test "Not attaching a monitor to a function not specified in the monitor specification" do
    load_monitor("dummy_spawn_arg.hml")

    io =
      capture_io(fn ->
        Dummy.Server.spawn_skip()
        :timer.sleep(100)
      end)

    assert String.contains?(String.downcase(io), "skipping")
  end

  @tag :skip
  test "Monitoring send function: 'end' verdict for unaccounted for pattern" do
    load_monitor("dummy_send.hml")

    payload = :ok

    io =
      capture_io(fn ->
        Dummy.Server.spawn_send(self(), payload)
        :timer.sleep(100)
      end)

    assert String.contains?(String.downcase(io), "instrumenting")
    assert_receive ^payload
    assert String.contains?(String.downcase(io), "reached verdict 'end'")
  end

  @tag :skip
  test "Monitoring send function: 'no' verdict for matched ff pattern" do
    load_monitor("dummy_send.hml")
    payload = :no

    io =
      capture_io(fn ->
        Dummy.Server.spawn_send(self(), payload)
        :timer.sleep(100)
      end)

    assert String.contains?(String.downcase(io), "instrumenting")
    assert_receive ^payload
    assert String.contains?(String.downcase(io), "reached verdict 'no'")
  end

  # @tag :skip
  test "Monitoring receive clause: 'end' verdict for unaccounted for pattern" do
    load_monitor("dummy_recv.hml")

    payload = {:add}

    # io =
    # capture_io(fn ->
    Dummy.Server.spawn_recv(payload)
    # Dummy.Server.spawn_recv(payload)
    :timer.sleep(100)
    # end)

    # assert String.contains?(String.downcase(io), "instrumenting")
    # assert String.contains?(String.downcase(io), "reached verdict 'end'")
  end

  @tag :skip
  test "Monitoring receive clause: 'no' verdict for matched ff pattern" do
    load_monitor("dummy_recv.hml")
    payload = :no

    io =
      capture_io(fn ->
        Dummy.Server.spawn_recv()
        :timer.sleep(100)
      end)

    assert String.contains?(String.downcase(io), "instrumenting")
    assert String.contains?(String.downcase(io), "reached verdict 'no'")
  end

  @tag :skip
  test "monitor unfolds on valid operation" do
    load_monitor("dummy_recurse.hml")

    capture_io(fn ->
      dest = Dummy.Server.spawn_recurse(0)
      send(dest, {self(), {:add, 1, 2}})

      :timer.sleep(100)
    end)

    assert_receive {:ok, 3}

    # assert String.contains?(String.downcase(monitor_output), "unfolding")
  end

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
