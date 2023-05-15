#!/bin/bash

mix run compile.exs

echo -e "IO.puts('Hello')\nBenchmark.init()" | iex --erl '+P 134217727' -S mix 