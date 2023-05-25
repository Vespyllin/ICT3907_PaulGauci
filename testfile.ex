# UNDER CONSTANT ALTERATION

defmodule TestFile do
  def spawn() do
    spawn(CalcSpawner, :init, [])
  end

  def send() do
    send(self(), {:ok})
  end

  def receive_1() do
    receive do
      {:message_type, value} ->
        :ok
    end
  end

  def receive_2() do
    receive do
      {:message_type, value} ->
        :ok
      _ ->
        :nok
    end
  end

  def if() do
    if true do
      send(self(), {:ok})
    end
  end

  def if_2() do
    if true do
      send(self(), {:ok})
    else
      send(self(), {:ok})
    end
  end

  def cond() do

    cond do
      true ->
        send(self(), {:ok})
    end
  end

end
