defmodule LambentExWeb.MachinesLive.Index do
  use LambentExWeb, :live_view

  alias LambentExWeb.MachinesLive.Index
  import LambentEx.Utils.Color, only: [hex: 1]

  @pubsub_name LambentEx.PubSub
  @pubsub_topic_fh "machine:"

  use Phoenix.LiveEditableView
  alias LambentEx.LiveEdit

  @speeds %{
    # 1 => :THOU,
    # 5 => :FTHOU,
    10 => :HUNDREDTHS,
    50 => :FHUNDREDTHS,
    100 => :TENTHS,
    500 => :FTENTHS,
    1000 => :ONES,
    2000 => :TWOS,
    5000 => :FIVES,
    10000 => :TENS,
    20000 => :TWENTYS,
    30000 => :THIRTYS,
    60000 => :MINS
  }

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(@pubsub_name, "machines_idx")
    Phoenix.PubSub.subscribe(@pubsub_name, @pubsub_topic_fh)

    {:ok,
     socket
     |> assign(:machine, nil)
     |> assign(:machines, %{})
     |> assign(:previews, %{})
     |> assign(:nonew, true)
     |> assign(:newctrl, [
       %{link: ~p"/cfg/machines/new", icon: "plus"},
       %{link: ~p"/cfg/machines/library", icon: "book"}
     ])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_link, "Machines")
    |> assign(:page_title, "Machine Library")
    |> assign(:source, nil)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:id, :new)
    |> assign(:page_link, "Machines")
    |> assign(:page_title, "New Machine")
    |> assign(:machine, %LambentEx.Schema.Machines{})
  end

  defp apply_action(socket, :library, _params) do
    socket
    |> assign(:id, :library)
    |> assign(:page_link, "Machines")
    |> assign(:page_title, "Machine Library")
    |> assign(:machine, [])
  end

  def handle_info({:machines_pub, machine}, socket) do
    #    IO.inspect(machine)
    {:noreply,
     socket |> assign(:machines, socket.assigns.machines |> Map.put(machine[:id], machine))}
  end

  def handle_info({:firehose, {name, data}}, socket) do
    {:noreply, socket |> assign(:previews, socket.assigns.previews |> Map.put(name, data))}
  end

  def handle_event("faster", data, socket) do
    LambentEx.Machine.faster(data["id"])
    {:noreply, socket}
  end

  def handle_event("slower", data, socket) do
    LambentEx.Machine.slower(data["id"])
    {:noreply, socket}
  end

  def handle_event("dimmer", data, socket) do
    LambentEx.Machine.dimmer(data["id"])
    {:noreply, socket}
  end

  def handle_event("brighter", data, socket) do
    LambentEx.Machine.brighter(data["id"])
    {:noreply, socket}
  end

  def handle_event("quit", params, socket) do
    LambentEx.Machine.quit(params["tgt"])
    machines = socket.assigns.machines |> Map.delete(params["tgt"])
    {:noreply, socket |> assign(:machines, machines)}
  end

  def handle_event("persist", data, socket) do
    LambentEx.Machine.persist(data["tgt"])
    {:noreply, socket}
  end

  def handle_info(:update_library, socket) do
    send_update(LambentEx.MachinesLive.LibraryFormComponent, id: :library)
    {:noreply, socket}
  end

  defp spd(val) do
    @speeds[val]
  end

  def bgt(val) do
    (val / 255 * 100) |> trunc
  end

  defp preview(pile, name) do
    pile |> Map.get(name, []) |> Enum.map(fn [r, g, b] -> "##{hex(r)}#{hex(g)}#{hex(b)}" end)
  end
end
