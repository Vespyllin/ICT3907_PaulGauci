defmodule Demo.CalcClient do
  @spec add(a :: number(), b :: number()) :: number()
  def add(a, b) do
    {:add, res} = rpc(Demo.CalcServer, {:add, a, b})
    res
  end

  @spec mul(a :: number(), b :: number()) :: number()
  def mul(a, b) do
    {:mul, res} = rpc(Demo.CalcServer, {:mul, a, b})
    res
  end

  @spec rpc(to :: pid() | atom(), req :: any()) :: any()
  def rpc(to, req) do
    send(to, {self(), req})

    receive do
      resp ->
        IO.inspect(resp)
        resp
    end
  end
end
