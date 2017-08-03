defmodule Exseed.Mixfile do
  use Mix.Project

  @version "0.0.3"

  def project do
    [app: :exseed,
     version: @version,
     elixir: "~> 1.0",
     deps: deps(),
     test_paths: test_paths(Mix.env),
     description: description(),
     package: package(),
     name: "Exseed",
     docs: [source_ref: "v#{@version}", main: "Exseed",
            source_url: "https://github.com/seaneshbaugh/exseed"],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      { :earmark, "~> 0.2", only: :dev },
      { :ecto, ">= 1.0.0" },
      { :ex_doc, "~> 0.11", only: :dev }
    ]
  end

  defp description do
    """
    A library that provides a simple DSL for seeding databases through Ecto.
    """
  end

  defp package do
    [maintainers: ["Sean Eshbaugh"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/seaneshbaugh/exseed"}]
  end

  defp test_paths(_) do
    ["test/exseed", "test/mix"]
  end
end
