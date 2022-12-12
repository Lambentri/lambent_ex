defmodule LambentExWeb.MachinesLive.Index do
  use LambentExWeb, :live_view

  alias LambentExWeb.MachinesLive.Index

  @pubsub_name LambentEx.PubSub

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
    {:ok, socket |> assign(:machines, %{})}
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

  def handle_info({:publish, machine}, socket) do
#    IO.inspect(machine)
    {:noreply, socket |> assign(:machines, socket.assigns.machines |> Map.put(machine[:id], machine))}
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

  defp spd(val) do
    @speeds[val]
  end

  def bgt(val) do
    val/255 * 100 |> trunc
  end

end