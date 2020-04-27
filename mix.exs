defmodule App.MixProject do
  use Mix.Project

  def project do
    [
      app: :app,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {App.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.10"},
      #{:phoenix_pubsub, "~> 1.1"},
      {:phoenix_html, "~> 2.13", override: true},
      #{:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:httpoison, "~> 1.6"},
      {:mogrify, "~> 0.7.3"},
      {:floki, "~> 0.26.0"},
      {:fast_html, "~> 1.0"},
      {:html_sanitize_ex, "~> 1.3.0-rc3"},
      {:elixir_xml_to_map, "~> 0.1"},
      {:exml, "~> 0.1.1"},
      {:timex, "~> 3.3", override: true},
    ]
  end

end
