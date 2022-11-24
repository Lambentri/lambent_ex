defmodule LambentEx.Machine.Steps.Chase.Cfg do
  #   @enforce_keys [:h]
  defstruct [:h, s: 255, v: 0, spacing: 30, fadeby: 15, id: 0, status: 0, window: 0]
end

defmodule LambentEx.Machine.Steps.Chase do
  @moduledoc false
  use GenServer
  #  @behaviour LambentEx.Machine.Steps

  @registry :lambent_steps
  @cls :chase

  alias LambentEx.Machine.Steps.Chase.Cfg
  alias LambentEx.Utils.Color

  defp n(opts) do
    "#{@cls}-#{opts[:name]}-#{opts[:id]}"
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: via_tuple(n(opts)))
  end

  def init(opts) do
    opts = opts |> Map.put(:status, opts.id)
    cfg = struct(%LambentEx.Machine.Steps.Chase.Cfg{}, opts)
    {:ok, %{cfg | window: 255 / (cfg.spacing - cfg.fadeby)}}
  end

  defp via_tuple(name) do
    {:via, Registry, {@registry, name}}
  end

  defp read(state) do
    Color.hsv2rgb([state.h, state.s, state.v])
  end

  defp step_v(state) do
    if state.fadeby < state.status and state.status < state.spacing do
      state.window * (state.status |> Integer.mod(state.fadeby))
    else
      0
    end
  end

  def handle_cast(:step, state) do
    state =
      state
      |> Map.put(:status, (state.status + 1) |> Integer.mod(state.spacing))
      |> Map.put(:v, step_v(state))

    {:noreply, state}
  end

  def handle_call(:read, _from, state) do
    {:reply, read(state), state}
  end
end
