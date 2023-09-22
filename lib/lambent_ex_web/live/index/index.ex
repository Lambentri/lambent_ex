defmodule LambentExWeb.IndexLive.Index do
  use LambentExWeb, :live_view

  alias LambentExWeb.IndexLive.Index

  @pubsub_name LambentEx.PubSub

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(@pubsub_name, "machines_idx")
    Phoenix.PubSub.subscribe(@pubsub_name, "scan-82667777")
    Phoenix.PubSub.subscribe(@pubsub_name, "links_idx")

    {:ok, socket
      |> assign(:links, %{})
      |> assign(:machines, %{})
      |> assign(:devices, %{})

      |> assign(:selected_m, nil)
      |> assign(:selected_d, [])
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_link, "LambentEx")
    |> assign(:page_title, "LambentEx")
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

  def handle_event("selectm", %{"name" => name}, socket) do
    if socket.assigns.selected_m != name do
      {:noreply, socket |> assign(:selected_m, name)}
    else
      {:noreply, socket |> assign(:selected_m, nil)}
    end
  end

  def handle_event("selectd", %{"name" => name}, socket) do
    IO.inspect(Enum.member?(socket.assigns.selected_d, name))
    if Enum.member?(socket.assigns.selected_d, name) do
      {:noreply, socket |> assign(:selected_d, socket.assigns.selected_d |> List.delete(name))}
    else
      {:noreply, socket |> assign(:selected_d, socket.assigns.selected_d |> List.insert_at(0, name))}
    end
  end

  # functions

  def group_links(links) do
    links |> Map.values |> Enum.filter(fn x -> x.enabled end) |> Enum.group_by(fn e -> e.source end)
  end

  def find_unlinked_machines(links, machines) do
    used_machines = links |> Map.values |> Enum.filter(fn x -> x.enabled end) |> Enum.map(fn x -> x.source end) |> Enum.uniq |> MapSet.new |> IO.inspect
    machine_ids = machines |> Map.values |> Enum.map(fn x -> x.id end) |> MapSet.new |> IO.inspect
    MapSet.difference(machine_ids, used_machines)
  end

  def find_unlinked_devices(links, devices) do
    used_sources = links |> Map.values |> Enum.map(fn x -> x.target end) |> MapSet.new
#     device_ids = devices |> Map.values |> Enum.map(fn x -> x.id end) |> MapSet.new
    ["fake4", "fake5", "fake6"]
  end
end
