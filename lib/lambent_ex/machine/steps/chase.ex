defmodule LambentEx.Machine.Steps.Chase do
  @moduledoc false
  use GenServer

  @registry :lambent_steps
  @cls :chase

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: via_tuple("#{@cls}-#{opts[:name]}-#{opts[:id]}"))
#    GenServer.start_link(__MODULE__, opts, name: {:global, "#{@cls}-#{opts[:name]}-#{opts[:id]}"})
  end

  def init(opts) do
    IO.inspect(opts)
    {:ok, opts}
  end

  defp via_tuple(name) do
    IO.inspect(name)
    {:via, Registry, {@registry, name}}
  end

  #  defp via_tuple(name), do: {:via, Registry, {@registry, name}}

  def step(id) do
    IO.puts("steppy#{id}")
  end
end
