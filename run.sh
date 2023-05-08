#!/bin/bash

mix run compile.exs

echo "Benchmark.init()" | iex --erl '+P 134217727' -S mix 