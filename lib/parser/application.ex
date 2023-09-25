defmodule Parser.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ParserWeb.Telemetry,
      # Start the Ecto repository
      # Parser.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Parser.PubSub},
      # Start the Endpoint (http/https)
      ParserWeb.Endpoint,
      # Start a worker by calling: Parser.Worker.start_link(arg)
      Parser.Cache
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Parser.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ParserWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
