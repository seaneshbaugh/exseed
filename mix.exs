defmodule Exseed.Mixfile do
  use Mix.Project

  def project do
    [app: :exseed,
     version: "0.0.1",
     elixir: "~> 1.0",
     package: package,
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
     links: %{"GitHub" => ""}]
  end

  defp deps do
    [
     { :ecto, ">= 0.10.0" },
    ]
  end
end
