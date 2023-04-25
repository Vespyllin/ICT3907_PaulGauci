IO.inspect(:erlang.memory(:total) / 1024 / 1025)

{:ok, pid} = RestApi.Application.start(nil, nil)
IO.inspect(pid)
ref = Process.monitor(pid)

resmon = fn ->
  loop = fn self, sample ->
    :timer.sleep(250)

    if sample == nil do
      self.(self, :scheduler.sample())
    else
      (:erlang.memory(:total) / 1024 / 1024)
      |> Float.round(2)
      |> IO.inspect()

      # IO.inspect(:scheduler.utilization(sample))
      self.(self, nil)
    end
  end

  loop.(loop, nil)
end

resmon.()

receive do
  {:DOWN, ^ref, :process, ^pid, :normal} ->
    IO.puts("Normal exit from #{inspect(pid)}")

  {:DOWN, ^ref, :process, ^pid, msg} ->
    IO.puts("Received :DOWN from #{inspect(pid)}")
    IO.inspect(msg)
end
