defmodule LambentEx.LinkSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(name, source, target) do
    spec = {LambentEx.Link, name: name, source: source, target: target}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def abort_child(pid) do
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