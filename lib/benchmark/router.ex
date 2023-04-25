defmodule RestApi.Router do
  use Plug.Router

  @a Benchmark.Calcserver.thing()
  # plug(Plug.Logger)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/" do
    # IO.inspect(@a)
    send(@a, {:msg, "contents"})
    send_resp(conn, 200, "OK")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
