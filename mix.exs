defmodule Static.MixProject do
  use Mix.Project

  def project do
    [
      app: :static,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.html": :test],
      # Docs
      name: "Static",
      source_url: "https:/github.com/enter-haken/static",
      homepage_url: "https://hake.one",
      docs: docs()
    ]
  end

  def escript do
    [main_module: Static.Generate]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def docs do
    [
      main: "readme",
      extras: [
        "README.md",
        "LICENSE"
      ]        
    ]
  end

  defp deps do
    [
      {:earmark, "~> 1.4"},
      {:yaml_elixir, "~> 2.8"},
      {:jason, "~> 1.2"},
      {:abnf_parsec, "~> 1.2", runtime: false},
      {:excoveralls, "~> 0.14", only: :test},
      {:ex_doc, "~> 0.28", only: :dev, runtime: false}
    ]
  end
end
