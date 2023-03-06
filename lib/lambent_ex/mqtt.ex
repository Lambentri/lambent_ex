defmodule LambentEx.MQTT do
  @moduledoc false
  use GenServer
  @registry :lambent_mqtt
  @pubsub_name LambentEx.PubSub
  @pubsub_topic_idx "svc_idx"

  def start_link(_args, opts) do
    GenServer.start_link(__MODULE__, opts, name: via_tuple("mqtt-#{opts[:name]}"))
  end

  def init(opts) do
    Process.send_after(self(), :publish, 50)

    {:ok, opts} = Keyword.validate(opts, [:name, :host, :port, tls: false, persist: false])

    {:ok, pid} =
      Tortoise.Connection.start_link(
        client_id: opts[:name],
        server: {Tortoise.Transport.Tcp, host: opts[:host], port: opts[:port]},
        handler: {Tortoise.Handler.Logger, []}
      )

    Tortoise.Events.register(opts[:name], :status)
    Tortoise.Events.register(opts[:name], :ping_response)

    {:ok,
     %{
       mqtt: pid,
       name: opts[:name],
       host: opts[:host],
       port: opts[:port],
       persist: opts[:persist],
       connected: :down,
       latency: nil
     }}
  end

  defp via_tuple(name), do: {:via, Registry, {@registry, name}}

  # public apis

  # callbacks
  @impl true
  def handle_info(:publish, state) do
    Process.send_after(self(), :publish, 400)
    Phoenix.PubSub.broadcast(@pubsub_name, @pubsub_topic_idx, {:mqtt_pub, publish(state)})
    {:noreply, state}
  end

  @impl true
  def handle_info({{Tortoise, name}, :ping_response, val}, state) do
    {:noreply, state |> Map.put(:latency, val)}
  end

  @impl true
  def handle_info({{Tortoise, name}, :status, status}, state) do
    {:noreply, state |> Map.put(:connected, status)}
  end

  # impls

  defp publish(state) do
    %{
      name: state[:name],
      host: state[:host],
      port: state[:port],
      persist: state[:persist],
      connected: state[:connected],
      latency: state[:latency]
    }
  end
end
