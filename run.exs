Code.require_file("./resources/calc_client.ex")

src_path = "./resources/calc_server.ex"
dest_path = "./resources/calc_server_mon.ex"

File.write!(dest_path, Macro.to_string(Elixir.Weave.weave(src_path)))

Code.require_file(dest_path)

pid = Demo.CalcServer.start(0)
Demo.CalcClient.rpc(pid, {:add, 1, 2})

# :hml_eval.compile('prop_add_rec.hml', [{:outdir, 'thing'}, :v, :erl])

# res = :tmp.give()
# imitate = :"$monitor"
# IO.inspect(is_atom(res))
# IO.inspect(is_atom(imitate))
