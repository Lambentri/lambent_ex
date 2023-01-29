defmodule LambentEx.MQTTSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(name, host, port \\ 1883) do
    spec = {LambentEx.MQTT, [name: name, host: host, port: port]}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def abort_child(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  @impl true
  def init(init_arg) do
    r =
      DynamicSupervisor.init(
        strategy: :one_for_one,
        extra_arguments: [init_arg]
      )

    Task.start(fn ->
      LambentEx.Meta.get_saved_cfg_mqtt()
      |> Enum.map(fn m ->
        IO.inspect(m[:opts])
        spec = {LambentEx.MQTT, m[:opts]}
        #
        DynamicSupervisor.start_child(__MODULE__, spec)
      end)
    end)

    r
  end
end
