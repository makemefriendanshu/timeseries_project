defmodule TimeseriesProject.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TimeseriesProjectWeb.Telemetry,
      # Start the Ecto repository
      TimeseriesProject.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: TimeseriesProject.PubSub},
      # Start Finch
      {Finch, name: TimeseriesProject.Finch},
      # Start the Endpoint (http/https)
      TimeseriesProjectWeb.Endpoint
      # Start a worker by calling: TimeseriesProject.Worker.start_link(arg)
      # {TimeseriesProject.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TimeseriesProject.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TimeseriesProjectWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
