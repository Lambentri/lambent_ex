defmodule LambentExWeb.DevicesLive.Index do
  use LambentExWeb, :live_view
  require Logger

  @pubsub_name LambentEx.PubSub

  use Phoenix.LiveEditableView
  alias LambentEx.LiveEdit

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(@pubsub_name, "scan-82667777")
    {:ok, socket |> assign(:devices, %{}) |> assign(:nonew, true)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp re_nil(r) do
    case r do
      "" -> nil
      otherwise -> otherwise
    end
  end

  @impl true
  def handle_info({:devices_pub, devices}, socket) do
    n = Map.merge(socket.assigns.devices, devices)
    {:noreply, socket |> assign(:devices, n)}
  end

  @impl true
  def handle_info({:rename, data}, socket) do
    id = data["id"] |> String.trim_trailing("name") |> String.trim_trailing("namem")
    name = data["data"] |> re_nil

    case socket.assigns[:devices] |> Map.get(id) |> Map.get("type") do
      "8266-7777" ->
        LambentEx.Scan.ESP8266x7777.rename(:mac, id, name)

      "mqtt-tasmota" ->
        xname = socket.assigns[:devices] |> Map.get(id) |> Map.get("dname")
        LambentEx.MQTT.rename(xname, id, name)

      type ->
        Logger.info("Need handler for this type: #{type}")
        :ok
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:reorder, data}, socket) do
    id = data["id"] |> String.trim_trailing("ord") |> String.trim_trailing("ordm")
    tgt = data["ok"]["ord"]

    case socket.assigns[:devices] |> Map.get(id) |> Map.get("type") do
      "8266-7777" ->
        LambentEx.Scan.ESP8266x7777.reorder(:mac, id, tgt)

      type ->
        Logger.info("Need handler for this type: #{type}")
        :ok
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:replace, data}, socket) do
    id = data["id"] |> String.trim_trailing("place") |> String.trim_trailing("placem")
    pl = data["data"] |> re_nil

    case socket.assigns[:devices] |> Map.get(id) |> Map.get("type") do
      "8266-7777" ->
        LambentEx.Scan.ESP8266x7777.replace(:mac, id, pl)

      "mqtt-tasmota" ->
        xname = socket.assigns[:devices] |> Map.get(id) |> Map.get("dname")
        LambentEx.MQTT.replace(xname, id, pl)

      type ->
        Logger.info("Need handler for this type: #{type}")
        :ok
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("poke", %{"id" => id, "dname" => name}, socket) do
    case socket.assigns[:devices] |> Map.get(id) |> Map.get("type") do
      "8266-7777" ->
        LambentEx.Scan.ESP8266x7777.poke(id)
      "mqtt-tasmota" ->
        LambentEx.MQTT.do_poke(name, id)

      type ->
        Logger.info("Need handler for this type: #{type}")
        :ok
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("poke", %{"id" => id}, socket) do
    case socket.assigns[:devices] |> Map.get(id) |> Map.get("type") do
      "8266-7777" ->
        LambentEx.Scan.ESP8266x7777.poke(id)
      type ->
        Logger.info("Need handler for this type: #{type}")
        :ok
    end

    {:noreply, socket}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_link, "Devices")
    |> assign(:page_title, "Detected Devices")
    |> assign(:source, nil)
  end

  defp pip(map) do
    cond do
      Map.has_key?(map, "ip") -> Map.get(map, "ip") |> Tuple.to_list() |> Enum.join(".")
      Map.has_key?(map, "POWER") -> "MQTT"
    end

  end

  defp options() do
    [:rgb, :grb, :rgbww, :rgbnw, :rgbcw, :rgbaw, :rgbxw]
  end
end
