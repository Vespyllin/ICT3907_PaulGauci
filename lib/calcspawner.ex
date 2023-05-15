# defmodule CalcSpawner do
#   def init() do
#     spawn(__MODULE__, :listener, [])
#   end

#   def listener() do
#     receive do
#       {clt, {:add, val1, val2}} ->
#         res = val1 + val2
#         send(clt, {:ok, res})

#       {clt, {:mul, val1, val2}} ->
#         res = val1 * val2
#         send(clt, {:ok, res})

#       payload ->
#         IO.inspect("ERR #{inspect(payload)}")
#     end
#   end
# end
