defmodule Mix.Tasks.Exseed.SeedTest do
  use ExUnit.Case, async: false
  alias Mix.Tasks.Exseed.Seed

  setup do
    start_supervised!(Exseed.TestRepo)
    :ok
  end

  test "runs the seed task and reports the configured repository" do
    Seed.run(["--path", "test/support/seeds"])
    assert_received {:insert, "posts", _}
    assert_received {:mix_shell, :info, ["The database for Exseed.TestRepo has been seeded."]}
  end

  test "quiet suppresses output and seed files run on every invocation" do
    for _ <- 1..2 do
      Seed.run(["--quiet", "--path", "test/support/seeds"])
      assert_received {:insert, "posts", _}
      refute_received {:mix_shell, :info, _}
    end
  end

  test "raises for a missing directory" do
    assert_raise File.Error, fn -> Seed.run(["--path", "test/nonexistent"]) end
  end

  @tag :tmp_dir
  test "loads only regular exs files in alphabetical order", %{tmp_dir: path} do
    File.write!(Path.join(path, "b.exs"), "send(self(), :second)")
    File.write!(Path.join(path, "a.exs"), "send(self(), :first)")
    File.write!(Path.join(path, "README.md"), "This is not Elixir")
    File.mkdir!(Path.join(path, "directory.exs"))

    Seed.run(["--quiet", "--path", path])
    assert_receive :first
    assert_receive :second
  end

  test "rejects unknown switches" do
    assert_raise OptionParser.ParseError, fn -> Seed.run(["--unknown"]) end
  end
end
