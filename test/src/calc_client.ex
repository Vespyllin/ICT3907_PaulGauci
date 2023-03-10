defmodule Dummy.Client do
  def rpc(to, req) do
    send(to, {self(), req})

    receive do
      resp ->
        resp
    end
  end

  def gen_client(server_pid) do
    add = fn a, b -> rpc(server_pid, {:add, a, b}) end
    %{add: add}
  end
end
