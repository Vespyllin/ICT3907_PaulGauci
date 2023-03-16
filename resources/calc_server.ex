defmodule Demo.CalcServer do
  # @spec start(n :: integer()) :: pid()
  def start(n) do
    spawn(__MODULE__, :loop, [n])
  end

  # @spec loop(tot :: integer()) :: no_return()
  def loop(tot) do
    receive do
      {clt, {:add, a, b}} ->
        send(clt, {:ok, a + b})
        loop(tot + 1)

      {clt, {:mul, a, b}} ->
        send(clt, {:ok, a * b})
        loop(tot + 1)

      {clt, :stp} ->
        send(clt, {:bye, tot})
    end
  end
end
