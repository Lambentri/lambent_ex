defmodule LambentEx.Machine.Steps.Rocker.Cfg do
  #   @enforce_keys [:h]
  defstruct h: [0, 128], l: 1000, d: true, s: 255, v: 255, id: 0, status: 0, hues: []
end

defmodule LambentEx.Machine.Steps.Rocker do
  @moduledoc false
  use GenServer
  #  @behaviour LambentEx.Machine.Steps

  @registry :lambent_steps
  @cls :rocker

  alias LambentEx.Machine.Steps.Rocker.Cfg
  alias LambentEx.Utils.Color

  # TODO. pass in the cfg here, destructured to grab the s/v instead of hardcoding 255
  def generate_status_hsvs(hues, linger, true) do
    # dark
    hues
    |> Enum.map(fn h ->
      [
        0..255 |> Enum.map(fn x -> [h, 255, x] end),
        0..linger |> Enum.map(fn _x -> [h, 255, 255] end),
        255..0 |> Enum.map(fn x -> [h, 255, x] end)
      ]
      |> Enum.concat()
    end)
    |> Enum.concat()
  end

  def generate_status_hsvs(hues, linger, false) do
    # light
    hues
    |> Enum.map(fn h ->
      [
        0..255 |> Enum.map(fn x -> [h, x, 255] end),
        0..linger |> Enum.map(fn _x -> [h, 255, 255] end),
        255..0 |> Enum.map(fn x -> [h, x, 255] end)
      ]
      |> Enum.concat()
    end)
    |> Enum.concat()
  end

  defp n(opts) do
    "#{@cls}-#{opts[:name]}-#{opts[:id]}"
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: via_tuple(n(opts)))
  end

  def init(opts) do
    opts = opts |> Map.put(:status, opts.id)
    cfg = struct(%LambentEx.Machine.Steps.Rocker.Cfg{}, opts)
    hues = generate_status_hsvs(cfg.h, cfg.l, cfg.d)
    {:ok, %{cfg | hues: hues}}
  end

  defp via_tuple(name) do
    {:via, Registry, {@registry, name}}
  end

  defp read(state) do
    Color.hsv2rgb(state.hues |> Enum.at(state.status))
  end

  def handle_cast(:step, state) do
    state =
      state
      |> Map.put(:status, (state.status + 1) |> Integer.mod(state.hues |> length))

    {:noreply, state}
  end

  def handle_call(:read, _from, state) do
    {:reply, read(state), state}
  end
end
