defmodule FishingJoy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      FishingJoyWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: FishingJoy.PubSub},

      # 房间
      {Registry, keys: :unique, name: Registry.Room},
      {DynamicSupervisor, strategy: :one_for_one, name: RoomSupervisor},

      # 玩家 
      {Registry, keys: :unique, name: Registry.Player},
      {DynamicSupervisor, strategy: :one_for_one, name: PlayerSupervisor},

      
      # Start the Endpoint (http/https)
      FishingJoyWeb.Endpoint
      # Start a worker by calling: FishingJoy.Worker.start_link(arg)
      # {FishingJoy.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FishingJoy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    FishingJoyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
