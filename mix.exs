defmodule Deploy.MixProject do
  use Mix.Project

  def project do
    [
      app: :deploy,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.6.1"}
    ]
  end
end
