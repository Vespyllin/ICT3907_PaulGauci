# Code.require_file("./resources/calc_client.ex")
# Code.require_file("./lib/weaver.ex")

src_path = "./resources/calc_server.ex"
dest_path = "./resources"

# :hml_eval.compile('prop_add_rec.hml', [{:outdir, './_build/dev/lib/xeval/ebin'}, :v])

Weaver.weave(src_path, dest_path, true)

# pid = Demo.CalcServer.start(0)
# Demo.CalcClient.rpc(pid, {:add, 1, 2})
