defmodule Dummy.Server do
  def spawn_noarg() do
    spawn(__MODULE__, :dummy_spawn, [])
  end

  def spawn_arg() do
    spawn(__MODULE__, :dummy_spawn, [:arg])
  end

  def spawn_skip() do
    spawn(__MODULE__, :skip, [:arg])
  end

  def spawn_send(arg) do
    spawn(__MODULE__, :dummy_send, [arg])
  end

  # def loops(tot) do
  #   receive do
  #     {clt, {:add, 0, b}} ->
  #       send(clt, {:ok, 1 + b})
  #       loops(tot + 1)

  #     # {clt, {:add, a, b}} ->
  #     #   send(clt, {:ok, a + b})
  #     #   loops(tot + 1)

  #     {clt, :stp} ->
  #       send(clt, {:bye, tot})
  #   end
  # end

  def dummy_spawn() do
  end

  def dummy_spawn(_arg) do
  end

  def dummy_send(arg) do
    send(self(), arg)
  end

  def skip(_arg) do
  end
end
