defmodule ExseedTest.Post do
  use Ecto.Model

  schema "posts" do
    field :title, :string, default: ""
    field :body, :string, default: ""
  end
end
