defmodule LambentEx.Machine.Steps.Solid.Cfg do
  #   @enforce_keys [:h]
  defstruct [:h, s: 255, v: 255, id: 0]
end

defmodule LambentEx.Machine.Steps.Solid do
  @moduledoc false
  use GenServer

  @registry :lambent_steps
  @cls :solid

  alias LambentEx.Machine.Steps.Solid.Cfg
  alias LambentEx.Utils.Color

  defp n(opts) do
    "#{@cls}-#{opts[:name]}-#{opts[:id]}"
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: via_tuple(n(opts)))
  end

  def init(opts) do
    opts = opts |> Map.put(:status, opts.id)
    cfg = struct(%LambentEx.Machine.Steps.Solid.Cfg{}, opts)
    {:ok, cfg}
  end

  defp via_tuple(name) do
    {:via, Registry, {@registry, name}}
  end

  defp read(state) do
    Color.hsv2rgb([state.h, state.s, state.v])
  end

  def handle_cast(:step, state) do
    {:noreply, state}
  end

  def handle_call(:read, _from, state) do
    {:reply, read(state), state}
  end
end
