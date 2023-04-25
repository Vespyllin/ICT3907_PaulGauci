defmodule Benchmark.Calcserver do
  def thing do
    spawn(fn ->
      receive do
        payload ->
          IO.inspect("recv #{inspect(payload)}")
      end
    end)
  end
end
