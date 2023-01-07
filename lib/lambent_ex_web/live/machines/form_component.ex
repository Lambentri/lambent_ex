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
     |> assign(:rgbs, [])
     |> assign(:hs, [])
     |> assign(:h, nil)
     |> assign(:s, nil)
     |> assign(:v, nil)
     |> assign(:r, nil)
     |> assign(:g, nil)
     |> assign(:b, nil)}
  end

  defp rocker_params(%{"name" => name, "type" => type}), do: %{"name" => name, "type" => type}

  defp rocker_params(params) do
    IO.inspect(params)
    currhs = Kernel.get_in(params, ["class", "h"]) || []

    case params |> Map.get("h_sel") do
      nil -> params |> Kernel.put_in(["class", "h"], currhs) |> IO.inspect()
      val -> params |> Kernel.put_in(["class", "h"], currhs + [val]) |> IO.inspect()
    end
  end

  @impl true
  def handle_event("validate", %{"machines" => machine_params}, socket) do
    #    machine_params = case machine_params["type"] do
    #      "gen_rocker" -> rocker_params(machine_params)
    #      "gen_rocker_s" -> rocker_params(machine_params)
    #      _otherwise -> machine_params
    #    end

    changeset =
      socket.assigns.machine
      |> Machines.change_machine(machine_params)
      |> IO.inspect()
      |> Map.put(:action, :validate)

    IO.inspect({changeset.changes[:type], changeset.changes[:class]})

    keys =
      case changeset.changes[:type] do
        :gen_chaser_h -> changeset.changes[:class] |> hue_keys
        :gen_solid_h -> changeset.changes[:class] |> hue_keys
        :gen_rocker -> changeset.changes[:class] |> rocker_keys
        :gen_rocker_s -> changeset.changes[:class] |> rocker_keys
        :gen_scape -> changeset.changes[:class] |> scape_keys
        :gen_scape_s -> changeset.changes[:class] |> scape_keys
        _otherwise -> []
      end
      |> IO.inspect()

    socket =
      case keys do
        [r: r, g: g, b: b, h: h, hs: hs] ->
          IO.puts("qqq")

          socket
          |> assign(:rgb, rgb(r, g, b))
          |> assign(:rgbs, hs |> Enum.map(fn [r_, g_, b_] -> rgb(r_, g_, b_) end))
          |> assign(:h, h)

        [r: r, g: g, b: b] ->
          socket |> assign(:rgb, rgb(r, g, b))

        [r: r, g: g, b: b, h: h] ->
          socket |> assign(:rgb, rgb(r, g, b)) |> assign(:h, h)

        [rh: rh, gh: gh, bh: bh, rl: rl, gl: gl, bl: bl, h_h: h_h, h_l: h_l] ->
          socket |> assign(:rgbs, [rgb(rh, gh, bh), rgb(rl, gl, bl)]) |> assign(:hs, [h_h, h_l])

        [] ->
          socket
      end

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"machines" => machines_params}, socket) do
    case Machines.update_machines(socket.assigns.machine, machines_params) do
      {:ok, _machine} ->
        {:noreply,
         socket
         |> put_flash(:info, "Machine Created Successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("new-name", _params, socket) do
    changeset = socket.assigns.changeset |> Ecto.Changeset.change(name: Names.name())
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("add-sel", %{"data" => data}, socket) do
    curr_h = Ecto.Changeset.get_change(socket.assigns.changeset, :h) || []
    changeset = socket.assigns.changeset |> Ecto.Changeset.change(h: curr_h ++ [data])
    {:noreply, socket}
  end

  defp values,
    do: LambentEx.Schema.Machines.values() |> Enum.map(fn {k, v} -> {v, k} end) |> Map.new()

  defp expand(int) do
    (int / 255 * 360) |> round
  end

  defp hue_keys(nil), do: []

  defp hue_keys(%{h: h, s: s, v: v}) do
    [r, g, b] = LambentEx.Utils.Color.hsv2rgb([h, s, v])
    [r: r, g: g, b: b, h: h]
  end


  defp hue_keys(%{h: h, s: s, v: v, h_sel: h_sel}) do
    [r, g, b] = LambentEx.Utils.Color.hsv2rgb([h, s, v])
    [r: r, g: g, b: b, h: h]
  end

  defp rocker_keys(nil), do: [] |> IO.inspect()

  defp rocker_keys(%{h_sel: h_sel, h: h, s: s, v: v}) do
    [r, g, b] = LambentEx.Utils.Color.hsv2rgb([h_sel, s, v])

    [
      r: r,
      g: g,
      b: b,
      h: h_sel,
      hs: h |> Enum.map(fn hh -> LambentEx.Utils.Color.hsv2rgb([hh, s, v]) end)
    ]
    |> IO.inspect()
  end

  defp scape_keys(nil), do: []

  defp scape_keys(%{h_h: h_h, h_l: h_l, s: s, v: v}) do
    [rh, gh, bh] = LambentEx.Utils.Color.hsv2rgb([h_h, s, v])
    [rl, gl, bl] = LambentEx.Utils.Color.hsv2rgb([h_l, s, v])
    [rh: rh, gh: gh, bh: bh, rl: rl, gl: gl, bl: bl, h_h: h_h, h_l: h_l]
  end

  defp rgb(r, g, b), do: "rgb(#{r}, #{g}, #{b})"
end
