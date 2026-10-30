defmodule Exseed do
  @moduledoc ~S"""
  Exseed is a library that provides a simple DSL for seeding databases through Ecto.

  ## Setup

  In `config/config.exs` add:

  ```elixir
      config :exseed, :repo, YourApplication.Repo
  ```

  ## Usage

  Exseed provides a `seed` macro which expects an Ecto schema and a block. Inside the block the fields on your schema will be available as functions which will set the value for the field for that record.

  By default Exseed will look in your project's `priv/repo/seeds/` directory for seed files to load. Let's say you have a schema named Post, you could put the following in `priv/repo/seeds/posts.exs`:

  ```elixir
      import Exseed

      seed YourApplication.Post do
        id 1

        title "First Post!"

        body "Hello, world!"
      end

      seed YourApplication.Post do
        id 2

        title "Second Post"

        {{year, month, day}, {hour, minute, second}} = :calendar.universal_time()

        body "This entry was seeded at #{year}-#{month}-#{day} #{hour}:#{minute}:#{second}."
      end
  ```
  """

  @doc """
  Inserts a record for an Ecto schema and returns the persisted struct.
  """
  defmacro seed(model, do: block) do
    schema = Macro.expand(model, __CALLER__)

    fields =
      schema.__schema__(:fields) ++
        schema.__schema__(:virtual_fields) ++
        schema.__schema__(:associations) ++ schema.__schema__(:embeds)

    block = Macro.postwalk(block, &postwalk(&1, fields))

    quote do
      var!(attributes, Exseed) = %{}

      unquote(block)

      seed_struct = struct!(unquote(schema), var!(attributes, Exseed))
      repo = Application.fetch_env!(:exseed, :repo)

      repo.insert!(Ecto.Changeset.change(seed_struct))
    end
  end

  @doc """
  Sets the value for a schema's attribute.

   Rather than call `attr` directly the name of the attribute should be used instead.
  """
  defmacro attr(attribute, value) do
    quote do
      var!(attributes, Exseed) =
        Map.put(var!(attributes, Exseed), unquote(attribute), unquote(value))
    end
  end

  defp postwalk({attribute, _meta, [value]} = ast, fields) when is_atom(attribute) do
    if attribute in fields do
      quote do
        Exseed.attr(unquote(attribute), unquote(value))
      end
    else
      ast
    end
  end

  defp postwalk(ast, _fields), do: ast
end
