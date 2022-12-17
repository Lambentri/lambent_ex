defmodule LambentEx.MachinesLive.FormComponent do
  use LambentExWeb, :live_component

  alias LambentEx.Schema.Machines
  alias LambentEx.Names

  @impl true
  def update(%{machine: machine} = assigns, socket) do
    changeset = Machines.change_machine(machine)

    {:ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"machines" => machine_params}, socket) do
    changeset =
      socket.assigns.machine
      |> Machines.change_machine(machine_params)
      |> Map.put(:action, :validate)
      |> IO.inspect()

    {:noreply, assign(socket, :changeset, changeset)}
  end

  defp values, do: LambentEx.Schema.Machines.values |> Enum.map(fn {k,v} -> {v,k} end) |> Map.new
end