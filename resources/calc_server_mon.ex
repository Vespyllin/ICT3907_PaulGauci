defmodule(Demo.CalcServer) do
  @spec(start(n :: integer()) :: pid())
  def(start(n)) do
    (fn ->
      mod = __MODULE__
      fun = :loop
      args = [n]
      pid = case(:prop_add_rec.mfa_spec({mod, fun, args})) do
        :undefined ->
          spawn(mod, fun, args)
        {:ok, mon} ->
          parent_pid = self()
          spawn(fn ->
            Process.put(:"$monitor", mon)
            :analyzer.dispatch({:init, self(), parent_pid, {mod, fun, args}})
            apply(mod, fun, args)
          end)
      end
      :analyzer.dispatch({:fork, self(), pid, {mod, fun, args}})
      pid
    end).()
  end
  @spec(loop(tot :: integer()) :: no_return())
  def(loop(tot)) do
    receive do
      {clt, {:add, a, b}} ->
        (fn ->
          match = {clt, {:add, a, b}}
          if(:analyzer.filter(match)) do
            :analyzer.dispatch({:recv, self(), match})
          end
        end).()
        (fn ->
          pid = clt
          msg = {:ok, a + b}
          send(pid, msg)
          if(:analyzer.filter(msg)) do
            :analyzer.dispatch({:send, self(), pid, msg})
          end
        end).()
        loop(tot + 1)
      {clt, {:mul, a, b}} ->
        (fn ->
          match = {clt, {:mul, a, b}}
          if(:analyzer.filter(match)) do
            :analyzer.dispatch({:recv, self(), match})
          end
        end).()
        (fn ->
          pid = clt
          msg = {:ok, a * b}
          send(pid, msg)
          if(:analyzer.filter(msg)) do
            :analyzer.dispatch({:send, self(), pid, msg})
          end
        end).()
        loop(tot + 1)
      {clt, :stp} ->
        (fn ->
          match = {clt, :stp}
          if(:analyzer.filter(match)) do
            :analyzer.dispatch({:recv, self(), match})
          end
        end).()
        (fn ->
          pid = clt
          msg = {:bye, tot}
          send(pid, msg)
          if(:analyzer.filter(msg)) do
            :analyzer.dispatch({:send, self(), pid, msg})
          end
        end).()
    end
  end
end