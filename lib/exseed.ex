defmodule Exseed do
  @moduledoc ~S"""
  Exseed is a library that provides a simple DSL for seeding databases through Ecto.

  ## Setup

  In `config/config.exs` add:

  ```elixir
      config :exseed, :repo, YourApplication.Repo
  ```

  ## Usage

  Exseed provides a `seed` macro which expects an Ecto model and a block. Inside the block the fields on your model will be available as functions which will set the value for the field for that record.

  By default Exseed will look in your project's `priv/repo/seeds/` directory for seed files to load. Let's say you have a model named Post, you could put the following in `priv/repo/seeds/posts.exs`:

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
  Creates a new record in the repo for a given model.
  """
  defmacro seed(model, do: block) do
    quote do
      var!(attributes, Exseed) = %{}

      unquote(Macro.postwalk(block, &postwalk(&1, model)))

      seed_struct = struct(unquote(model), var!(attributes, Exseed))

      # For some reason version 1.1.3 of Ecto requires the prepare key to be present in the changeset for Ecto.Repo.Schema.do_insert/4.
      # But, Ecto.Changeset.change/1 does not add it. It looks like the master branch of Ecto removes this requirement so this can be
      # reverted in the future.
      changeset = Map.put(Ecto.Changeset.change(seed_struct), :prepare, [])

      Application.get_env(:exseed, :repo).insert!(changeset)

      seed_struct
    end
  end

  @doc """
  Sets the value for a model's attribute.

   Rather than call `attr` directly the name of the attribute should be used instead.
  """
  defmacro attr(attribute, value) do
    quote do
      var!(attributes, Exseed) = Map.put(var!(attributes, Exseed), unquote(attribute), unquote(value))
    end
  end

  defp postwalk({attribute, _meta, [value]} = ast, {_, _, model}) do
    attributes = struct(Module.concat(model), %{}) |> Map.keys |> Enum.reject(fn key -> key in [:__meta__, :__struct__] end)

    if attribute in attributes do
      quote do
        attr(unquote(attribute), unquote(value))
      end
    else
      ast
    end
  end

  defp postwalk(ast, _model) do
    ast
  end
end
