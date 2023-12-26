defmodule Ucat.MixProject do
  use Mix.Project

  def project do
    [
      app: :ucat,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      atomvm: [
        start: Main,
        flash_offset: 0x210000
      ]
    ]
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
      {:exatomvm, github: "AtomVM/exatomvm", runtime: false},
      {:avm_scene, github: "AtomVM/avm_scene"}
    ]
  end
end
