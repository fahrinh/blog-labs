defmodule FileDownloader.MixProject do
  use Mix.Project

  def project do
    [
      app: :file_downloader,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:hound, "~> 1.1.0"} # <- add hound library
    ]
  end
end
