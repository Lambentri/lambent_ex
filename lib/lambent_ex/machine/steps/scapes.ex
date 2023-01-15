defmodule LambentEx.Machine.Steps.Scape.Cfg do
  #   @enforce_keys [:h]
  defstruct h_l: 0, h_h: 128, s: 255, v: 255, id: 0, status: 0, target: 0, hues: []
end

defmodule LambentEx.Machine.Steps.Scape do
  @moduledoc false
  use GenServer

  @registry :lambent_steps
  @cls :scape

  alias LambentEx.Machine.Steps.Scape.Cfg
  alias LambentEx.Utils.Color

  defp n(opts) do
    "#{@cls}-#{opts[:name]}-#{opts[:id]}"
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: via_tuple(n(opts)))
  end

  def init(opts) do
    opts = opts |> Map.put(:status, opts.id)
    cfg = struct(%LambentEx.Machine.Steps.Scape.Cfg{}, opts)
    hues = generate_hue_range(cfg.h_l, cfg.h_h)

    {:ok,
     cfg
     |> Map.put(:hues, hues)
     |> Map.put(:target, length(hues) - 1)
     |> Map.put(:status, Integer.mod(opts.id, length(hues) - 1))}
  end

  defp via_tuple(name) do
    {:via, Registry, {@registry, name}}
  end

  defp read(state) do
    Color.hsv2rgb([state.hues |> Enum.at(state.status), state.s, state.v])
  end

  defp do_status_step(current, target, size \\ 1) do
    if (current - target) |> abs > size do
      cond do
        current > target -> current - size
        current < target -> current + size
        true -> current
      end
    else
      target
    end
  end

  def handle_cast(:step, state) do
    state =
      case state.status == state.target do
        true ->
          if state.target == 0 do
            state |> Map.put(:target, length(state.hues) - 1)
          else
            state |> Map.put(:target, 0)
          end

        false ->
          state
      end
      |> Map.put(:status, do_status_step(state.status, state.target))

    {:noreply, state}
  end

  def handle_call(:read, _from, state) do
    {:reply, read(state), state}
  end

  def generate_hue_range(low, high) when low > high,
    do: Enum.to_list(low..255) ++ Enum.to_list(0..high)

  def generate_hue_range(low, high), do: low..high |> Enum.to_list()
end
