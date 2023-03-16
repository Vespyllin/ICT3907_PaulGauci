defmodule DummyTargetTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureIO
  require Weaver
  require Dummy.Client

  @src_path "./test/resources"
  @bin_path "./_build/test/lib/xeval/ebin"
  @mon "./prop_add_rec.hml"

  def load_monitor(file_name) do
    # Force reloading of the compile monitor BEAM
    :code.purge(:prop_add_rec)

    File.rm(@mon)
    # File.rm("#{@bin_path}/prop_add_rec.beam")

    File.write!(@mon, File.read!("#{@src_path}/#{file_name}"))

    res =
      capture_io(fn ->
        :hml_eval.compile(to_charlist(@mon), [{:outdir, to_charlist(@bin_path)}, :v])
      end)

    if(String.contains?(String.downcase(res), "error")) do
      raise("Bad monitor syntax in \"#{file_name}\"\n#{res}")
    end

    :code.load_abs(to_charlist("#{@bin_path}/prop_add_rec"))
  end

  setup_all do
    Weaver.weave("#{@src_path}/dummy_target.ex")
    Weaver.weave("#{@src_path}/dummy_target.ex", "./test/resources", true)

    on_exit(fn -> File.rm!(@mon) end)
  end

  @tag :skip
  test "Attaching a monitor to a function without arguments" do
    load_monitor("dummy_noarg.hml")

    io =
      capture_io(fn ->
        Dummy.Server.spawn_noarg()
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
    load_monitor("dummy_arg.hml")

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

  @tag :skip
  test "Monitoring receive clause: 'end' verdict for unaccounted for pattern" do
    load_monitor("dummy_recv.hml")

    payload = {:ok}

    io =
      capture_io(fn ->
        dest = Dummy.Server.spawn_recv()
        send(dest, {self(), payload})
        :timer.sleep(100)
      end)

    assert String.contains?(String.downcase(io), "instrumenting")
    assert_receive ^payload
    assert String.contains?(String.downcase(io), "reached verdict 'end'")
  end

  @tag :skip
  test "Monitoring receive clause: 'no' verdict for matched ff pattern" do
    load_monitor("dummy_recv.hml")

    payload = {:no}

    io =
      capture_io(fn ->
        dest = Dummy.Server.spawn_recv()
        send(dest, {self(), payload})
        :timer.sleep(100)
      end)

    assert String.contains?(String.downcase(io), "instrumenting")
    assert_receive ^payload
    assert String.contains?(String.downcase(io), "reached verdict 'no'")
  end

  # @tag :skip
  test "Monitor recurses on matched recurse pattern" do
    # load_monitor("original.hml")
    load_monitor("dummy_recurse.hml")

    # capture_io(fn ->
    dest = Dummy.Server.dummy_recurse()
    # dest = Demo.CalcServer.start(0)
    # send(dest, {self(), {:add, 1, 1}})

    # :timer.sleep(100)
    # end)

    # assert_receive {:ok, 3}

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
