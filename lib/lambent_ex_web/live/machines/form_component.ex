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

  defp is_multi(v) do
    case v do
      "gen_firefly" -> true
      "gen_rocker" -> true
      "gen_rocker_s" -> true
      _otherwise -> false
    end
  end

  @impl true
  def handle_event("validate", %{"machines" => machine_params}, socket) do
    machine_params =
      case machine_params["type"] do
        "gen_firefly" ->
          case Ecto.Changeset.get_field(socket.assigns.changeset, :class) do
            nil -> machine_params
            val -> machine_params |> put_in(["class", "h"], val |> Map.get(:h))
          end

        "gen_rocker" ->
          case Ecto.Changeset.get_field(socket.assigns.changeset, :class) do
            nil -> machine_params
            val -> machine_params |> put_in(["class", "h"], val |> Map.get(:h))
          end

        "gen_rocker_s" ->
          case Ecto.Changeset.get_field(socket.assigns.changeset, :class) do
            nil -> machine_params
            val -> machine_params |> put_in(["class", "h"], val |> Map.get(:h))
          end

        _otherwise ->
          machine_params
      end

    IO.inspect(machine_params)
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
        :gen_firefly -> changeset.changes[:class] |> hue_keys
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
    machines_params =
      case machines_params["type"] do
        "gen_firefly" ->
          machines_params
          |> put_in(
            ["class", "h"],
            Ecto.Changeset.get_field(socket.assigns.changeset, :class) |> Map.get(:h)
          )

        "gen_rocker" ->
          machines_params
          |> put_in(
            ["class", "h"],
            Ecto.Changeset.get_field(socket.assigns.changeset, :class) |> Map.get(:h)
          )

        "gen_rocker_s" ->
          machines_params
          |> put_in(
            ["class", "h"],
            Ecto.Changeset.get_field(socket.assigns.changeset, :class) |> Map.get(:h)
          )

        _otherwise ->
          machines_params
      end

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
    curr_cls = Ecto.Changeset.get_field(socket.assigns.changeset, :class)

    curr_h =
      case curr_cls do
        %LambentEx.Schema.Steps.Firefly{h: h} -> h
        %LambentEx.Schema.Steps.Rocker{h: h} -> h
        cs -> Ecto.Changeset.get_field(cs, :h)
      end

    cls_up =
      case curr_cls do
        %LambentEx.Schema.Steps.Firefly{} = x ->
          x |> Map.put(:h, curr_h ++ [data])

        %LambentEx.Schema.Steps.Rocker{} = x ->
          x |> Map.put(:h, curr_h ++ [data])

        cs ->
          Ecto.Changeset.get_field(socket.assigns.changeset, :class)
          |> Ecto.Changeset.change(h: curr_h ++ [data])
      end

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.change(class: cls_up)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("add-sel", _params, socket) do
    {:noreply, socket |> put_flash(:info, "Please select another hue")}
  end

  def handle_event("del-sel", %{"idx" => idx}, socket) do
    curr_cls = Ecto.Changeset.get_field(socket.assigns.changeset, :class)
    cls_up = curr_cls |> Map.put(:h, curr_cls.h |> List.delete_at(int(idx)))

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.change(class: cls_up)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  defp values,
    do: LambentEx.Schema.Machines.values() |> Enum.map(fn {k, v} -> {v, k} end) |> Map.new()

  defp expand(int) do
    (int / 255 * 360) |> round
  end

  def get_sel(values) do
    case values |> Map.get(:params) do
      %{"h_sel" => sel} -> sel
      %{} -> nil
    end
  end

  defp int(v) when is_binary(v) do
    {i, _v} = Integer.parse(v)
    i
  end

  defp int(v) when is_integer(v), do: v

  defp hue_keys(nil), do: []

  defp hue_keys(%{h_sel: h, s: s, v: v}) do
    [r, g, b] = LambentEx.Utils.Color.hsv2rgb([h, s, v])
    [r: r, g: g, b: b, h: h]
  end

  defp hue_keys(%{h: h, s: s, v: v}) do
    [r, g, b] = LambentEx.Utils.Color.hsv2rgb([h, s, v])
    [r: r, g: g, b: b, h: h]
  end

  defp hue_keys(%{h: h, s: s, v: v, h_sel: h_sel}) do
    [r, g, b] = LambentEx.Utils.Color.hsv2rgb([h, s, v])
    [r: r, g: g, b: b, h: h]
  end

  defp hue_keys(%{h: h}) do
    [r, g, b] = LambentEx.Utils.Color.hsv2rgb([int(h), 255, 255])
    [r: r, g: g, b: b]
  end

  defp hrgb(r: r, g: g, b: b) do
    rgb(r, g, b)
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
