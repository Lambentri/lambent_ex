defmodule LambentEx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  @registry :lambent

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LambentExWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: LambentEx.PubSub},
      # Start the Endpoint (http/https)
      LambentExWeb.Endpoint,
      # Start a worker by calling: LambentEx.Worker.start_link(arg)
      # {LambentEx.Worker, arg}
      {Registry, [keys: :unique, name: @registry]},
      LambentEx.ComponentSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LambentEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LambentExWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
