Code.require_file "support/mock_repo.exs", __DIR__

Code.require_file "support/models/post.ex", __DIR__

defmodule ExseedTest do
  use ExUnit.Case, async: true

  require Exseed.MockRepo, as: MockRepo

  Application.put_env :exseed, :repo, MockRepo

  import Exseed

  test "it inserts a record in the repo" do
    seed ExseedTest.Post do
      id 1

      title "LOL"

      body "ROFL"
    end
  end
end
