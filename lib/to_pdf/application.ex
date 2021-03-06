defmodule ToPdf.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ToPdf.Repo,
      # Start the Telemetry supervisor
      ToPdfWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ToPdf.PubSub},
      # Start the Endpoint (http/https)
      ToPdfWeb.Endpoint,
      # Start a worker by calling: ToPdf.Worker.start_link(arg)
      # {ToPdf.Worker, arg}
      {ToPdfWeb.AuthAgent, nil}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ToPdf.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ToPdfWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
