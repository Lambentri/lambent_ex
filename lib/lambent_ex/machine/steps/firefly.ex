defmodule LambentEx.Machine.Steps.Firefly.Cfg do
  #   @enforce_keys [:h]
  defstruct h: [0, 128], mult: 1000, s: 255, v: 255, id: 0, status: 0
end

defmodule LambentEx.Machine.Steps.Firefly do
  @moduledoc false
  use GenServer
  #  @behaviour LambentEx.Machine.Steps

  @registry :lambent_steps
  @cls :firefly

  alias LambentEx.Machine.Steps.Firefly.Cfg
  alias LambentEx.Utils.Color

  defp n(opts) do
    "#{@cls}-#{opts[:name]}-#{opts[:id]}"
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: via_tuple(n(opts)))
  end

  def init(opts) do
    opts = opts |> Map.put(:status, opts.id)
    cfg = struct(%LambentEx.Machine.Steps.Firefly.Cfg{}, opts) |> Map.from_struct()

    {:ok,
     cfg
     |> Map.put(:active, false)
     |> Map.put(:h_curr, cfg[:h] |> Enum.random)
     |> Map.put(:v_curr, 0)
     |> Map.put(:active_total, 5)
     |> Map.put(:active_done, 0)}
  end

  defp via_tuple(name) do
    {:via, Registry, {@registry, name}}
  end

  defp read(state) do
    Color.hsv2rgb([state[:h_curr], state[:s], state[:v_curr]])
  end

  defp multier(mult), do: [true] ++ for(_i <- 0..mult, do: false)

  defp gen_curr(state) do
    case state[:active] do
      true ->
        state
        |> Map.put(:h_curr, Enum.random(state[:h]))
        |> Map.put(:active_total, Enum.random(3..7))
        |> Map.put(:active_done, 0)

      false ->
        state
    end
  end

  def handle_cast(:step, state) do
    state =
      case(state[:active]) do
        true ->
          case state[:active_done] >= state[:active_total] do
            true -> state |> Map.put(:active, false)
            false -> case state[:v_curr] do
              0 -> state |> Map.put(:v_curr, Enum.random([state[:v], div(state[:v], 2), div(state[:v], 3)]))
              otherwise -> state |> Map.put(:v_curr, 0) |> Map.put(:active_done, state[:active_done] + 1)
            end
          end

        false ->
          state
          |> Map.put(:active, multier(state[:mult]) |> Enum.random()) |> gen_curr
      end

    {:noreply, state}
  end

  def handle_call(:read, _from, state) do
    {:reply, read(state), state}
  end
end
