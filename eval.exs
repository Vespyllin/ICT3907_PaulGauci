# {:ok, q} = Xeval_Helper.file_to_quoted("./resources/calc_server.ex")
# Xeval_Helper.traverse_ast(q)
# IO.inspect(q)

# (fn -> IO.inspect("ABC") end).()

# l = [
#   {:one},
#   {:two},
#   {:three, 3, 44, :foobar},
#   {:four},
#   {:five}
# ]

# IO.inspect(List.keyfind(l, :three, 0))

# path = "./resources/calc_server.ex"
# {:ok, original_ast} = Code.string_to_quoted(File.read!(path))
# IO.inspect("Original AST")
# IO.inspect(original_ast)

# IO.inspect("New AST")
# weave = Clean.weave(path)
# IO.inspect(weave)
# File.write!("res.ex", Macro.to_string(weave))

# begin
#         _Pid@0 =
#             case prop_add_rec:mfa_spec({_Mod@0 = calc_server, _Fun@0 = loop, _Args@0 = [N]}) of
#                 undefined ->
#                     spawn(_Mod@0, _Fun@0, _Args@0);
#                 {ok, _MonFun@0} ->
#                     _PidParent@0 = self(),
#                     spawn(fun() ->
#                         put('$monitor', _MonFun@0),
#                         analyzer:dispatch({init, self(), _PidParent@0, {_Mod@0, _Fun@0, _Args@0}}),
#                         apply(_Mod@0, _Fun@0, _Args@0)
#                     end)
#             end,
#         analyzer:dispatch({fork, self(), _Pid@0, {_Mod@0, _Fun@0, _Args@0}}),
#         _Pid@0
#     end

q =
  quote do
    mod = :a
    fun = :b
    args = :c

    pid =
      case :prop_add_rec.mfa_spec({mod, fun, args}) do
        :undefined ->
          spawn(mod, fun, args)

        {ok, mon} ->
          parent_pid = self()

          spawn(fn ->
            Process.put('$monitor', mon)
            :analyzer.dispatch({:init, self(), parent_pid, {mod, fun, args}})
            apply(mod, fun, args)
          end)
      end

    :analyzer.dispatch({:fork, self(), pid, {mod, fun, args}})
    pid
  end

IO.inspect(q)
