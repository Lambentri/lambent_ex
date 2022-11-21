defmodule LambentEx.ComponentSupervisor do
  # Automatically defines child_spec/1
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {LambentEx.Scan.ESP8266x7777, []},
      {LambentEx.MachineSupervisor, []},
      {Registry, [keys: :unique, name: :lambent_steps]}
      # {LambentEx.Links, []}
      # {LambentEx.Zones, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
