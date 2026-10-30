# Exseed

An Elixir library that provides a simple DSL for seeding databases through Ecto.

Inspired largely by [seed-fu](https://github.com/mbleigh/seed-fu).

[![CircleCI](https://circleci.com/gh/seaneshbaugh/exseed/tree/master.svg?style=svg)](https://circleci.com/gh/seaneshbaugh/exseed/tree/master)

## Installation

In your project's `mix.exs` add the following:

```elixir
    defp deps do
      [{:exseed, "~> 1.0.0"}]
    end
```

and then run `mix deps.get`.

## Setup

In `config/config.exs` add:

```elixir
    config :exseed, :repo, YourApplication.Repo
```

## Usage

Exseed provides a `seed` macro which expects an Ecto schema and a block. Inside
the block the fields on your schema will be available as functions which will set
the value for the field for that record.

By default Exseed will look in your project's `priv/repo/seeds/` directory for
seed files to load. Let's say you have a schema named Post, you could put the
following in `priv/repo/seeds/posts.exs`:

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

Run `mix exseed.seed` to load the `.exs` files directly inside
`priv/repo/seeds/` in alphabetical order. Use `--path path/to/seeds` to choose
a different directory, or `--quiet` to suppress the completion message.
Your configured repository must be started by your application's supervision tree.

`seed` inserts a new record and returns the persisted struct, including generated
IDs and Ecto metadata. Values use Ecto's normal type validation; this DSL does not
call a schema's custom changeset function. Repeated runs insert again, so existing
primary keys may raise database constraint errors.

## Development

Install the versions in `.tool-versions` with `asdf install`, then run:

```sh
mix deps.get
mix test
mix docs
```

The tests use a current Ecto adapter without requiring an external database.
