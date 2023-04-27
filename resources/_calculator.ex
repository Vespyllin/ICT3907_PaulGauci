defmodule MyCalculator do
  use GenServer

  @listener_pid "lp"
  @timeout 3000

  # Init Callbacks

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, %{@listener_pid => spawn(__MODULE__, :listener, [0]), "total" => 0}}
  end

  # Driver

  def listener(tot) do
    receive do
      {clt, {:add, a, b}} ->
        send(clt, {:ok, a + b})
        listener(tot + 1)

      {clt, {:mul, a, b}} ->
        send(clt, {:ok, a * b})
        listener(tot + 1)

      _ ->
        IO.puts("ERR")
        listener(tot + 1)
    end
  end

  # Handlers
  @impl true
  def handle_info(_msg, state) do
    # IO.inspect(
    #   "Unhandled message -> module: #{__MODULE__}, msg: #{inspect(msg)}, state: #{inspect(state)}, is_alive?: #{:erlang.is_process_alive(Map.get(state, @listener_pid))}"
    # )

    {:noreply, state}
  end

  @impl true
  def handle_call({op, val}, _from, state) when is_atom(op) and is_number(val) do
    %{@listener_pid => dest, "total" => tot} = state

    send(dest, {self(), {op, tot, val}})

    receive do
      {:ok, v} ->
        {:reply, {:ok, v}, Map.merge(state, %{"total" => v})}

      _ ->
        {:reply, {:err}, state}
    end
  end

  def handle_call(_, _, state) do
    IO.inspect("INVALID FORMAT")
    {:reply, {:err}, state}
  end

  # Abstracted API

  def add(val) do
    IO.inspect(GenServer.call(__MODULE__, {:add, val}, @timeout))
  end

  def sub(val) do
    GenServer.call(__MODULE__, {:add, -val}, @timeout)
  end

  def mul(val) do
    GenServer.call(__MODULE__, {:mul, val}, @timeout)
  end

  def div(val) do
    GenServer.call(__MODULE__, {:mul, 1 / val}, @timeout)
  end
end
