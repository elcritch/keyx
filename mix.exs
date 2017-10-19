defmodule KeyX.Mixfile do
  use Mix.Project

  def project do
    [
      app: :keyx,
      version: "0.3.0",
      elixir: "~> 1.3",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package(),
    ]
  end

  defp description() do
    "Elixir library for Shamir's Secret Sharing (SSS) algorithm"
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end

  defp package() do
    [
      files: [
        "lib", "priv", "mix.exs", "README*", "LICENSE*"
      ],
      maintainers: ["Jaremy Creechley", "Patrick Cieplak"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/elcritch/keyx"}
    ]
  end
end
