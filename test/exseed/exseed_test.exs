defmodule ExseedTest do
  use ExUnit.Case, async: false
  alias ExseedTest.Post
  import Exseed, only: [seed: 2]

  setup do
    start_supervised!(Exseed.TestRepo)
    :ok
  end

  test "inserts fields and returns a loaded struct" do
    post =
      seed Post do
        id(1)
        title("LOL")
        body("ROFL")
      end

    assert %Post{id: 1, title: "LOL", body: "ROFL", __meta__: %{state: :loaded}} = post
    assert_received {:insert, "posts", fields}
    assert fields[:id] == 1
    assert fields[:title] == "LOL"
    assert fields[:body] == "ROFL"
  end

  test "supports expressions, variables, qualified calls and repeated attributes" do
    suffix = "!"

    post =
      seed Post do
        title("original")
        value = String.upcase("hello")
        title(value <> suffix)
        body(String.replace("some text", "some", "seed"))
      end

    assert post.title == "HELLO!"
    assert post.body == "seed text"
    assert post.id == 42
  end

  test "supports a single attribute block and preserves defaults" do
    post = seed(ExseedTest.Post, do: title("only title"))
    assert post.title == "only title"
    assert post.body == ""
  end

  test "supports explicit attr and qualified seed without importing attr" do
    post =
      Exseed.seed Post do
        Exseed.attr(:title, "explicit")
      end

    assert post.title == "explicit"
  end

  def title(value), do: "qualified " <> value

  test "leaves qualified calls named after schema fields intact" do
    post =
      seed Post do
        title(__MODULE__.title("value"))
      end

    assert post.title == "qualified value"
  end

  test "raises for values Ecto cannot dump" do
    assert_raise Ecto.ChangeError, fn ->
      seed Post do
        title(123)
      end
    end
  end
end
