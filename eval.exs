path = "./resources/calc_server.ex"
# {:ok, original_ast} = Code.string_to_quoted(File.read!(path))
# IO.inspect("Original AST")
# IO.inspect(original_ast)

IO.inspect("New AST")
weave = Clean.weave(path)
IO.inspect(weave)
File.write!("res.ex", Macro.to_string(weave))
