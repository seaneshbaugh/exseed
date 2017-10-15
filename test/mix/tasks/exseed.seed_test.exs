Code.require_file "../../support/test_repo.exs", __DIR__

defmodule Mix.Tasks.Exseed.SeedTest do
  use ExUnit.Case, async: true

  alias Mix.Tasks.Exseed.Seed

  require Exseed.TestRepo, as: TestRepo

  Application.put_env :exseed, :repo, TestRepo

  test "runs the seed task" do
    Seed.run ["-r", to_string(TestRepo), "--path", "test/support/seeds"]

    assert_received {:mix_shell, :info, ["The database for Exseed.TestRepo has been seeded."]}
  end
end
