defmodule LambentEx.LinkSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(name, source, target) do
    spec = {LambentEx.Link, [name: name, source: source, target: target]}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def abort_child(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  @impl true
  def init(init_arg) do
    r = DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [init_arg]
    )

    Task.start(fn ->
      LambentEx.Meta.get_saved_links()
      |> Enum.map(fn l ->
        IO.inspect(l[:opts])
        spec = {LambentEx.Link, l[:opts]}
        #
        DynamicSupervisor.start_child(__MODULE__, spec) |> IO.inspect
      end)
    end)

    r
  end
end