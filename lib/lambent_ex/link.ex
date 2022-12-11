defmodule LambentEx.Link do
  @moduledoc false
  use Parent.GenServer

  @pubsub_name LambentEx.PubSub
  @pubsub_topic "machine-"

  @registry :lambent

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: via_tuple("link-#{opts[:name]}"))
  end

  def init(_opts) do
    Phoenix.PubSub.subscribe(@pubsub_name, @pubsub_topic)

    # gets overwritten
    {
      :ok,
      %{}
    }
  end

  defp via_tuple(name), do: {:via, Registry, {@registry, name}}

  def handle_info({:publish, data}, state) do
    IO.puts("hhh")

    dvcs =
      [
        {192, 168, 13, 203},
        {192, 168, 13, 209},
        {192, 168, 13, 211},
        {192, 168, 13, 214},
        {192, 168, 13, 215},
        {192, 168, 13, 222},
        {192, 168, 13, 225},
        {192, 168, 13, 228},
        {192, 168, 13, 230},
        {192, 168, 13, 241}
      ]

    dvcs = [
      "10:52:1c:02:8c:12",
      "10:52:1c:02:d4:d2",
      "18:fe:34:d4:7a:b5",
      "68:c6:3a:a4:d3:b6",
      "8c:aa:b5:1b:46:09",
      "a4:cf:12:b3:fc:b6",
      "ec:fa:bc:c0:96:98",

    ]

    for i <- dvcs do
      LambentEx.Scan.ESP8266x7777.submit(i, data |> List.flatten)
    end
    #    IO.inspect(data)

    {:noreply, state}
  end
end