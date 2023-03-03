path = "./resources/calc_server.ex"
# {:ok, original_ast} = Code.string_to_quoted(File.read!(path))
# IO.inspect("Original AST")
# IO.inspect(original_ast)

IO.inspect("New AST")
weave = Clean.weave(path)
IO.inspect(weave)
File.write!("res.ex", Macro.to_string(weave))

# _q =
#   quote do
#     # (fn ->
#     #    mod = :a
#     #    fun = :b
#     #    args = :c

#     #    pid =
#     case :prop_add_rec.mfa_spec({mod, fun, args}) do
#       :undefined ->
#         spawn(mod, fun, args)

#       {:ok, mon} ->
#         parent_pid = self()

#         spawn(fn ->
#           Process.put('$monitor', mon)
#           :analyzer.dispatch({:init, self(), parent_pid, {mod, fun, args}})
#           apply(mod, fun, args)
#         end)
#     end

#     :analyzer.dispatch({:fork, self(), pid, {mod, fun, args}})
#     pid
#     #  end).()
#   end

# IO.inspect(_q)

# IO.inspect(
#   CodeAbstractors.case_stmt(
#     quote do
#       :prop_add_rec.mfa_spec({mod, fun, args})
#     end,
#     Enum.zip([
#       [:undefined, {:ok, :mon}],
#       [
#         quote do
#           y = 6
#         end,
#         quote do
#           x = 11
#         end
#       ]
#     ])
#   )
# )
