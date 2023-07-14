defmodule LambentEx.Cronos do
  use GenServer

  require Logger
  @s "⏰🐻"

  def init(arg) do
    Logger.info(
      "#{@s} Cronos waits to start the first tick until the top of the minute, it's currently #{DateTime.utc_now().second} seconds past."
    )

    Process.send_after(self(), :work, :timer.seconds(60 - DateTime.utc_now().second + 1))
    {zone, result} = System.cmd("date", ["+%Z"])
    zone = zone |> String.trim
    zone = case zone do
      "EDT" -> "America/New_York"
      _otherwise -> zone
    end

    Logger.info(
    "#{@s} Cronos uses the system timezone to determine when to tick and when to sleep, we've found this to be '#{zone}'"
    )
    if result == 0 do
      {:ok, %{tz: zone |> String.trim()}}
    else
      {:ok, %{tz: "UTC"}}
    end
  end

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def group(cronos, state) do
    {:ok, now} = DateTime.now(state[:tz])

    cronos
    |> Enum.map(fn {key, value} -> value end)
    |> Enum.filter(fn val -> val[:time].minute == now.minute and val[:time].hour == now.hour end)
  end

  def handle_info(:work, state) do
    Process.send_after(self(), :work, :timer.minutes(1))
    curr = LambentEx.Meta.get_cronos() |> group(state)

    for i <- curr do
      case i[:action] do
        :machine_speed ->
          case i[:arg] do
            :faster ->
              i[:targets] |> Enum.map(&LambentEx.Machine.faster/1)

            :slower ->
              i[:targets] |> Enum.map(&LambentEx.Machine.slower/1)

            otherwise ->
              i[:targets] |> Enum.map(fn t -> LambentEx.Machine.set_speed(t, otherwise) end)
          end

        :machine_bright ->
          case i[:arg] do
            :dimmer ->
              i[:targets] |> Enum.map(&LambentEx.Machine.dimmer/1)

            :brighter ->
              i[:targets] |> Enum.map(&LambentEx.Machine.brighter/1)

            otherwise ->
              i[:targets] |> Enum.map(fn t -> LambentEx.Machine.set_brightness(t, otherwise) end)
          end

        :link_toggle ->
          i[:targets] |> Enum.map(&LambentEx.Link.toggle/1)
      end
    end

    {:noreply, state}
  end
end

### Examples
# LambentEx.Meta.put_cronos("testa", %{time: ~T[23:10:00], action: :machine_speed, arg: :slower, targets: ["red"]})
# LambentEx.Meta.put_cronos("testb", %{time: ~T[23:11:00], action: :machine_speed, arg: :faster, targets: ["red"]})
# LambentEx.Meta.put_cronos("testc", %{time: ~T[23:10:00], action: :machine_bright, arg: :dimmer, targets: ["red"]})
# LambentEx.Meta.put_cronos("testd", %{time: ~T[23:12:00], action: :machine_bright, arg: :brighter, targets: ["red"]})
