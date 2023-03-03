defmodule(Demo.CalcServer) do
  def(start(n)) do
    _mod = __MODULE__
    _fun = :loop
    _args = [n]
    spawn(__MODULE__, :loop, [n])
  end

  def(start2(n)) do
    fun = :loop
    args = [n]
  end
end
