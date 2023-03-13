defmodule Dummy.Server do
  def start(n) do
    spawn(__MODULE__, :dummy_spawn, [n])
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

  def dummy_spawn(n) do
    send(self(), {:ok, 1})
    # spawn(fn -> IO.puts(:stdio, "\nDUMMY_SIDE_EFFECT #{n}") end)
  end
end
