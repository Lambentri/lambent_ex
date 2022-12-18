defmodule LambentEx.MachinesLive.FormComponent do
  use LambentExWeb, :live_component

  alias LambentEx.Schema.Machines
  alias LambentEx.Names

  @impl true
  def update(%{machine: machine} = assigns, socket) do
    changeset = Machines.change_machine(machine)

    {:ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:rgb, nil)
      |> assign(:h, nil)
      |> assign(:s, nil)
      |> assign(:v, nil)
      |> assign(:r, nil)
      |> assign(:g, nil)
      |> assign(:b, nil)
    }
  end

  @impl true
  def handle_event("validate", %{"machines" => machine_params}, socket) do
    changeset =
      socket.assigns.machine
      |> Machines.change_machine(machine_params)
      |> Map.put(:action, :validate)

    IO.inspect(changeset)
    keys = case changeset.changes[:type] do
      :gen_chaser_h -> changeset.changes[:class] |> hue_keys
      _otherwise -> []
    end

    socket = case keys do
      [r: r, g: g, b: b] -> socket |> assign(:rgb, "rgb(#{r}, #{g}, #{b})")
      [] -> socket
    end

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("new-name", _params, socket) do
    changeset = socket.assigns.changeset |> Ecto.Changeset.change(name: Names.name())
    {:noreply, assign(socket, :changeset, changeset)}
  end

  defp values, do: LambentEx.Schema.Machines.values |> Enum.map(fn {k,v} -> {v,k} end) |> Map.new
  defp expand(int) do
    (int / 255 * 360) |> round
  end
  defp hue_keys(nil), do: []
  defp hue_keys(%{h: h, s: s, v: v}) do
    [r,g,b] = LambentEx.Utils.Color.hsv2rgb([h,s,v])
    [r: r, g: g, b: b]
  end
end