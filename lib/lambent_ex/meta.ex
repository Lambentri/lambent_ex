defmodule LambentEx.Meta do
  use GenServer

  @table :lex_metadata
  @pubsub_name LambentEx.PubSub
  @pubsub_svc "svc_pub"

  def init(arg) do
    #    File.cd("meta")
    {:ok, table} = :dets.open_file(@table, type: :set)
    #    File.cd("..")

    Phoenix.PubSub.subscribe(@pubsub_name, "machines_idx")
    Phoenix.PubSub.subscribe(@pubsub_name, "links_idx")
    Phoenix.PubSub.subscribe(@pubsub_name, "mqtt_idx")
    Process.send_after(self(), :machine_flush, 5000)
    Process.send_after(self(), :link_flush, 5000)
    Process.send_after(self(), :svc_pub, 10)
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

  def get_place(mac) do
    case :dets.lookup(@table, "place-#{mac}") do
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

  def put_place(key, value) do
    :dets.insert(@table, {"place-#{key}", value})
  end

  # svcs
  defp put_gen(type, name, entry) do
    curr = get_gen(type)

    case length(curr) do
      0 -> :dets.insert(@table, {type, [{name, entry}]})
      _otherwise -> :dets.insert(@table, {type, curr ++ [{name, entry}]})
    end
  end

  defp del_gen(type, key) do
    to_delete = get_gen(type) |> Enum.filter(fn {k, _v} -> k == key end)

    :dets.insert(
      @table,
      {type, to_delete |> Enum.reduce(get_gen(type), fn x, acc -> acc |> List.delete(x) end)}
    )
  end

  defp get_gen(type) do
    case :dets.lookup(@table, type) do
      [] ->
        []

      [{_key, value}] ->
        value
    end
  end

  def put_http(name), do: put_http(name, Ecto.UUID.generate())
  def put_http(name, path), do: put_gen("http", name, path)
  def del_http(key), do: del_gen("http", key)
  def get_http, do: get_gen("http")

  def put_mqtt(name), do: put_mqtt(name, Ecto.UUID.generate())
  def put_mqtt(name, cfg), do: put_gen("mqtt", name, cfg)
  def del_mqtt(key), do: del_gen("mqtt", key)
  def get_mqtt, do: get_gen("mqtt")

  def put_cronos(name, cfg), do: put_gen("cronos", name, cfg)
  def del_cronos(key), do: del_gen("cronos", key)
  def get_cronos, do: get_gen("cronos")

  # init functions
  def get_saved_machines do
    case :dets.lookup(@table, "machs") do
      [] ->
        []

      [{_key, value}] ->
        value
    end
  end

  def get_saved_links do
    case :dets.lookup(@table, "links") do
      [] ->
        []

      [{_key, value}] ->
        value
    end
  end

  def get_saved_cfg_mqtt do
    case :dets.lookup(@table, "cfg_mqtt") do
      [] ->
        []

      [{_key, value}] ->
        value
    end
  end

  def get_saved_cfg_http do
    case :dets.lookup(@table, "cfg_http") do
      [] ->
        []

      [{_key, value}] ->
        value
    end
  end

  def clear_links() do
    :dets.delete(@table, "links")
  end

  def clear_machines() do
    :dets.delete(@table, "machs")
  end

  def clear_cfg_mqtt() do
    :dets.delete(@table, "cfg_mqtt")
  end

  def clear_cfg_http() do
    :dets.delete(@table, "cfg_http")
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

  def handle_info(:svc_pub, state) do
    Process.send_after(self(), :svc_pub, 500)

    Phoenix.PubSub.broadcast(@pubsub_name, @pubsub_svc, {:http, get_http})
    # Phoenix.PubSub.broadcast(@pubsub_name, @pubsub_svc, {:mqtt, get_mqtt})
    Phoenix.PubSub.broadcast(@pubsub_name, @pubsub_svc, {:cronos, get_cronos})
    {:noreply, state}
  end

  def handle_info({:machines_pub, machine}, state) do
    case machine[:persist] do
      true ->
        {:noreply, %{state | machines: MapSet.put(state.machines, machine)}}

      false ->
        {:noreply,
         %{
           state
           | machines:
               MapSet.delete(
                 state.machines,
                 machine
                 |> Map.put(:persist, true)
                 |> Map.put(
                   :opts,
                   machine[:opts] |> Keyword.update(:persist, true, fn _ -> true end)
                 )
               )
         }}
    end
  end

  def handle_info({:links_pub, link}, state) do
    case link[:persist] do
      true ->
        {:noreply, %{state | links: MapSet.put(state.links, link)}}

      false ->
        {:noreply,
         %{
           state
           | links:
               MapSet.delete(
                 state.links,
                 link
                 |> Map.put(:persist, true)
                 |> Map.put(
                   :opts,
                   link[:opts] |> Keyword.update(:persist, true, fn _ -> true end)
                 )
               )
         }}
    end
  end
end
