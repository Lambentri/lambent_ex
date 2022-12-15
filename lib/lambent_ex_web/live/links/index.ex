defmodule LambentExWeb.LinksLive.Index do
  use LambentExWeb, :live_view

  alias LambentExWeb.LinksLive.Index

  @pubsub_name LambentEx.PubSub

  use Phoenix.LiveEditableView
  alias LambentEx.LiveEdit

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(@pubsub_name, "machines_idx")
    Phoenix.PubSub.subscribe(@pubsub_name, "scan-82667777")
    Phoenix.PubSub.subscribe(@pubsub_name, "links_idx")

    {:ok,
     socket
     |> assign(:links, %{})
     |> assign(:machines, %{})
     |> assign(:devices, %{})
     |> assign(:link, nil)
     |> assign(:nonew, true)
     |> assign(:newctrl, [
       %{link: ~p"/cfg/links/new", icon: "plus"},
       %{link: ~p"/cfg/links/bulk", icon: "bucket"}
     ])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_link, "Links")
    |> assign(:page_title, "Links")
    |> assign(:source, nil)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:id, :new)
    |> assign(:page_link, "Links")
    |> assign(:page_title, "New Link")
    |> assign(:link, %LambentEx.Schema.Links{})
  end

  def handle_info({:machines_pub, machine}, socket) do
    {:noreply,
     socket |> assign(:machines, socket.assigns.machines |> Map.put(machine[:name], machine))}
  end

  def handle_info({:links_pub, link}, socket) do
    {:noreply, socket |> assign(:links, socket.assigns.links |> Map.put(link[:name], link))}
  end

  def handle_info({:devices_pub, device}, socket) do
    {:noreply,
     socket |> assign(:devices, socket.assigns.devices |> Map.put(device[:mac], device))}
  end

  def handle_event("toggle", params, socket) do
    LambentEx.Link.toggle(params["tgt"])
    {:noreply, socket}
  end

  def handle_event("quit", params, socket) do
    LambentEx.Link.quit(params["tgt"])
    links = socket.assigns.links |> Map.delete(params["tgt"])
    {:noreply, socket |> assign(:links, links)}
  end
end
