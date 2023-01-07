defmodule LambentEx.MachineSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(step, opts, name, options, count \\ 360) do
    spec = {LambentEx.Machine, [step: step, step_opts: opts, count: count, name: name] ++ options}
    IO.inspect(spec)
    # |> IO.inspect
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def start_child(opts) do
    spec = {LambentEx.Machine, opts}
    IO.inspect(spec)
    #
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def abort_child(pid) do
    IO.inspect("here")
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  @impl true
  def init(init_arg) do
    r =
      DynamicSupervisor.init(
        strategy: :one_for_one,
        extra_arguments: [init_arg]
      )

    Task.start(fn ->
      LambentEx.Meta.get_saved_machines()
      |> Enum.map(fn m ->
        IO.inspect(m[:opts])
        spec = {LambentEx.Machine, m[:opts]}
        #
        DynamicSupervisor.start_child(__MODULE__, spec)
      end)
    end)

    r
  end
end

# LambentEx.Machine.Steps.Chase, step_opts: %{}, name: :default, count: 300,
#
