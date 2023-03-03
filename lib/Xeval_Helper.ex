defmodule Xeval_Helper do
  def file_to_quoted(path) do
    Code.string_to_quoted(File.read!(path))
  end

  def get_module_data(q_mod) do
    {:defmodule, _meta, [alias_data, [content]]} = q_mod

    {alias_data, content}
  end

  def parse_module_contents(q_mod_content) do
    case q_mod_content do
      {:do, {:__block__, _meta, fn_content}} ->
        IO.inspect("1< fn")
        fn_content

      {:do, fn_content} ->
        IO.inspect("1 fn")
        fn_content

      _ ->
        IO.inspect("could not parse")
        nil
    end
  end

  def get_fn_data(def_block) do
    IO.inspect("fn data")

    case def_block do
      {:def, _meta, [fn_name, [fn_content_block]]} ->
        case fn_content_block do
          {:do, {:__block__, _meta, fn_content}} ->
            IO.inspect("1< lines")
            {fn_name, fn_content}

          {:do, fn_content} ->
            IO.inspect("1 line")
            {fn_name, fn_content}

          _ ->
            IO.inspect("Could not parse fn def")
            nil
        end

      _ ->
        nil
    end
  end

  def check_fns(list_of_fn_defs) do
    # TODO: For each stmt, check if spawn, if so replace with results of wrap_spawn
    case list_of_fn_defs do
      {:def, _meta, [fn_name, [fn_content_block]]} ->
        case fn_content_block do
          {:do, {:__block__, _meta, fn_content}} ->
            IO.inspect("1< lines")
            inject_wrapper(fn_content)

          # {fn_name, fn_content}

          {:do, fn_content} ->
            IO.inspect("1 line")
            {fn_name, fn_content}

          _ ->
            IO.inspect("Could not parse fn def")
            nil
        end

      _ ->
        nil
    end
  end

  def inject_wrapper([head | tail]) do
    case head do
      {:spawn, _, [arg1, arg2, arg3]} ->
        IO.inspect([arg1, arg2, arg3])
        IO.inspect("found spawn")
        inject_wrapper(tail)

      _ ->
        inject_wrapper(tail)
    end
  end

  def inject_wrapper([]) do
    IO.inspect("done")
  end

  def traverse_ast(quoted_module) do
    # IO.inspect(quoted_module)

    case quoted_module do
      {:defmodule, _meta, _contents} ->
        {_mod_alias, mod_content} = get_module_data(quoted_module)

        test = parse_module_contents(mod_content)
        check_fns(Enum.at(test, 0))

        :module

      _ ->
        :nomatch
    end
  end
end
