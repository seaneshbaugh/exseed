Code.require_file "../support/test_repo.exs", __DIR__

Code.require_file "../support/models/post.ex", __DIR__

defmodule ExseedTest do
  use ExUnit.Case, async: true

  require Exseed.TestRepo, as: TestRepo

  Application.put_env :exseed, :repo, TestRepo

  import Exseed

  test "it inserts a record in the repo" do
    seed ExseedTest.Post do
      id 1

      title "LOL"

      body "ROFL"
    end
  end
end
