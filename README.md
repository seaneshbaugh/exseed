# Exseed

An Elixir library that provides a simple DSL for seeding databases through Ecto.

Inspired largely by [seed-fu](https://github.com/mbleigh/seed-fu).

## Installation

In your project's `mix.exs` add the following:

```elixir
    defp deps do
      {:exseed, "~> 0.0.3"}
    end
```

and then run `mix deps.get`.

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
