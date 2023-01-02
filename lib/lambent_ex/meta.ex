defmodule LambentEx.Meta do
  use GenServer

  @table :lex_metadata
  @pubsub_name LambentEx.PubSub

  def init(arg) do
    File.cd("meta")
    {:ok, table} = :dets.open_file(@table, type: :set)
    File.cd("..")

    Phoenix.PubSub.subscribe(@pubsub_name, "machines_idx")
    Process.send_after(self(), :machine_flush, 5000)
    ml = MapSet.new()

    {:ok, %{table: table, machines: ml}}
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

  def handle_info({:machines_pub, machine}, state) do
    case machine[:persist] do
      true ->
        {:noreply, %{state | machines: MapSet.put(state.machines, machine)}}

      false ->
#        IO.inspect(machine)
        {:noreply,
         %{state | machines: MapSet.delete(state.machines, machine |> Map.put(:persist, true) |> Map.put(:opts, machine[:opts] |> Keyword.update(:persist, true, fn _ -> true end)))}}
    end
  end
end
