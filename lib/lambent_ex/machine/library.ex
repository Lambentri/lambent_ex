defmodule LambentEx.Machines.Library do
  def machines do [
  solid: %{
    red: %{ machine: LambentEx.Machine.Steps.Solid, args: %{h: 0}},
    blue: %{ machine: LambentEx.Machine.Steps.Solid, args: %{h: 128}},
    green: %{ machine: LambentEx.Machine.Steps.Solid, args: %{h: 84}},

    wwhite: %{ machine: LambentEx.Machine.Steps.SolidRGB, args: %{r: 255, g: 255, b: 190}},
    sapphire: %{desc: "jewels", machine: LambentEx.Machine.Steps.SolidRGB, args: %{r: 0, g: 102, b: 202}},
    ruby: %{desc: "jewels", machine: LambentEx.Machine.Steps.SolidRGB, args: %{r: 155, g: 17, b: 30}},
    emerald: %{desc: "jewels", machine: LambentEx.Machine.Steps.SolidRGB, args: %{r: 4, g: 93, b: 28}},
    gold: %{desc: "jewels", machine: LambentEx.Machine.Steps.SolidRGB, args: %{r: 255, g: 215, b: 0}},
    cafe: %{desc: "jewels", machine: LambentEx.Machine.Steps.SolidRGB, args: %{r: 117, g: 86, b: 56}},
    orange: %{desc: "fruit", machine: LambentEx.Machine.Steps.SolidRGB, args: %{r: 255, g: 204, b: 16}},
    plum: %{desc: "fruit", machine: LambentEx.Machine.Steps.SolidRGB, args: %{r: 122, g: 14, b: 190}},
    guava: %{desc: "fruit", machine: LambentEx.Machine.Steps.SolidRGB, args: %{r: 240, g: 122, b: 190}},
    lime: %{desc: "fruit", machine: LambentEx.Machine.Steps.SolidRGB, args: %{r: 8, g: 255, b: 107}},
    lemon: %{desc: "fruit", machine: LambentEx.Machine.Steps.SolidRGB, args: %{r: 243, g: 255, b: 7}},
  },
  chase: %{
    red: %{machine: LambentEx.Machine.Steps.Chase, args: %{h: 0}},
    blue: %{machine: LambentEx.Machine.Steps.Chase, args: %{h: 128}},
    green: %{machine: LambentEx.Machine.Steps.Chase, args: %{h: 84}},
    yellow: %{machine: LambentEx.Machine.Steps.Chase, args: %{h: 42}},
    pink: %{machine: LambentEx.Machine.Steps.Chase, args: %{h: 212}},
    purple: %{machine: LambentEx.Machine.Steps.Chase, args: %{h: 170}},
  },
  scapes: %{
    vista: %{machine: LambentEx.Machine.Steps.Scape, args: %{h_l: 240, h_h: 120}},
    love: %{machine: LambentEx.Machine.Steps.Scape, args: %{h_l: 230, h_h: 20}},
    ocean: %{machine: LambentEx.Machine.Steps.Scape, args: %{h_l: 90, h_h: 160}},
    forest: %{machine: LambentEx.Machine.Steps.Scape, args: %{h_l: 60, h_h: 90}},
    royal: %{machine: LambentEx.Machine.Steps.Scape, args: %{h_l: 34, h_h: 43}},
    sunny: %{machine: LambentEx.Machine.Steps.Scape, args: %{h_l: 245, h_h: 10}},
    night: %{machine: LambentEx.Machine.Steps.Scape, args: %{h_l: 250, h_h: 20}},
    fire: %{machine: LambentEx.Machine.Steps.Scape, args: %{h_l: 240, h_h: 120, v: 128}},
    vapor: %{machine: LambentEx.Machine.Steps.Scape, args: %{h_l: 150, h_h: 220}},
  },
    rocker: %{
      vapor: %{machine: LambentEx.Machine.Steps.Rocker, args: %{h: [136, 245]}},
      halloween: %{machine: LambentEx.Machine.Steps.Rocker, args: %{h: [13, 187]}},
      halloween_2: %{machine: LambentEx.Machine.Steps.Rocker, args: %{h: [13, 187, 85]}},
      xmas: %{machine: LambentEx.Machine.Steps.Rocker, args: %{h: [0,85]}},
      rgb: %{machine: LambentEx.Machine.Steps.Rocker, args: %{h: [0,85,171]}},
      cmy: %{machine: LambentEx.Machine.Steps.Rocker, args: %{h: [42,127,212]}},
      cmyrgb: %{machine: LambentEx.Machine.Steps.Rocker, args: %{h: [0,42,85,127,171,212]}},
    },
  ]
  end
end

defmodule LambentEx.Machines.Library.Worker do
  @moduledoc false
  use GenServer

  @impl true
  def init(stack) do
    {:ok, stack}
  end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    {:noreply, [element | state]}
  end
end