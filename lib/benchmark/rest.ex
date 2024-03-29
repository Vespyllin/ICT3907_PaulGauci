defmodule RestAPI do
  use Plug.Router

  # plug(Plug.Logger)

  plug(:match)

  plug(:dispatch)

  get "/" do
    send(
      CalcSpawner.init(),
      {self(), {:add, :rand.uniform(100), :rand.uniform(100)}}
    )

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
