defmodule Exseed.Mixfile do
  use Mix.Project

  def project do
    [app: :exseed,
     version: "0.0.2",
     elixir: "~> 1.0",
     package: package,
     description: """
     A library that provides a simple DSL for seeding databases through Ecto.
     """,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp package do
    [contributors: ["Sean Eshbaugh"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/seaneshbaugh/exseed"}]
  end

  defp deps do
    [
     { :ecto, ">= 0.10.0" },
    ]
  end
end
