Code.require_file("./resources/calc_client.ex")
Code.require_file("./lib/Weave.ex")

src_path = "./resources/calc_server.ex"
dest_path = "./resources/calc_server_mon.ex"

# :hml_eval.compile('prop_add_rec.hml', [{:outdir, './_build/dev/lib/xeval/ebin'}, :v])
# :hml_eval.compile('prop_add_rec.hml', [{:outdir, './'}, :v, :erl])

File.write!(dest_path, Macro.to_string(Elixir.Weave.weave(src_path)))

Code.require_file(dest_path)

pid = Demo.CalcServer.start(0)
Demo.CalcClient.rpc(pid, {:add, 1, 2})

# res = :tmp.give()
# imitate = :"$monitor"
# IO.inspect(is_atom(res))
# IO.inspect(is_atom(imitate))
