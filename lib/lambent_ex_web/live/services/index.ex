defmodule LambentExWeb.ServicesLive.Index do
  use LambentExWeb, :live_view

  @pubsub_name LambentEx.PubSub
  @pubsub_mqtt_idx "svc_idx"

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(@pubsub_name, @pubsub_mqtt_idx)

    {:ok,
     socket
     |> assign(:svcs_mqtt, %{})
     |> assign(:svcs_http, %{
       "GSI-DOTA-Player-D0" => %{id: "75f38c20-0122-43ce-bc06-c7bc848fa493"},
       "GSI-DOTA-Player-D1" => %{id: "e73ba486-2156-46b2-87d6-3baf2b597ad6"},
       "GSI-DOTA-Player-D2" => %{id: "487fe006-4038-4a89-8ca4-5f44e724bcd8"},
       "GSI-DOTA-Player-D3" => %{id: "63f96027-dc5e-4483-bd9c-b98926c3d2c2"},
       "GSI-DOTA-Player-D4" => %{id: "e26a0f6b-d2e4-46af-9b11-13592b358a7a"},
       "GSI-DOTA-Player-R0" => %{id: "9aaf93cf-9115-44bb-9245-ceefff12484d"},
       "GSI-DOTA-Player-R1" => %{id: "11584550-7d1a-4d69-9240-639e3465ba69"},
       "GSI-DOTA-Player-R2" => %{id: "c7e3d62b-261b-42d6-8dd6-9c25d86cf8a6"},
       "GSI-DOTA-Player-R3" => %{id: "e1fbc4bb-28d3-4b10-9801-d20659bcad7f"},
       "GSI-DOTA-Player-R4" => %{id: "c2b4a14f-f1af-414e-8027-2fd72c8689c3"}
     })
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

  def handle_info({:html_pub, svc}, socket) do
    {:noreply, socket |> assign(:scvs_html, socket.assigns.scvs_html |> Map.put(svc[:name], svc))}
  end
end
