defmodule Dummy.Server do
  def spawn_noarg() do
    IO.puts("HELLO")
    spawn(__MODULE__, :dummy_spawn, [])
  end

  def spawn_arg() do
    spawn(__MODULE__, :dummy_spawn, [:arg])
  end

  def spawn_skip() do
    spawn(__MODULE__, :skip, [:arg])
  end

  def spawn_send(dest, arg) do
    spawn(__MODULE__, :dummy_send, [dest, arg])
  end

  def spawn_recv() do
    spawn(__MODULE__, :dummy_recv, [:arg])
    # send(recv_dest, arg)
  end

  def dummy_recurse() do
    spawn(__MODULE__, :dummy_loop, [0])
  end

  def dummy_loop(tot) do
    receive do
      {clt, :loop} ->
        send(clt, :loop)
        dummy_loop(tot + 1)

      {clt, :out} ->
        send(clt, :out)
        dummy_loop(tot + 1)

      {clt, :fail} ->
        send(clt, :fail)
        dummy_loop(tot + 1)

      {clt, :stop} ->
        send(clt, :stop)
    end
  end

  def dummy_spawn() do
  end

  def dummy_spawn(_arg) do
  end

  def dummy_send(dest, arg) do
    send(dest, arg)
  end

  def dummy_recv(_arg) do
    IO.inspect("SPAWNED")

    receive do
      {return_address, payload} ->
        send(return_address, payload)
    end
  end

  def skip(_arg) do
  end
end
