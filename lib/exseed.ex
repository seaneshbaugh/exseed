defmodule Exseed do
  defmacro seed(model, do: block) do
    quote do
      var!(attributes, Exseed) = %{}

      unquote(Macro.postwalk(block, &postwalk(&1, model)))

      seed_struct = struct(unquote(model), var!(attributes, Exseed))

      Application.get_env(:exseed, :repo).insert!(seed_struct)

      seed_struct
    end
  end

  defmacro attr(attribute, value) do
    quote do
      var!(attributes, Exseed) = Dict.put(var!(attributes, Exseed), unquote(attribute), unquote(value))
    end
  end

  def postwalk({attribute, _meta, [value]} = ast, {_, _, model}) do
    attributes = struct(Module.concat(model), %{}) |> Map.keys |> Enum.reject(fn key -> key in [:__meta__, :__struct__] end)

    if attribute in attributes do
      quote do
        attr(unquote(attribute), unquote(value))
      end
    else
      ast
    end
  end

  def postwalk(ast, _model) do
    ast
  end
end
