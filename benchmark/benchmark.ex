defmodule Benchmark do
  def run_benchmark(process_count, request_count) do
    start_time = :erlang.monotonic_time()
    init(self(), process_count, request_count)

    times =
      for _ <- 1..process_count do
        receive do
          {:ok, time} ->
            time
        end
      end

    end_time = Enum.reduce(times, fn val, acc -> max(val, acc) end)

    IO.inspect((end_time - start_time) / :math.pow(10, 6))
  end

  def init(parent_pid, process_count, request_count) do
    for _ <- 1..process_count do
      recv_pid = spawn(fn -> recv_loop(parent_pid, request_count) end)

      send_pid = spawn(fn -> send_loop(recv_pid, request_count) end)

      {recv_pid, send_pid}
    end
  end

  def recv_loop(parent_pid, request_count) when request_count > 0 do
    for _ <- 1..request_count do
      receive do
        {:ok} ->
          # IO.puts("#{process_count}: received\t{:ok} ##{request_idx} at #{inspect(self())}")
          nil
      end
    end

    send(parent_pid, {:ok, :erlang.monotonic_time()})
  end

  def send_loop(dest_pid, request_count) when request_count > 0 do
    for _ <- 1..request_count do
      send(dest_pid, {:ok})
      # IO.puts("#{process_count}: sent    \t{:ok} ##{request_idx} to #{inspect(dest_pid)}")
    end
  end
end
