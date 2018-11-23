defmodule REST.MixProject do
  use Mix.Project

  def project do
    [
      app: :rest,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {REST, []},
      applications: [:cowboy, :ranch],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, github: "ninenines/cowboy", tag: "2.4.0"},
      {:jsex, "~> 2.0.0"},
      {:distillery, "~> 2.0"},
      {:recon, "~> 2.3"},
       {:observer_cli, "~> 1.4"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
