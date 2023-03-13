defmodule(Dummy.Server) do
  def(start(n)) do
    (fn ->
      mod = __MODULE__
      fun = :dummy_spawn
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
  def(dummy_spawn(n)) do
    (fn ->
      pid = self()
      msg = {:ok, 1}
      send(pid, msg)
      if(:analyzer.filter(msg)) do
        :analyzer.dispatch({:send, self(), pid, msg})
      end
    end).()
  end
end