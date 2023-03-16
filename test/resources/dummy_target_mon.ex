defmodule(Dummy.Server) do
  def(spawn_noarg()) do
    (fn ->
      mod = __MODULE__
      fun = :dummy_spawn
      args = []
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
  def(spawn_arg()) do
    (fn ->
      mod = __MODULE__
      fun = :dummy_spawn
      args = [:arg]
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
  def(spawn_skip()) do
    (fn ->
      mod = __MODULE__
      fun = :skip
      args = [:arg]
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
  def(spawn_send(dest, arg)) do
    (fn ->
      mod = __MODULE__
      fun = :dummy_send
      args = [dest, arg]
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
  def(spawn_recv()) do
    (fn ->
      mod = __MODULE__
      fun = :dummy_recv
      args = [:arg]
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
  def(dummy_recurse()) do
    (fn ->
      mod = __MODULE__
      fun = :loop
      args = [0]
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
  def(dummy_spawn()) do
    
  end
  def(dummy_spawn(_arg)) do
    
  end
  def(dummy_send(dest, arg)) do
    (fn ->
      pid = dest
      msg = arg
      send(pid, msg)
      if(:analyzer.filter(msg)) do
        :analyzer.dispatch({:send, self(), pid, msg})
      end
    end).()
  end
  def(dummy_recv(_arg)) do
    IO.inspect("SPAWNED")
    receive do
      {return_address, payload} ->
        (fn ->
          match = {return_address, payload}
          if(:analyzer.filter(match)) do
            :analyzer.dispatch({:recv, self(), match})
          end
        end).()
        (fn ->
          pid = return_address
          msg = payload
          send(pid, msg)
          if(:analyzer.filter(msg)) do
            :analyzer.dispatch({:send, self(), pid, msg})
          end
        end).()
    end
  end
  def(skip(_arg)) do
    
  end
end