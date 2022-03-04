defmodule Static.MixProject do
  use Mix.Project

  def project do
    [
      app: :static,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
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

  defp deps do
    [
      {:earmark, "~> 1.4"},
      {:jason, "~> 1.2"},
      {:abnf_parsec, "~> 1.2", runtime: false}
    ]
  end
end
