defmodule Benchmark do
  def init() do
    {:ok, _pid} = MySupervisor.start_link()

    sampler()
  end

  def filter_cores(data) do
    filter(data, [])
  end

  def filter([{:normal, _, _, pct} | unfiltered], filtered) do
    filter(unfiltered, filtered ++ [pct])
  end

  def filter([{:cpu, _, _, _} | unfiltered], filtered) do
    filter(unfiltered, filtered)
  end

  def filter([], filtered) do
    filtered
  end

  def clean_pct(pct) do
    String.slice("#{pct}", 0..(length(pct) - 2))
    |> String.to_float()
  end

  def sampler(sample \\ nil) do
    :timer.sleep(250)

    if sample == nil do
      sampler(:scheduler.sample())
    else
      mem =
        (:erlang.memory(:total) / 1024 / 1024)
        |> :erlang.float_to_binary(decimals: 2)

      util = :scheduler.utilization(sample)
      [_total, {:weighted, _num, cpu_pct} | cores] = util

      IO.puts("\t{")
      IO.puts("\t\t\"process_count\": #{length(Process.list())},")
      IO.puts("\t\t\"memory\": #{mem},")
      IO.puts("\t\t\"cpu\": #{clean_pct(cpu_pct)},")
      IO.puts("\t\t\"cores\": #{inspect(Enum.map(filter_cores(cores), &clean_pct/1))}")
      IO.puts("\t},")

      sampler(nil)
    end
  end
end
