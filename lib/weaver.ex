defmodule Elixir.Weaver do
  def weave(source_file, dest_path \\ nil, source_code \\ false) do
    try do
      unless !dest_path || File.dir?(dest_path),
        do: raise("2nd argument must be an existing directory.")

      unless String.ends_with?(source_file, ".ex"),
        do: raise("Source must be a .ex file.")

      file_name = Path.basename(source_file, ".ex")
      read_res = File.read!(source_file)

      monitored_ast = unwrap_ast(Code.string_to_quoted!(read_res))

      [{mod_name, binary}] = Code.compile_quoted(monitored_ast)

      if dest_path do
        if source_code do
          dest_file_path = "#{dest_path}/#{file_name}_mon.ex"

          File.write!(dest_file_path, Macro.to_string(monitored_ast))

          IO.puts("Monitored source code written to \"#{dest_file_path}\".")
        else
          dest_file_path = "#{dest_path}/#{mod_name}.beam"

          File.write!(dest_file_path, binary)

          IO.puts("Monitored file compiled and loaded into the environment as \"#{mod_name}\".")
          IO.puts("Monitored BEAM written to \"#{dest_file_path}\".")
        end
      else
        IO.puts("Monitored file compiled and loaded into the environment as \"#{mod_name}\".")
      end
    rescue
      e in File.Error ->
        case e.reason do
          :enoent ->
            exit("Could not read from \"#{source_file}\"")

          _ ->
            exit("File error:\n#{e}")
        end

      e in SyntaxError ->
        exit("Source file contains invalid syntax.\n#{e.description}")

      e in TokenMissingError ->
        exit("Source file contains invalid syntax.\n#{e.description}")

      reason ->
        exit(reason)
    end
  end

  # Unwrap imports and module definitions
  defp unwrap_ast({:__block__, meta, file_contents}) do
    {:__block__, meta, unwrap_mod_def(file_contents)}
  end

  defp unwrap_ast(pass) do
    [res] = unwrap_mod_def([pass])
    res
  end

  # Unwrap module declarations
  defp unwrap_mod_def([{:defmodule, meta, [alias_data, [mod_content]]} | tail]) do
    [{:defmodule, meta, [alias_data, [unwrap_mod_block(mod_content)]]} | unwrap_mod_def(tail)]
  end

  defp unwrap_mod_def([head | tail]) do
    [head | unwrap_mod_def(tail)]
  end

  defp unwrap_mod_def(pass) do
    pass
  end

  # Unwrap module content block
  defp unwrap_mod_block({:do, {:__block__, meta, mod_stmts}}) do
    {:do, {:__block__, meta, unwrap_mod_members(mod_stmts)}}
  end

  defp unwrap_mod_block({:do, mod_stmts}) do
    {:do, unwrap_mod_members(mod_stmts)}
  end

  defp unwrap_mod_block(pass) do
    pass
  end

  # Unwrap module components
  defp unwrap_mod_members({:def, meta, fn_decl}) do
    {:def, meta, unwrap_fn_decl(fn_decl)}
  end

  defp unwrap_mod_members({:defp, meta, fn_decl}) do
    {:defp, meta, unwrap_fn_decl(fn_decl)}
  end

  defp unwrap_mod_members([{:def, meta, fn_decl} | tail]) do
    [{:def, meta, unwrap_fn_decl(fn_decl)} | unwrap_mod_members(tail)]
  end

  defp unwrap_mod_members([{:defp, meta, fn_decl} | tail]) do
    [{:defp, meta, unwrap_fn_decl(fn_decl)} | unwrap_mod_members(tail)]
  end

  defp unwrap_mod_members([head | tail]) do
    [head | unwrap_mod_members(tail)]
  end

  defp unwrap_mod_members(pass) do
    pass
  end

  # Unwrap function declaration
  defp unwrap_fn_decl([fn_name, [{:do, {:__block__, meta, fn_stmts}}]]) do
    [fn_name, [{:do, {:__block__, meta, traverse_statements(fn_stmts)}}]]
  end

  defp unwrap_fn_decl([fn_name, [{:do, fn_stmt}]]) do
    [inject_content] = traverse_statements([fn_stmt])
    [fn_name, [{:do, inject_content}]]
  end

  # Wrapper to traverse and unwrap a list of statements
  defp traverse_statements([head | tail]) do
    [unwrap_statement(head) | traverse_statements(tail)]
  end

  defp traverse_statements([]) do
    []
  end

  # Unwrap statements and constructs
  defp unwrap_statement({:=, meta, block}) do
    {:=, meta, unwrap_statement(block)}
  end

  defp unwrap_statement({:send, meta, [dest, msg]}) do
    transform({:send, meta, [dest, msg]})
  end

  defp unwrap_statement({:spawn, meta, [mod, fun, args]}) do
    transform({:spawn, meta, [mod, fun, args]})
  end

  defp unwrap_statement({:receive, meta, [[{:do, cases}]]}) do
    {:receive, meta, [[{:do, Enum.map(cases, &transform/1)}]]}
  end

  defp unwrap_statement({:if, meta, [condition, [do: {:__block__, [], stmts}]]}) do
    {:if, meta, [condition, [do: {:__block__, [], traverse_statements(stmts)}]]}
  end

  defp unwrap_statement({:if, meta, [condition, [do: stmt]]}) do
    {:if, meta, [condition, [do: unwrap_statement(stmt)]]}
  end

  defp unwrap_statement({:cond, meta, [[{:do, cases}]]}) do
    {:cond, meta, [[{:do, traverse_statements(cases)}]]}
  end

  defp unwrap_statement({:case, meta, [condition, [do: cases]]}) do
    {:case, meta, [condition, [do: traverse_statements(cases)]]}
  end

  defp unwrap_statement({:->, meta, [[condition], {:__block__, [], stmts}]}) do
    {:->, meta, [[condition], {:__block__, [], traverse_statements(stmts)}]}
  end

  defp unwrap_statement({:->, meta, [[condition], stmt]}) do
    {:->, meta, [[condition], unwrap_statement(stmt)]}
  end

  defp unwrap_statement(pass) do
    pass
  end

  # Transform functions
  defp transform({:spawn, _meta, [mod, fun, args]}) do
    quote do
      (fn ->
         mod = unquote(mod)
         fun = unquote(fun)
         args = unquote(args)

         pid =
           case :prop_add_rec.mfa_spec({mod, fun, args}) do
             :undefined ->
               spawn(mod, fun, args)

             {:ok, mon} ->
               parent_pid = self()

               spawn(fn ->
                 Process.put(:"$monitor", mon)
                 :analyzer.dispatch({:init, self(), parent_pid, {mod, fun, args}})
                 apply(mod, fun, args)
               end)
           end

         :analyzer.dispatch({:fork, self(), pid, {mod, fun, args}})
         pid
       end).()
    end
  end

  defp transform({:send, _meta, [dest, msg]}) do
    quote do
      (fn ->
         pid = unquote(dest)
         msg = unquote(msg)

         send(pid, msg)

         if :analyzer.filter(msg) do
           :analyzer.dispatch({:send, self(), pid, msg})
         end
       end).()
    end
  end

  defp transform({:->, meta, [[match_case], match_block]}) do
    match_case =
      case match_case do
        {:_, meta, extra} -> {:passmatch, meta, extra}
        _ -> match_case
      end

    match_injection =
      quote do
        (fn ->
           match = unquote(match_case)

           if :analyzer.filter(match) do
             :analyzer.dispatch({:recv, self(), match})
           end
         end).()
      end

    # Recreate case block with monitor code injected at the start
    case(match_block) do
      {:__block__, [], match_stmts} ->
        inject_content = traverse_statements(match_stmts)
        {:->, meta, [[match_case], {:__block__, [], [match_injection | inject_content]}]}

      match_stmt ->
        [inject_content] = traverse_statements([match_stmt])
        {:->, meta, [[match_case], {:__block__, [], [match_injection, inject_content]}]}
    end
  end

  defp transform(x) do
    x
  end
end
