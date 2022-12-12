defmodule LambentExWeb.LinksLive.Index do
  use LambentExWeb, :live_view

  alias LambentExWeb.LinksLive.Index

  @pubsub_name LambentEx.PubSub

  use Phoenix.LiveEditableView
  alias LambentEx.LiveEdit

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(@pubsub_name, "links_idx")

    {:ok,
     socket
     |> assign(
       :links,
       %{}
     )}
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

  def handle_info({:publish, link}, socket) do
    {:noreply, socket |> assign(:links, socket.assigns.links |> Map.put(link[:name], link))}
  end
end
