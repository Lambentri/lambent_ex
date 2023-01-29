defmodule LambentEx.ComponentSupervisor do
  # Automatically defines child_spec/1
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {LambentEx.Meta, []},
      {LambentEx.Scan.ESP8266x7777, []},
      {LambentEx.MachineSupervisor, []},
      {LambentEx.LinkSupervisor, []},
      {LambentEx.MQTTSupervisor, []},
      {Registry, [keys: :unique, name: :lambent_machine]},
      {Registry, [keys: :unique, name: :lambent_links]},
      {Registry, [keys: :unique, name: :lambent_steps]},
      {Registry, [keys: :unique, name: :lambent_mqtt]}
      # {LambentEx.Links, []}
      # {LambentEx.Zones, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
