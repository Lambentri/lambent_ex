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
     )
    |> assign(:link, nil)
     |> assign(:nonew, :true)
     |> assign(:newctrl, [
       %{link: ~p"/cfg/links/new", icon: "plus"},
       %{link: ~p"/cfg/links/bulk", icon: "bucket"}
     ])
    }
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

  def handle_info({:publish, link}, socket) do
    {:noreply, socket |> assign(:links, socket.assigns.links |> Map.put(link[:name], link))}
  end
end
