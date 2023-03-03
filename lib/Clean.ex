defmodule Clean do
  # Master FN
  def weave(path) do
    {:ok, ast} = Code.string_to_quoted(File.read!(path))

    unwrap_mod_decl(ast)
  end

  defp unwrap_mod_decl({:defmodule, meta, [alias_data, [mod_content]]}) do
    {:defmodule, meta, [alias_data, [unwrap_mod(mod_content)]]}
  end

  defp unwrap_mod_decl(_) do
    IO.inspect("NO MATCH FOR unwrap_mod_decl")
  end

  defp unwrap_mod({:do, {:__block__, meta, mod_stmts}}) do
    {:do, {:__block__, meta, unwrap_mod_stmts(mod_stmts)}}
  end

  defp unwrap_mod({:do, mod_stmts}) do
    {:do, unwrap_mod_stmts(mod_stmts)}
  end

  defp unwrap_mod(pass) do
    IO.inspect("NO MATCH FOR unwrap_mod")
    pass
  end

  defp unwrap_mod_stmts({:def, meta, fn_decl}) do
    {:def, meta, unwrap_fn_decl(fn_decl)}
  end

  # defp unwrap_mod_stmts({:@}) do
  #   {:@}
  # end

  defp unwrap_mod_stmts(pass) do
    IO.inspect("NO MACH FOR unwrap_mod_stmts")
    IO.inspect(pass)
    pass
  end

  # defp unwrap_fn_decl([fn_name, [{:do, {:__block__, meta, fn_stmts}}]]) do
  # end

  # defp unwrap_fn_decl({:do, fn_content}) do
  # end

  defp unwrap_fn_decl(_) do
    IO.inspect("NO MACH FOR unwrap_fn_decl")
  end

  # defp inject_monitor() do
  # end
end
