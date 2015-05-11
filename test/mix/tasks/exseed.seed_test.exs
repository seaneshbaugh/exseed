Code.require_file "../../support/mock_repo.exs", __DIR__

defmodule Mix.Tasks.Exseed.SeedTest do
  use ExUnit.Case, async: true

  alias Mix.Tasks.Exseed.Seed

  require Exseed.MockRepo, as: MockRepo

  Application.put_env :exseed, :repo, MockRepo

  test "runs the seed task" do
    Seed.run ["-r", to_string(MockRepo), "--path", "test/support/seeds"]

    assert_received {:mix_shell, :info, ["The database for Exseed.MockRepo has been seeded."]}
  end
end
