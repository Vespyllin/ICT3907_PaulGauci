# defmodule(CalcSpawner) do
#   def(init()) do
#     (fn ->
#        mod = __MODULE__
#        fun = :listener
#        args = []

#        pid =
#          case(:prop_add_rec.mfa_spec({mod, fun, args})) do
#            :undefined ->
#              spawn(mod, fun, args)

#            {:ok, mon} ->
#              parent_pid = self()

#              spawn(fn ->
#                Process.put(:"$monitor", mon)
#                :analyzer.dispatch({:init, self(), parent_pid, {mod, fun, args}})
#                apply(mod, fun, args)
#              end)
#          end

#        :analyzer.dispatch({:fork, self(), pid, {mod, fun, args}})
#        pid
#      end).()
#   end

#   def(listener()) do
#     receive do
#       {clt, {:add, val1, val2}} ->
#         (fn ->
#            match = {clt, {:add, val1, val2}}

#            if(:analyzer.filter(match)) do
#              :analyzer.dispatch({:recv, self(), match})
#            end
#          end).()

#         res = val1 + val2

#         (fn ->
#            pid = clt
#            msg = {:ok, res}
#            send(pid, msg)

#            if(:analyzer.filter(msg)) do
#              :analyzer.dispatch({:send, self(), pid, msg})
#            end
#          end).()

#       {clt, {:mul, val1, val2}} ->
#         (fn ->
#            match = {clt, {:mul, val1, val2}}

#            if(:analyzer.filter(match)) do
#              :analyzer.dispatch({:recv, self(), match})
#            end
#          end).()

#         res = val1 * val2

#         (fn ->
#            pid = clt
#            msg = {:ok, res}
#            send(pid, msg)

#            if(:analyzer.filter(msg)) do
#              :analyzer.dispatch({:send, self(), pid, msg})
#            end
#          end).()

#       payload ->
#         (fn ->
#            match = payload

#            if(:analyzer.filter(match)) do
#              :analyzer.dispatch({:recv, self(), match})
#            end
#          end).()

#         IO.inspect("ERR #{inspect(payload)}")
#     end
#   end
# end
