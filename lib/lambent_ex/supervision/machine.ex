defmodule LambentEx.MachineSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(step, opts, name, options, count \\ 300) do
    spec = {LambentEx.Machine, [step: step, step_opts: opts, count: count, name: name] ++ options}
    IO.inspect(spec)
    DynamicSupervisor.start_child(__MODULE__, spec) |> IO.inspect
  end

  def abort_child(pid) do
    IO.inspect("here")
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  @impl true
  def init(init_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [init_arg]
    )
  end
end

# LambentEx.Machine.Steps.Chase, step_opts: %{}, name: :default, count: 300,
#