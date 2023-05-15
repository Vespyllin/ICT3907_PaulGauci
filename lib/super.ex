defmodule MySupervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    port = 8080
    IO.puts("Running on port #{inspect(port)}")

    children = [
      {Plug.Cowboy, scheme: :http, plug: RestAPI, options: [port: port]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
