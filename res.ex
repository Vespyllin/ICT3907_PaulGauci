import(Kernel)

defmodule(Demo.CalcServer) do
  @spec start(n :: integer()) :: pid()
  def(start(n)) do
    (fn ->
       __mod = __MODULE__
       __fun = :loop
       __args = [n]

       __pid =
         case(:prop_add_rec.mfa_spec({__mod, __fun, __args})) do
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

  @spec loop(tot :: integer()) :: no_return()
  defp(loop(tot)) do
    receive do
      {clt, {:add, a, b}} ->
        (fn ->
           __match = {clt, {:add, a, b}}

           if(:analyzer.filter(__match)) do
             :analyzer.dispatch({:recv, self(), __match})
           end
         end).()

        (fn ->
           __pid = clt
           __msg = {:ok, a + b}

           if(:analyzer.filter(__msg)) do
             :analyzer.dispatch({:send, self(), __pid, _msg})
           end
         end).()

        loop(tot + 1)

      {clt, {:mul, a, b}} ->
        (fn ->
           __match = {clt, {:mul, a, b}}

           if(:analyzer.filter(__match)) do
             :analyzer.dispatch({:recv, self(), __match})
           end
         end).()

        (fn ->
           __pid = clt
           __msg = {:ok, a * b}

           if(:analyzer.filter(__msg)) do
             :analyzer.dispatch({:send, self(), __pid, _msg})
           end
         end).()

        loop(tot + 1)

      {clt, :stp} ->
        (fn ->
           __match = {clt, :stp}

           if(:analyzer.filter(__match)) do
             :analyzer.dispatch({:recv, self(), __match})
           end
         end).()

        (fn ->
           __pid = clt
           __msg = {:bye, tot}

           if(:analyzer.filter(__msg)) do
             :analyzer.dispatch({:send, self(), __pid, _msg})
           end
         end).()
    end
  end
end

defmodule(Demo.CalcServer2) do
  @spec start(n :: integer()) :: pid()
  def(start(n)) do
    (fn ->
       __mod = __MODULE__
       __fun = :loop
       __args = [n]

       __pid =
         case(:prop_add_rec.mfa_spec({__mod, __fun, __args})) do
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

  @spec loop(tot :: integer()) :: no_return()
  defp(loop(tot)) do
    receive do
      {clt, {:add, a, b}} ->
        (fn ->
           __match = {clt, {:add, a, b}}

           if(:analyzer.filter(__match)) do
             :analyzer.dispatch({:recv, self(), __match})
           end
         end).()

        (fn ->
           __pid = clt
           __msg = {:ok, a + b}

           if(:analyzer.filter(__msg)) do
             :analyzer.dispatch({:send, self(), __pid, _msg})
           end
         end).()

        loop(tot + 1)

      {clt, {:mul, a, b}} ->
        (fn ->
           __match = {clt, {:mul, a, b}}

           if(:analyzer.filter(__match)) do
             :analyzer.dispatch({:recv, self(), __match})
           end
         end).()

        (fn ->
           __pid = clt
           __msg = {:ok, a * b}

           if(:analyzer.filter(__msg)) do
             :analyzer.dispatch({:send, self(), __pid, _msg})
           end
         end).()

        loop(tot + 1)

      {clt, :stp} ->
        (fn ->
           __match = {clt, :stp}

           if(:analyzer.filter(__match)) do
             :analyzer.dispatch({:recv, self(), __match})
           end
         end).()

        (fn ->
           __pid = clt
           __msg = {:bye, tot}

           if(:analyzer.filter(__msg)) do
             :analyzer.dispatch({:send, self(), __pid, _msg})
           end
         end).()
    end
  end
end
