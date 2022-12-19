defmodule LambentEx.Machine.Steps.Rainbow.Cfg do
  #   @enforce_keys [:h]
  defstruct [modulo: 1, id: 0, s: 255, v: 255, status: 0]
end

defmodule LambentEx.Machine.Steps.Rainbow do
  @moduledoc false
  use GenServer
  #  @behaviour LambentEx.Machine.Steps

  @registry :lambent_steps
  @cls :chase

  alias LambentEx.Machine.Steps.Rainbow.Cfg
  alias LambentEx.Utils.Color

  defp n(opts) do
    "#{@cls}-#{opts[:name]}-#{opts[:id]}"
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: via_tuple(n(opts)))
  end

  def init(opts) do
    opts = opts |> Map.put(:status, opts.id)
    cfg = struct(%LambentEx.Machine.Steps.Rainbow.Cfg{}, opts)
    {:ok, cfg}
  end

  defp via_tuple(name) do
    {:via, Registry, {@registry, name}}
  end

  defp read(state) do
    Color.hsv2rgb([state.status, state.s, state.v])
  end

  def handle_cast(:step, state) do
    state =
      state
      |> Map.put(:status, (state.status + 1) |> Integer.mod(255))
    {:noreply, state}
  end

  def handle_call(:read, _from, state) do
    {:reply, read(state), state}
  end
end
