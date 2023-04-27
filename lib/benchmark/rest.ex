defmodule RestAPI do
  use Plug.Router

  # plug(Plug.Logger)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  post "/" do
    # jsonthing = conn.body_params

    send(CalcSpawner.init(), {self(), {:add, 1, 2}})

    receive do
      {:ok, val} ->
        send_resp(
          conn,
          200,
          "{\n\t\"status\": \"ok\",\n\t\"result\": #{val}\n}"
        )

      _ ->
        send_resp(conn, 500, "Internal Server Error")
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
