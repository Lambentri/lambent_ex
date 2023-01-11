defmodule LambentEx.Meta do
  use GenServer

  @table :lex_metadata
  @pubsub_name LambentEx.PubSub

  def init(arg) do
#    File.cd("meta")
    {:ok, table} = :dets.open_file(@table, type: :set)
#    File.cd("..")

    Phoenix.PubSub.subscribe(@pubsub_name, "machines_idx")
    Phoenix.PubSub.subscribe(@pubsub_name, "links_idx")
    Process.send_after(self(), :machine_flush, 5000)
    Process.send_after(self(), :link_flush, 5000)
    ml = MapSet.new()
    ll = MapSet.new()

    {:ok, %{table: table, machines: ml, links: ll}}
  end

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  # devices
  def get_name(mac) do
    case :dets.lookup(@table, "name-#{mac}") do
      [] ->
        nil

      [{_key, value}] ->
        value
    end
  end

  def get_ord(mac) do
    case :dets.lookup(@table, "ord-#{mac}") do
      [] ->
        nil

      [{_key, value}] ->
        value
    end
  end

  def put_name(key, value) do
    :dets.insert(@table, {"name-#{key}", value})
  end

  def put_ord(key, value) do
    :dets.insert(@table, {"ord-#{key}", value})
  end

  # machines
  def get_saved_machines do
    case :dets.lookup(@table, "machs") do
      [] -> []
      [{_key, value}] ->
        value
    end
  end

  def get_saved_links do
    case :dets.lookup(@table, "links") do
      [] -> []
      [{_key, value}] ->
        value
    end
  end

  def links_clear() do
    :dets.delete(@table, "links")
  end

  def machines_clear() do
    :dets.delete(@table, "machs")
  end

  def handle_info(:machine_flush, state) do
    Process.send_after(self(), :machine_flush, 5000)

    if state.machines |> MapSet.size() == 0 do
      {:noreply, state}
    else
      :dets.insert(@table, {"machs", state.machines})
      {:noreply, state}
    end
  end

  def handle_info(:link_flush, state) do
    Process.send_after(self(), :link_flush, 5000)
    if state.links |> MapSet.size() == 0 do
      {:noreply, state}
    else
      :dets.insert(@table, {"links", state.links})
      {:noreply, state}
    end
  end

  def handle_info({:machines_pub, machine}, state) do
    case machine[:persist] do
      true ->
        {:noreply, %{state | machines: MapSet.put(state.machines, machine)}}

      false ->
        {:noreply,
         %{state | machines: MapSet.delete(state.machines, machine |> Map.put(:persist, true) |> Map.put(:opts, machine[:opts] |> Keyword.update(:persist, true, fn _ -> true end)))}}
    end
  end

  def handle_info({:links_pub, link}, state) do
    case link[:persist] do
      true ->
        {:noreply, %{state | links: MapSet.put(state.links, link)}}

      false ->
        {:noreply,
          %{state | links: MapSet.delete(state.links, link |> Map.put(:persist, true) |> Map.put(:opts, link[:opts] |> Keyword.update(:persist, true, fn _ -> true end)))}}
    end
  end
end
