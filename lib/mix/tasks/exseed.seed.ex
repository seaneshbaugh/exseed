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
  import Supervisor.Spec, warn: false
  import Mix.Ecto

  def run(args) do
    repos = parse_repo(args)

    Enum.each repos, fn repo ->
      ensure_repo(repo, [])

      Mix.Task.run "app.start", args

      {opts, _, _} = OptionParser.parse args, switches: [quiet: :boolean, path: :string]

      seed_path = opts[:path] || "priv/repo/seeds/"

      unless File.exists?(seed_path) do
        raise File.Error, reason: :enoent, action: "find", path: seed_path
      end

      seed_files = Path.wildcard("#{seed_path}/*.exs")

      seed_files |> Enum.each(&(Code.load_file(&1)))

      unless opts[:quiet] do
        Mix.shell.info "The database for #{inspect repo} has been seeded."
      end
    end
  end
end
