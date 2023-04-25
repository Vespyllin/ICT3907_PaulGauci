defmodule RestApi.Application do
  use Application

  @impl true
  def start(_type, _args) do
    port = 8081
    IO.puts("Running on port #{inspect(port)}")

    children = [
      {Plug.Cowboy, scheme: :http, plug: RestApi.Router, options: [port: port]}
    ]

    opts = [strategy: :one_for_one, name: RestApi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
