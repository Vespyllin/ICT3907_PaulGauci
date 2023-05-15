# :hml_eval.compile('./prop_add_rec.hml',[{:outdir, './_build/dev/lib/deploy/ebin'}] )
# {:ok, _, pid} = :monitor.start_online {TMP, :init, []}, &:prop_add_rec.mfa_spec/1, []
# Weaver.weave("./lib/tmp.ex", "./", true)
Weaver.New.weave("./lib/calcspawner.ex", "./", true)
