Code.require_file("benchmark.ex")

pids = Benchmark.run_benchmark(100_000, 2)
IO.inspect(pids)
