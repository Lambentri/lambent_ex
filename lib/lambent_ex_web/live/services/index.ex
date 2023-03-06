defmodule LambentExWeb.ServicesLive.Index do
  use LambentExWeb, :live_view

  @pubsub_name LambentEx.PubSub
  @pubsub_mqtt_idx "svc_idx"
  @pubsub_svc_http "svc_pub"

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(@pubsub_name, @pubsub_mqtt_idx)
    Phoenix.PubSub.subscribe(@pubsub_name, @pubsub_svc_http)

    {:ok,
     socket
     |> assign(:svcs_mqtt, %{})
     |> assign(:svcs_http, %{})
     |> assign(:svcs_cronos, %{})
     |> assign(:nonew, true)
     |> assign(:newctrl, [
       %{link: ~p"/cfg/services/mqtt", icon: "network-wired"},
       %{link: ~p"/cfg/services/http", icon: "globe"},
       %{link: ~p"/cfg/services/cronos", icon: "clock"}
     ])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_link, "Services")
    |> assign(:page_title, "External Services")
  end

  defp apply_action(socket, :new_mqtt, _params) do
    socket
    |> assign(:id, :mqtt)
    |> assign(:page_link, "MQTT")
    |> assign(:page_title, "New MQTT")
  end

  defp apply_action(socket, :new_http, _params) do
    socket
    |> assign(:id, :http)
    |> assign(:page_link, "HTTP")
    |> assign(:page_title, "New HTTP")
  end

  defp apply_action(socket, :new_cronos, _params) do
    socket
    |> assign(:id, :cronos)
    |> assign(:page_link, "Cronos")
    |> assign(:page_title, "New Cronos")
  end

  def handle_info({:mqtt_pub, svc}, socket) do
    {:noreply, socket |> assign(:svcs_mqtt, socket.assigns.svcs_mqtt |> Map.put(svc[:name], svc))}
  end

  def handle_info({:http, svc}, socket) do
    {:noreply, socket |> assign(:svcs_http, svc)}
  end

  def handle_info({:mqtt, svc}, socket) do
    {:noreply, socket |> assign(:svcs_mqtt, svc)}
  end

  def handle_info({:cronos, svc}, socket) do
    {:noreply, socket |> assign(:svcs_cronos, svc)}
  end

  def handle_event("del_http", %{"tgt" => tgt}, socket) do
    LambentEx.Meta.del_http(tgt)
    {:noreply, socket}
  end

  def handle_event("del_mqtt", %{"tgt" => tgt}, socket) do
    LambentEx.Meta.del_mqtt(tgt)
    {:noreply, socket}
  end

  def handle_event("del_cronos", %{"tgt" => tgt}, socket) do
    LambentEx.Meta.del_cronos(tgt)
    {:noreply, socket}
  end
end
