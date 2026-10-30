defmodule Mix.Tasks.Exseed.Seed do
  @moduledoc ~S"""
  Seed the database from seed files.

  ## Examples

      mix exseed.seed
      mix exseed.seed --path path/to/seed/files/

  ## Command line options

    * `--path` - the path to the seed files (defaults to `priv/repo/seeds/`)
    * `--quiet` - don't display any non-error output.
  """

  use Mix.Task

  @impl true
  def run(args) do
    {opts, _} = OptionParser.parse!(args, strict: [quiet: :boolean, path: :string])

    Mix.Task.run("app.start")

    repo = Application.fetch_env!(:exseed, :repo)
    seed_path = opts[:path] || "priv/repo/seeds/"

    seed_path
    |> File.ls!()
    |> Enum.filter(&String.ends_with?(&1, ".exs"))
    |> Enum.sort()
    |> Enum.map(&Path.join(seed_path, &1))
    |> Enum.filter(&File.regular?/1)
    |> Enum.each(&Code.eval_file/1)

    unless opts[:quiet] do
      Mix.shell().info("The database for #{inspect(repo)} has been seeded.")
    end
  end
end
