defmodule LambentEx.Scan.ESP8266x7777 do
  @moduledoc false
  use GenServer
  require Logger

  alias LambentEx.Utils.Color, as: C

  @registry :lambent
  @s "ꙭ📡"
  @filtered_prefixes ["br", "docker", "lo"]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: via_tuple("scan_8266"))
  end

  def init(_opts) do
    {:ok, socket} = :gen_udp.open(0, [:binary])
    Process.send_after(self(), :arp, :timer.seconds(1))
    Process.send_after(self(), :scan, :timer.seconds(3))
    interfaces = get_valid_interfaces()
    # gets overwritten
    {:ok,
     %{
       interfaces: interfaces,
       arps: %{},
       devices: %{"10:52:1c:02:d4:d2" => %{"ip" => {192, 168, 13, 226}, "name" => "AssFace3k", "ord" => :rgb}},
       socket: socket
     }}
  end

  defp via_tuple(name), do: {:via, Registry, {@registry, name}}

  # public

  def rename(:mac, mac, name) do
    via_tuple("scan_8266") |> GenServer.call({:rename_mac, mac, name})
  end

  def rename(:ip, ip, name) do
    via_tuple("scan_8266") |> GenServer.call({:rename_ip, ip, name})
  end

  # impls

  @impl true
  def handle_call({:rename_mac, mac, name}, _from, state) do
    d = state[:devices] |> Map.get(mac)
    dev = state[:devices] |> Map.put(mac, d |> Map.put("name", name))
    {:reply, :ok, %{state | devices: dev}}
  end

  def handle_call({:rename_ip, ip, name}, _from, state) do
    mac = state[:arps] |> Map.get(ip)
    d = state[:devices] |> Map.get(mac)
    state = state[:devices] |> Map.put(mac, d |> Map.put("name", name))
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  @impl true
  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  def query_http(ip) do
    case HTTPoison.get("http://#{ip |> Tuple.to_list() |> Enum.join(".")}", [],
           hackney: [pool: :default]
         ) do
      {:ok, resp} ->
        case resp.status_code do
          404 ->
            case resp.body do
              "File not found." -> {:lambent, ip}
              _other -> {:not_lambent, ip}
            end

          _other ->
            {:not_lambent, ip}
        end

      {:error, _err} ->
        {:not_lambent, ip}
    end
  end

  defp rgb_shift(stream, device) do
    chunked = Enum.chunk_by(stream, 3)
    case device |> Map.get(:ord) do
      :rgb -> chunked
      :grb -> chunked |> Enum.map(fn [r, g, b] -> [g, r, b] end)
      :rgbww -> chunked |> Enum.map(fn [r, g, b] -> [r, g, b, Enum.min(C.wrgb([r, g, b]), r)] end)
      :rgbnw -> chunked |> Enum.map(fn [r, g, b] -> [r, g, b, C.wrgb([r, g, b])] end)
      :rgbcw -> chunked |> Enum.map(fn [r, g, b] -> [r, g, b, Enum.min([C.wrgb([r, g, b]), b])] end)
      :rgbaw -> chunked |> Enum.map(fn [r, g, b] -> [r, g, b, C.argb([r, g, b]), C.wrgb([r, g, b])] end)
      :rgbxw -> chunked |> Enum.map(fn [r, g, b] -> [r, g, b, 0] end)
      nil -> chunked
    end
    |> List.flatten
  end

  defp rgb_stream(stream) do
    stream # TOOD FIGURE OUT HOW TO RECREATE THE PYTHON PACKING
  end

  @impl
  def handle_cast({:submit, dvc, stream}, state) do
    case state[:devices] |> Map.get(dvc) do
      nil -> {:noreply, state}
      device ->
        :gen_udp.send(state.socket, device[:ip], 7777, rgb_shift(stream, device) |> rgb_stream)
        {:noreply, state}
    end
  end

  @impl true
  def handle_info(:arp, state) do
    Process.send_after(self(), :arp, :timer.seconds(15))
    Logger.notice("#{@s} Updating ARP tables")

    curr = state[:arps]

    neighbors =
      :os.cmd('ip neighbor show')
      |> to_string
      |> String.split("\n")
      |> Enum.filter(fn x ->
        case x |> String.split(" ", trim: true) do
          [_ip, _dev, _iface, _smth, _mac, "REACHABLE"] -> true
          [_ip, _dev, _iface, _smth, _mac, "DELAY"] -> true
          [_ip, _dev, _iface, _smth, _mac, "STALE"] -> true
          [_ip, _dev, _iface, _smth, _mac, "PROBE"] -> true
          [_ip, _dev, _iface, "INCOMPLETE"] -> false
          [_ip, _dev, _iface, "FAILED"] -> false
          [] -> false
        end
      end)
      |> Enum.map(fn x ->
        [ip, _dev, iface, _smth, mac, _status] = x |> String.split(" ", trim: true)
        %{iface: iface, ip: ip, mac: mac}
      end)
      |> Enum.reduce(
        curr,
        fn x, acc ->
          acc
          |> Map.put(
            x.iface,
            Map.get(acc, x.iface, %{}) |> Map.put(x.ip |> IP.from_string!(), x.mac)
          )
        end
      )

    {:noreply, %{state | arps: neighbors}}
  end

  @impl true
  def handle_info(:scan, state) do
    Process.send_after(self(), :scan, :timer.seconds(60))
    Logger.notice("#{@s} Scanning for ws2812esp8266i2s instances")

    instances =
      state.interfaces
      |> Enum.map(fn {i, v} ->
        addr = v |> Keyword.get(:addr)
        nm = v |> Keyword.get(:netmask) |> LambentEx.Utils.Network.get_netmask()

        lambents =
          LambentEx.Utils.Network.get_ip_range(addr, nm)
          |> Enum.map(&Task.async(fn -> query_http(&1) end))
          |> Enum.map(fn x -> Task.await(x, 15000) end)
          |> Enum.filter(fn {return, _value} -> return == :lambent end)
          |> Enum.map(fn x -> x |> Kernel.elem(1) end)

        Logger.notice("#{@s} Found #{lambents |> Kernel.length()} on #{i}")
        {i |> to_string, lambents}
      end)
      |> Map.new()

    state = join_new_instances_old(instances, state)

    {:noreply, state}
  end

  defp join_new_instances_old(new, state) do
    devices = state[:devices]
    arps = state[:arps]

    rez =
      new
      |> Enum.map(fn {if, arr} ->
        arr
        |> Enum.map(fn ip ->
          mac = Map.get(arps[if], ip)
          {Map.get(arps[if], ip), Map.get(devices, mac, %{}) |> Map.put("ip", ip)}
        end)
        |> Map.new()
      end)
      |> Enum.reduce(fn x, y ->
        Map.merge(x, y, fn _k, v1, v2 -> v2 ++ v1 end)
      end)

    state |> Map.put(:devices, rez)
  end

  def get_valid_interfaces() do
    {:ok, addrs} = :inet.getifaddrs()

    addrs
    |> Enum.filter(fn x ->
      case Kernel.elem(x, 1) |> Keyword.get(:addr) do
        nil -> false
        addr -> Kernel.tuple_size(addr) == 4
      end
    end)
    |> Enum.filter(fn x ->
      !Enum.any?(@filtered_prefixes, fn y ->
        String.starts_with?(Kernel.elem(x, 0) |> to_string, y)
      end)
    end)
    |> Map.new()
  end
end
