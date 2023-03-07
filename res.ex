defmodule(Demo.CalcServer) do
  def(loop(tot)) do
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
