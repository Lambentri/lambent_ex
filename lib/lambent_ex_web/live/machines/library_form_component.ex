defmodule LambentEx.MachinesLive.LibraryFormComponent do
  use LambentExWeb, :live_component
  alias LambentEx.Names
  import LambentEx.Utils.Color, only: [hex: 1]

  @count 64

  defp combine(extant, new, max \\ @count) do
    extant
    |> Map.merge(new, fn _k, v1, v2 ->
      v1
      |> Map.merge(v2, fn _k, vv1, vv2 ->
        (vv1 ++ vv2) |> Enum.reverse() |> Enum.slice(0..@count) |> Enum.reverse()
      end)
    end)
  end

  defp tick(machines, times) do
    machines
    |> Enum.map(fn {type, items} ->
      {type,
       items
       |> Enum.map(fn {name, pid} ->
         {name,
          0..times
          |> Enum.map(fn _val ->
            GenServer.cast(pid, :step)
            GenServer.call(pid, :read)
          end)}
       end)
       |> Map.new()}
    end)
    |> Map.new()
  end

  def mount(socket) do
    machines =
      LambentEx.Machines.Library.machines()
      |> Enum.map(fn {type, arr} ->
        {type,
         arr
         |> Enum.map(fn {name, cfg} ->
           args = cfg[:args] |> Map.put(:id, 0)
           {:ok, pid} = GenServer.start_link(cfg[:machine], args)
           {name, pid}
         end)
         |> Map.new()}
      end)

    results = tick(machines, @count)

    if connected?(socket), do: Process.send_after(self(), :update_library, 500)
    {:ok, socket |> assign(:libmachines, machines) |> assign(:results, results)}
  end

  @impl true
  def update(%{machine: machine} = assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:library, LambentEx.Machines.Library.machines())
      #      |> assign(:changeset, changeset)
    }
  end

  @impl true
  def update(%{id: :library}, socket) do
    # this takes a rather circuitous route
    Process.send_after(self(), :update_library, 1000)
    results = tick(socket.assigns.libmachines, 1)
    combined = combine(socket.assigns.results, results)
    {:ok, socket |> assign(:results, combined)}
  end

  @impl true
  def handle_event("validate", %{"links_b" => links_params}, socket) do
    changeset =
      socket.assigns.link
      |> LinksB.change_link(links_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  defp machy(name) do
    name |> to_string |> String.split(".") |> Enum.take(-2) |> Enum.join(".")
  end

  defp l(s) when is_atom(s), do: Atom.to_string(s)
  defp l(s), do: s |> String.downcase()

  defp check_active?(machines, name, type) do
    machines
    |> Enum.filter(fn {_k, v} -> l(v[:name]) == l(name) and l(v[:step]) == l(type) end)
    |> Enum.empty?()
  end

  defp preview(pile, name) do
    pile |> Map.get(name, []) |> Enum.map(fn [r, g, b] -> "##{hex(r)}#{hex(g)}#{hex(b)}" end)
  end
end
