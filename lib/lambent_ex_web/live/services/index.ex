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
     |> assign(:nonew, true)
     |> assign(:newctrl, [
       %{link: ~p"/cfg/services/new", icon: "network-wired"},
       %{link: ~p"/cfg/services/new", icon: "globe"},
       %{link: ~p"/cfg/services/new", icon: "clock"}
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

  def handle_info({:mqtt_pub, svc}, socket) do
    {:noreply, socket |> assign(:svcs_mqtt, socket.assigns.svcs_mqtt |> Map.put(svc[:name], svc))}
  end

  def handle_info({:http, svc}, socket) do
    {:noreply, socket |> assign(:svcs_http, svc)}
  end
end
