defmodule LambentEx.MQTT do
  @moduledoc false
  use GenServer
  require Logger

  alias LambentEx.Meta, as: M

  @registry :lambent_mqtt
  @pubsub_name LambentEx.PubSub
  @pubsub_topic_idx "svc_idx"

  @mqtt_topic_prefix_tasmota_tele "tele/"
  @mqtt_topic_prefix_tasmota_cmnd "cmnd/"
  @mqtt_topic_prefix_tasmota_stat "stat/"

  @lighting_keywords ["Color", "Fade", "White", "CT", "Dimmer"]

  def start_link(_args, opts) do
    GenServer.start_link(__MODULE__, opts, name: via_tuple("mqtt-#{opts[:name]}"))
  end

  def init(opts) do
    Process.send_after(self(), :publish, 50)

    {:ok, opts} =
      Keyword.validate(opts, [:name, :host, :port, tls: false, persist: false, modes: [:tasmota]])

    {:ok, pid} =
      Tortoise.Connection.start_link(
        client_id: opts[:name],
        server: {Tortoise.Transport.Tcp, host: opts[:host], port: opts[:port]},
        handler: {LambentEx.MQTT.Handler, [id: self()]}
      )

    cond do
      Enum.member?(opts[:modes], :tasmota) ->
        Tortoise.Connection.subscribe(opts[:name], @mqtt_topic_prefix_tasmota_tele <> "#", qos: 0)
        Tortoise.Connection.subscribe(opts[:name], @mqtt_topic_prefix_tasmota_stat <> "#", qos: 0)
        Logger.info("Subscribed to tasmota subscriptions")
        :ok

      Enum.member?(opts[:modes], :apollos_crib) ->
        :ok
    end

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
       latency: nil,
       modes: opts[:modes],
       d_sensors: %{},
       d_lights: %{}
     }}
  end

  defp via_tuple(name), do: {:via, Registry, {@registry, name}}

  # public apis
  def do_poke(name, id) do
    via_tuple("mqtt-#{name}")
    |> GenServer.cast({:poke, id})
  end

  def rename(name, id, new) do
    via_tuple("mqtt-#{name}")
    |> GenServer.cast({:rename_mac, id, new})
  end

  def replace(name, id, new) do
    via_tuple("mqtt-#{name}")
    |> GenServer.cast({:replace, id, new})
  end

  # callbacks
  defp add_type(devices, name) do
    devices |> Enum.map(fn {k, v} -> {k, v |> Map.put("type", "mqtt-tasmota") |> Map.put("dname", name)} end) |> Map.new()
  end

  @impl true
  def handle_info(:publish, state) do
    Process.send_after(self(), :publish, 400)
    Phoenix.PubSub.broadcast(@pubsub_name, @pubsub_topic_idx, {:mqtt_pub, publish(state)})

    Phoenix.PubSub.broadcast(
      @pubsub_name,
      "scan-82667777",
      {:devices_pub, state[:d_lights] |> add_type(state[:name])}
    )
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
  def handle_info({{Tortoise, "hass"}, ref, result}, state) do
    IO.inspect({"gottem", ref, result})
    {:noreply, state}
  end

  def handle_info({:light, device, payload}, state) do
    c = state[:d_lights]
    d = c |> Map.get(device, %{})
    m = Map.merge(d, payload)
    n = M.get_name(device)
    p = M.get_place(device)
    c2 = c |> Map.put(device, m |> Map.put("name", n) |> Map.put("place", p))
    {:noreply, state |> Map.put(:d_lights, c2)}
  end

  @impl true
  def handle_cast({:poke, id}, state) do
    IO.inspect("got poke")
    {:noreply, state}
  end

  @impl true
  def handle_cast({:rename_mac, device, name}, state) do
    d = state[:d_lights] |> Map.get(device, %{})
    dev = state[:d_lights] |> Map.put(device, d |> Map.put("name", name))

    M.put_name(device, name)
    {:noreply, %{state | d_lights: dev}}
  end

  @impl true
  def handle_cast({:replace, device, place}, state) do
    d = state[:d_lights] |> Map.get(device, %{})
    dev = state[:d_lights] |> Map.put(device, d |> Map.put("place", place))

    M.put_place(device, place)
    {:noreply, %{state | d_lights: dev}}
  end

  defp publish(state) do
    %{
      name: state[:name],
      host: state[:host],
      port: state[:port],
      persist: state[:persist],
      connected: state[:connected],
      latency: state[:latency],
      d_lights: state[:d_lights],
      d_sensors: state[:d_sensors]
    }
  end
end

defmodule LambentEx.MQTT.Handler do
  @moduledoc false

  require Logger

  use Tortoise.Handler

  defstruct []
  alias __MODULE__, as: State

  def init(opts) do
    Logger.info("Initializing handler")
    {:ok, %{id: opts[:id]}}
  end

  def connection(:up, state) do
    Logger.info("Connection has been established")
    {:ok, state}
  end

  def connection(:down, state) do
    Logger.warn("Connection has been dropped")
    {:ok, state}
  end

  def connection(:terminating, state) do
    Logger.warn("Connection is terminating")
    {:ok, state}
  end

  def subscription(:up, topic, state) do
    Logger.info("Subscribed to #{topic}")
    {:ok, state}
  end

  def subscription({:warn, [requested: req, accepted: qos]}, topic, state) do
    Logger.warn("Subscribed to #{topic}; requested #{req} but got accepted with QoS #{qos}")
    {:ok, state}
  end

  def subscription({:error, reason}, topic, state) do
    Logger.error("Error subscribing to #{topic}; #{inspect(reason)}")
    {:ok, state}
  end

  def subscription(:down, topic, state) do
    Logger.info("Unsubscribed from #{topic}")
    {:ok, state}
  end

  def publish_entity(pid, cls, device, payload) do
    Process.send(pid, {cls, device, payload}, [])
  end

  def handle_message(topic, payload, state) do
      case topic do
        ["tele", device, "LWT"] ->
          Logger.info("#{device}: got LWT, queueing discovery work, #{payload}")

        ["tele", device, "STATE"] ->
          Logger.info("#{device}: got STATE, updating device states, #{payload}")
          {:ok, p} = Poison.decode(payload)

          if is_lighting_entity?(:p, p) do
            publish_entity(state[:id], :light, device, p)
          end

        ["tele", device, "INFO1"] ->
          Logger.info("#{device}: got INFO1, updating device states, #{payload}")

        ["tele", device, "INFO2"] ->
          Logger.info("#{device}: got INFO2, updating device states, #{payload}")

        ["tele", device, "INFO3"] ->
          Logger.info("#{device}: got INFO3, updating device states, #{payload}")

        ["stat", device, "POWER"] ->
          Logger.info("#{device}: got POWER message, #{payload}")

        ["stat", device, "RESULT"] ->
          Logger.info("#{device}: got RESULT message, #{payload}")
          {:ok, p} = Poison.decode(payload)

          if is_lighting_entity?(:p, p) do
            publish_entity(state[:id], :light, device, p)
          end
        _otherwise ->
          Logger.debug("xxx---#{Enum.join(topic, "/")} #{inspect(payload)}")
      end

    {:ok, state}
  end

  def terminate(reason, _state) do
    Logger.warn("Client has been terminated with reason: #{inspect(reason)}")
    :ok
  end

  def is_lighting_entity?(:t, topic) do
    "tasmota" in topic and
      Enum.any?(@lighting_keywords, fn keyword -> String.member?(topic, keyword) end)
  end

  def is_lighting_entity?(:p, payload) do
    keys = payload |> Map.keys()

    Enum.any?(["Color", "Fade", "White", "CT", "Dimmer"], fn keyword ->
      Enum.member?(keys, keyword)
    end)
  end

  def is_sensor_entity(:p, payload) do
  end
end
