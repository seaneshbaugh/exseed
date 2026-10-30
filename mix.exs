defmodule Exseed.Mixfile do
  use Mix.Project

  @version "1.0.0"

  def project do
    [
      app: :exseed,
      version: @version,
      elixir: "~> 1.20",
      deps: deps(),
      test_ignore_filters: [&String.starts_with?(&1, "test/support/")],
      description: description(),
      package: package(),
      name: "Exseed",
      docs: [
        source_ref: "v#{@version}",
        main: "Exseed",
        source_url: "https://github.com/seaneshbaugh/exseed"
      ],
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:ecto, "~> 3.14.2"},
      {:ex_doc, "~> 0.40.4", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    A library that provides a simple DSL for seeding databases through Ecto.
    """
  end

  defp package do
    [
      maintainers: ["Sean Eshbaugh"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/seaneshbaugh/exseed"}
    ]
  end
end
