defmodule Dummy.Server do
  def start(n) do
    spawn(__MODULE__, :loop, [n])
  end

  def loop(tot) do
    receive do
      {clt, {:add, a, b}} ->
        send(clt, {:ok, a + b})
        loop(tot + 1)

      {clt, :stp} ->
        send(clt, {:bye, tot})
    end
  end
end
