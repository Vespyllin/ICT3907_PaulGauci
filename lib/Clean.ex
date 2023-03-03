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
    {:do, {:__block__, meta, unwrap_mod_comp(mod_stmts)}}
  end

  defp unwrap_mod({:do, mod_stmts}) do
    {:do, unwrap_mod_comp(mod_stmts)}
  end

  defp unwrap_mod(pass) do
    pass
  end

  defp unwrap_mod_comp([{:def, meta, fn_decl} | tail]) do
    [{:def, meta, unwrap_fn_decl(fn_decl)} | unwrap_mod_comp(tail)]
  end

  # For modules containing only 1 function
  defp unwrap_mod_comp({:def, meta, fn_decl}) do
    {:def, meta, unwrap_fn_decl(fn_decl)}
  end

  defp unwrap_mod_comp([head | tail]) do
    [head | unwrap_mod_comp(tail)]
  end

  defp unwrap_mod_comp([]) do
    []
  end

  defp unwrap_fn_decl([fn_name, [{:do, {:__block__, meta, fn_stmts}}]]) do
    [fn_name, [{:do, {:__block__, meta, inject_monitor(fn_stmts)}}]]
  end

  defp unwrap_fn_decl([fn_name, [{:do, fn_stmts}]]) do
    inject_res = inject_monitor([fn_stmts])
    IO.inspect(length(inject_res))

    if length(inject_res) == 1 do
      [tmp] = inject_res
      [fn_name, [{:do, tmp}]]
    else
      [fn_name, [{:do, {:__block__, [], inject_res}}]]
    end
  end

  # Wrapper to destructure monitor injection over functions with and without block statements
  defp inject_monitor([head | tail]) do
    [wrap_stmt(head) | inject_monitor(tail)]
  end

  defp inject_monitor([]) do
    []
  end

  # For functions with no block statement
  defp inject_monitor(standalone) do
    wrap_stmt(standalone)
  end

  defp wrap_stmt({:spawn, _meta, [arg1, arg2, arg3]}) do
    quote do
      (fn ->
         __mod = unquote(arg1)
         __fun = unquote(arg2)
         __args = unquote(arg3)

         __pid =
           case :prop_add_rec.mfa_spec({__mod, __fun, __args}) do
             :undefined ->
               spawn(__mod, __fun, __args)

             {:ok, mon} ->
               __parent_pid = self()

               spawn(fn ->
                 Process.put('$monitor', mon)
                 :analyzer.dispatch({:init, self(), __parent_pid, {__mod, __fun, __args}})
                 apply(__mod, __fun, __args)
               end)
           end

         :analyzer.dispatch({:fork, self(), __pid, {__mod, __fun, __args}})
         __pid
       end).()
    end
  end

  defp wrap_stmt(pass) do
    pass
  end
end
