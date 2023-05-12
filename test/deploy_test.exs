defmodule DeployTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureIO
  require Weaver

  # ADD TESTS
  # VERDICTS BASED ON ARGUMENTS
  # MULTIPLE SPAWNS
  # SPAWN INSIDE SPAWN
  # NO RECURSION AFTER FAILING
  # SEND tuples, lists, atoms, etc
  # MULTIPLE SPAWNS, DIFFERENT VERDICTS
  #   IE SPAWN1 SPAWN2, SEND1 GOOD SEND2 BAD, VERDICT 1 END VERDICT 2 NO

  @src_path "./test/resources"
  @mon "./prop_add_rec.hml"

  # sleep duration in ms
  @sleep 100

  def load_monitor(file_name) do
    # Force reloading of the compile monitor BEAM
    :code.purge(:prop_add_rec)

    File.rm(@mon)

    # File has to be named prop_add_rec.hml
    # Copying the file under this name then continuing
    File.write!(@mon, File.read!("#{@src_path}/#{file_name}"))

    res = capture_io(fn -> :hml_eval.compile(to_charlist(@mon), [:v]) end)

    if(String.contains?(String.downcase(res), "error")) do
      raise("Bad monitor syntax in \"#{file_name}\"\n#{res}")
    end

    :code.load_abs(to_charlist("./prop_add_rec"))
  end

  setup_all do
    Weaver.weave("#{@src_path}/dummy_target.ex")
    Weaver.weave("#{@src_path}/dummy_target.ex", "./test/resources", true)

    on_exit(fn -> File.rm!(@mon) end)
    on_exit(fn -> File.rm!("./prop_add_rec.beam") end)
  end

  @tag :skip
  test "Attaching a monitor to a function without arguments" do
    load_monitor("dummy_noarg.hml")

    io =
      capture_io(fn ->
        Dummy.Server.spawn_noarg()
        :timer.sleep(@sleep)
      end)

    assert String.contains?(String.downcase(io), "instrumenting monitor")
  end

  @tag :skip
  test "Attaching a monitor to a function with arguments" do
    load_monitor("dummy_arg.hml")

    io =
      capture_io(fn ->
        Dummy.Server.spawn_arg()
        :timer.sleep(@sleep)
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
        :timer.sleep(@sleep)
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
        :timer.sleep(@sleep)
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
        :timer.sleep(@sleep)
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
        :timer.sleep(@sleep)
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
        :timer.sleep(@sleep)
      end)

    assert String.contains?(String.downcase(io), "instrumenting")
    assert_receive ^payload
    assert String.contains?(String.downcase(io), "reached verdict 'no'")
  end

  @tag :skip
  test "Monitor recurses on matched recurse pattern" do
    load_monitor("dummy_recurse.hml")

    payload = :loop

    io =
      capture_io(fn ->
        dest = Dummy.Server.dummy_recurse()
        send(dest, {self(), payload})

        :timer.sleep(@sleep)
      end)

    assert_receive ^payload

    assert String.contains?(String.downcase(io), "unfolding")
  end

  @tag :skip
  test "Monitor does not recurse on matched ff pattern" do
    load_monitor("dummy_recurse.hml")

    payload = :fail

    io =
      capture_io(fn ->
        dest = Dummy.Server.dummy_recurse()
        send(dest, {self(), payload})

        :timer.sleep(@sleep)
      end)

    assert_receive ^payload

    assert String.contains?(String.downcase(io), "reached verdict 'no'")
  end

  @tag :skip
  test "Monitor recurses on unaccounted for pattern" do
    load_monitor("dummy_recurse.hml")

    payload = :stop

    io =
      capture_io(fn ->
        dest = Dummy.Server.dummy_recurse()
        send(dest, {self(), payload})

        :timer.sleep(@sleep)
      end)

    assert_receive ^payload

    assert String.contains?(String.downcase(io), "reached verdict 'end'")
  end
end
