defmodule Benchmark do
  # @good_payload {:ok}

  def run_benchmark(process_count, request_count) do
    pids = init(process_count, request_count)

    monitor_pids =
      Enum.map(pids, fn {recv_pid, send_pid} ->
        {Process.monitor(recv_pid), Process.monitor(send_pid)}
      end)

    Enum.each(monitor_pids, fn {recv_pid, send_pid} ->
      IO.inspect("Waiting for recv DOWN")

      receive do
        {:DOWN, ^recv_pid, _, _, _} ->
          nil

          # payload ->
          #   IO.inspect("payload #{payload}")
      end

      IO.inspect("Waiting for send DOWN")

      receive do
        {:DOWN, ^send_pid, _, _, _} ->
          nil

          # payload ->
          #   IO.inspect("payload #{payload}")
      end
    end)
  end

  def init(process_count, request_count) do
    for process_idx <- 1..process_count do
      recv_pid = spawn(fn -> recv_loop(process_idx, request_count) end)

      send_pid = spawn(fn -> send_loop(process_idx, recv_pid, request_count) end)

      {recv_pid, send_pid}
    end
  end

  def recv_loop(process_count, request_count) when request_count > 0 do
    for request_idx <- 1..request_count do
      receive do
        {:ok} ->
          IO.puts("#{process_count}: received\t{:ok} ##{request_idx} at #{inspect(self())}")
      end
    end
  end

  def send_loop(process_count, dest_pid, request_count) when request_count > 0 do
    for request_idx <- 1..request_count do
      send(dest_pid, {:ok})
      IO.puts("#{process_count}: sent    \t{:ok} ##{request_idx} to #{inspect(dest_pid)}")
    end
  end
end
