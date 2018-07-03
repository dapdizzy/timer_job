defmodule TimerJob.Mixfile do
  use Mix.Project

  def project do
    [app: :timer_job,
     version: "0.1.7",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: description(),
     package: package(),
     name: "TimerJob"
   ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:function_invoker, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    "This is a GenServer-ish implementation of a TimerJob, a Job that is executed asynchronously after a given timeout, probably recurring."
  end

  defp package do
    [
      name: "timer_job",
      maintainers: ["Dmitry A. Pyatkov"],
      licenses: ["Apache 2.0"],
      files: ["lib", "mix.exs"],
      links: %{"No Link" => "http://localhost"}
    ]
  end
end
