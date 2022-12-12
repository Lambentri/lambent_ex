defmodule LambentEx.Link do
  @moduledoc false
  use Parent.GenServer

  @pubsub_name LambentEx.PubSub
  @pubsub_topic "machine-"
  @pubsub_topic_idx "links_idx"

  @registry :lambent_links

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: via_tuple("link-#{opts[:name]}"))
  end

  def init(opts) do
    Process.send_after(self(), :publish, 50)
    {:ok, opts} = Keyword.validate(opts, [:source, :target, :name])
    Phoenix.PubSub.subscribe(@pubsub_name, @pubsub_topic <> opts[:source])

    # todo
    # publish-pause-siblings
    # subscribe-pause-siblings

    {
      :ok,
      %{
        source: opts[:source],
        target: opts[:target],
        name: opts[:name],
        enabled: true,
      }
    }
  end

  defp via_tuple(name), do: {:via, Registry, {@registry, name}}

  defp publish(state) do
    %{
      name: state[:name],
      source: state[:source],
      target: state[:target],
      enabled: state[:enabled]
    }
  end

  def handle_info({:publish, data}, state) do
    case state[:enabled] do
      true -> LambentEx.Scan.ESP8266x7777.submit(state[:target], data |> List.flatten)
      false -> :ok
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(:publish, state) do
    Process.send_after(self(), :publish, 400)
    Phoenix.PubSub.broadcast(@pubsub_name, @pubsub_topic_idx, {:publish, publish(state)})
    {:noreply, state}
  end
end