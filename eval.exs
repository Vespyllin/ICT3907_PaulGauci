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

path = "./resources/calc_server.ex"
# {:ok, original_ast} = Code.string_to_quoted(File.read!(path))
# IO.inspect("Original AST")
# IO.inspect(original_ast)

# IO.inspect("New AST")
# IO.inspect()
Clean.weave(path)
