defmodule Membrane.RTP.Format.MixProject do
  use Mix.Project

  @version "0.4.0"
  @github_url "https://github.com/membraneframework/membrane_rtp_format"

  def project do
    [
      app: :membrane_rtp_format,
      version: @version,
      elixir: "~> 1.9",
      deps: deps(),

      # hex
      description: "Membrane Multimedia Framework RTP/RTCP format description",
      package: package(),

      # docs
      name: "Membrane RTP format",
      source_url: @github_url,
      homepage_url: "https://membraneframework.org",
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [],
      mod: {Membrane.RTP.Format.App, []}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "LICENSE"],
      source_ref: "v#{@version}"
    ]
  end

  defp package do
    [
      maintainers: ["Membrane Team"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @github_url,
        "Membrane Framework Homepage" => "https://membraneframework.org"
      }
    ]
  end

  defp deps do
    [
      {:membrane_core, "~> 0.10.0"},
      {:dialyxir, "~> 1.0.0", only: :dev, runtime: false},
      {:credo, "~> 1.6.4", only: :dev, runtime: false},
      {:ex_doc, "~> 0.28", only: :dev, runtime: false}
    ]
  end
end
