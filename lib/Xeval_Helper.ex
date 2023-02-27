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
    {:def, _meta, [fn_name, [fn_content_block]]} = def_block

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
  end

  def traverse_ast(quoted_module) do
    case quoted_module do
      {:defmodule, _meta, _contents} ->
        {_mod_alias, mod_content} = get_module_data(quoted_module)

        test = parse_module_contents(mod_content)
        test = get_fn_data(test)
        IO.inspect(test)

        :module

      _ ->
        :nomatch
    end
  end
end
