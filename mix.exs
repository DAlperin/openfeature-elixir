defmodule OpenFeature.MixProject do
  use Mix.Project

  def project do
    [
      app: :openfeature_elixir,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: [
        main: "OpenFeature",
        extras: ["README.md"]
      ],
      description:
        "OpenFeature is an open specification that provides a vendor-agnostic, community-driven API for feature flagging that works with your favorite feature flag management tool."
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/DAlperin/openfeature-elixir"},
      maintainers: ["Dov Alperin"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {OpenFeature.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ldclient, "~> 3.0.4", hex: :launchdarkly_server_sdk},
      {:elixir_uuid, "~> 1.2"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
