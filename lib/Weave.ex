defmodule Elixir.Weave do
  # Master FN
  # TODO: add options
  def weave(path) do
    {:ok, ast} = Code.string_to_quoted(File.read!(path))

    unwrap_top_level(ast)
  end

  # Unwrap imports and module definitions
  defp unwrap_top_level({:__block__, meta, file_contents}) do
    {:__block__, meta, unwrap_mod_def(file_contents)}
  end

  defp unwrap_top_level(pass) do
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
    [fn_name, [{:do, {:__block__, meta, inject_monitor(fn_stmts)}}]]
  end

  defp unwrap_fn_decl([fn_name, [{:do, fn_stmt}]]) do
    [inject_content] = inject_monitor([fn_stmt])
    [fn_name, [{:do, inject_content}]]
  end

  # Wrapper to destructure monitor injection over functions with and without block statements
  defp inject_monitor([head | tail]) do
    [wrap_stmt(head) | inject_monitor(tail)]
  end

  defp inject_monitor([]) do
    []
  end

  # Wrap spawn/3 in a monitor
  defp wrap_stmt({:spawn, _meta, [mod, fun, args]}) do
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

  # Wrap receive clause members in a monitor
  defp wrap_stmt({:receive, meta, [[{:do, cases}]]}) do
    {:receive, meta, [[{:do, Enum.map(cases, &wrap_stmt/1)}]]}
  end

  # Wrap receive statement in a monitor
  defp wrap_stmt({:->, meta, [[match_case], match_block]}) do
    match_injection =
      quote do
        (fn ->
           match = unquote(match_case)

           if :analyzer.filter(match) do
             :analyzer.dispatch({:recv, self(), match})
           end
         end).()
      end

    case(match_block) do
      {:__block__, [], match_stmts} ->
        {:->, meta,
         [[match_case], {:__block__, [], [match_injection | inject_monitor(match_stmts)]}]}

      match_stmt ->
        [inject_content] = inject_monitor([match_stmt])
        {:->, meta, [[match_case], {:__block__, [], [match_injection, inject_content]}]}
    end
  end

  defp wrap_stmt({:send, _meta, [dest, msg]}) do
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

  defp wrap_stmt(pass) do
    pass
  end
end