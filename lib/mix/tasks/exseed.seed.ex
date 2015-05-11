defmodule Mix.Tasks.Exseed.Seed do
  use Mix.Task
  import Mix.Ecto

  def run(args) do
    repo = parse_repo(args)

    ensure_repo(repo)

    {opts, _, _} = OptionParser.parse args, switches: [quiet: :boolean, path: :string]

    seed_path = opts[:path] || "seeds/"

    unless File.exists?(seed_path) do
      raise File.Error, reason: :enoent, action: "find", path: seed_path
    end

    {:ok, seed_files} = File.ls(seed_path)

    seed_files |> Enum.each &(Code.load_file(Path.join(seed_path, &1)))

    unless opts[:quiet] do
      Mix.shell.info "The database for #{inspect repo} has been seeded."
    end
  end
end
