defmodule LambentEx.Link do
  @moduledoc false
  use GenServer

  @pubsub_name LambentEx.PubSub
  @pubsub_topic "machine-"
  @pubsub_topic_idx "links_idx"
  @pubsub_pfx_on "links_on_"

  @registry :lambent_links

  def start_link(_args, opts) do
    GenServer.start_link(__MODULE__, opts, name: via_tuple("link-#{opts[:name]}"))
  end

  def init(opts) do
    Process.send_after(self(), :publish, 50)
    {:ok, opts} = Keyword.validate(opts, [:source, :target, :name, :persist])
    Phoenix.PubSub.subscribe(@pubsub_name, @pubsub_topic <> opts[:source])
    Phoenix.PubSub.subscribe(@pubsub_name, @pubsub_pfx_on <> opts[:target])

    state = %{
      source: opts[:source],
      target: opts[:target],
      name: opts[:name],
      enabled: true,
      started: DateTime.utc_now(),
      persist: opts[:persist] || false,
      full_opts: opts
    }

    neighbor_on(state)

    # todo
    # publish-pause-siblings
    # subscribe-pause-siblings

    {
      :ok,
      state
    }
  end

  defp via_tuple(name), do: {:via, Registry, {@registry, name}}

  # public

  def toggle(id) do
    via_tuple("link-#{id}") |> GenServer.cast(:do_toggle)
  end

  def persist(id) do
    via_tuple("link-#{id}") |> GenServer.cast(:persist)
  end

  def quit(id) do
    via_tuple("link-#{id}") |> GenServer.cast(:quit)
  end

  defp publish(state) do
    %{
      name: state[:name],
      source: state[:source],
      target: state[:target],
      enabled: state[:enabled],
      persist: state[:persist],
      opts: state[:full_opts] |> Keyword.update(:persist, true, fn _ -> state[:persist] end)
    }
  end

  defp neighbor_on(state) do
    Phoenix.PubSub.broadcast(
      @pubsub_name,
      @pubsub_pfx_on <> state[:target],
      {:neighbor_on, state[:name]}
    )
  end

  @impl true
  def handle_info({:publish, data}, state) do
    case state[:enabled] do
      true -> LambentEx.Scan.ESP8266x7777.submit(state[:target], data |> List.flatten())
      false -> :ok
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(:publish, state) do
    Process.send_after(self(), :publish, 400)
    Phoenix.PubSub.broadcast(@pubsub_name, @pubsub_topic_idx, {:links_pub, publish(state)})
    {:noreply, state}
  end

  @impl true
  def handle_info({:neighbor_on, id}, state) do
    case state[:name] == id do
      true -> {:noreply, state}
      false -> {:noreply, %{state | enabled: false}}
    end
  end

  @impl true
  def handle_cast(:do_toggle, state) do
    case state[:enabled] do
      true ->
        {:noreply, %{state | enabled: false}}

      false ->
        neighbor_on(state)
        {:noreply, %{state | enabled: true}}
    end
  end

  @impl
  def handle_cast(:quit, state) do
    LambentEx.LinkSupervisor.abort_child(self())
    {:noreply, state}
  end

  @impl true
  def handle_cast(:persist, state) do
    {:noreply, state |> Map.put(:persist, !state.persist)}
  end
end
