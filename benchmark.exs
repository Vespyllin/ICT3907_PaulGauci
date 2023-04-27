{:ok, pid} = MySupervisor.start_link()
ref = Process.monitor(pid)

(fn ->
   loop = fn self, sample ->
     :timer.sleep(250)

     if sample == nil do
       self.(self, :scheduler.sample())
     else
       (:erlang.memory(:total) / 1024 / 1024)
       |> Float.round(2)
       |> (fn val -> IO.puts("#{val} MB") end).()

       [_total, weighted | _physicalCores_and_brokenHyperThreads] = :scheduler.utilization(sample)
       IO.inspect(weighted)
       self.(self, nil)
     end
   end

   loop.(loop, nil)
 end).()

receive do
  {:DOWN, ^ref, :process, ^pid, :normal} ->
    IO.puts("Normal exit from #{inspect(pid)}")

  {:DOWN, ^ref, :process, ^pid, msg} ->
    IO.puts("Received :DOWN from #{inspect(pid)}")
    IO.inspect(msg)
end
