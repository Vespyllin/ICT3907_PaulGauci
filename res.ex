defmodule(Demo.CalcServer) do
  def(start(n)) do
    (fn ->
      __mod = __MODULE__
      __fun = :loop
      __args = [n]
      __pid = case(:prop_add_rec.mfa_spec({__mod, __fun, __args})) do
        :undefined ->
          spawn(__mod, __fun, __args)
        {:ok, mon} ->
          __parent_pid = self()
          spawn(fn ->
            Process.put('$monitor', mon)
            :analyzer.dispatch({:init, self(), __parent_pid, {__mod, __fun, __args}})
            apply(__mod, __fun, __args)
          end)
      end
      :analyzer.dispatch({:fork, self(), __pid, {__mod, __fun, __args}})
      __pid
    end).()
  end
  def(start2(n)) do
    fun = :loop
    args = [n]
  end
end