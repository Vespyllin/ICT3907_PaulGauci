defmodule Demo.TMP do
  # @spec smp() :: no_return()
  def smp() do
    IO.puts("A")
    # IO.puts("B")
  end

  # def smp2() do
  #   IO.puts("B")
  #   IO.puts("C")
  # end

  # @spec smp2() :: no_return()
  # def smp2() do
  #   receive do
  #     {clt, {:add, a, b}} ->
  #       send(clt, {:ok, a + b})
  #       loop(tot + 1)
  #   end
  # end
end
