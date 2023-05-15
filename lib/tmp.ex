defmodule TMP do
  def init() do
    x = true

    case x do
      true ->
        send(self(), {:add})
    end
  end
end
