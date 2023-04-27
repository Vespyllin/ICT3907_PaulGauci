defmodule Benchmark do
  def init() do
    {:ok, _pid} = MySupervisor.start_link()

    (fn ->
       loop = fn self, sample ->
         :timer.sleep(250)

         if sample == nil do
           self.(self, :scheduler.sample())
         else
           (:erlang.memory(:total) / 1024 / 1024)
           |> Float.round(2)
           |> (fn val -> IO.puts("#{val} MB") end).()

           [_total, weighted | _physicalCores_and_brokenHyperThreads] =
             :scheduler.utilization(sample)

           IO.inspect(weighted)
           self.(self, nil)
         end
       end

       loop.(loop, nil)
     end).()
  end
end
