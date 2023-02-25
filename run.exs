q =
  quote do
    defmodule TMP do
      def sample_fn(a, b) do
        c = a + 2
        b + c
      end
    end
  end

# IO.inspect(q)
{a1, m1, t1} = q
[al, bloc1] = t1
[inbloc1] = bloc1
{do1, def1} = inbloc1
{a2, m2, t2} = def1
[_fn_decl, bloc2] = t2
[{do2, fn_bloc}] = bloc2
{a3, m3, t3} = fn_bloc

print_stmt =
  quote do
    IO.inspect("injected line")
  end

new_t3 = [print_stmt | t3]
new_fndecl = {:new_fn, [context: Elixir], [{:a, [], Elixir}, {:b, [], Elixir}]}

new_fn_bloc = {a3, m3, new_t3}
new_bloc2 = [{do2, new_fn_bloc}]
new_t2 = [new_fndecl, new_bloc2]
new_def1 = {a2, m2, new_t2}
new_inbloc1 = {do1, new_def1}
new_bloc1 = [new_inbloc1]
new_t1 = [al, new_bloc1]
new_q = {a1, m1, new_t1}

IO.inspect(Macro.to_string(new_q))
[{name, _bin}] = Code.compile_quoted(new_q)
IO.inspect(name.new_fn(1, 2))

# [{name, _bin}] = Code.compile_quoted(q)
