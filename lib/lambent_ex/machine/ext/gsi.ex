defmodule LambentEx.Machine.Ext.GSI.Cfg do
  #   @enforce_keys [:h]
  defstruct [:src, :game, :count, :name, id: 0, flash_mticks: 8, flash_cticks: %{}]
end

defmodule LambentEx.Machine.Ext.GSI do
  @moduledoc false
  use GenServer

  @registry :lambent_steps
  @cls :gsi

  @pubsub_name LambentEx.PubSub
  @pubsub_topic "http_pubs"

  @red [200, 0, 0]
  @green [0, 200, 0]
  @blue [0, 0, 200]
  @yellow [180, 180, 0]

  @black [0, 0, 0]
  @blackish [15, 15, 15]
  @whitish [200, 200, 200]
  @csgo_blue [93, 121, 174]
  @csgo_orange [222, 155, 53]
  @csgo_tan [204, 186, 124]
  @csgo_money [77, 119, 41]

  @csgo_max_money 10000
  @csgo_max_health 100

  alias LambentEx.Machine.Ext.GSI.Cfg
  alias LambentEx.Utils.Color

  defp n(opts) do
    "#{@cls}-#{opts[:name]}-#{opts[:id]}"
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: via_tuple(n(opts)))
  end

  def init(opts) do
    opts = opts |> Map.put(:status, opts.id)
    cfg = struct(%Cfg{}, opts) |> Map.from_struct()

    Phoenix.PubSub.subscribe(@pubsub_name, @pubsub_topic)

    {:ok, cfg |> Map.put(:gs, %{})}
  end

  defp via_tuple(name) do
    {:via, Registry, {@registry, name}}
  end

  defp delta(data, state) do
    #    IO.puts("delta")
    #    IO.inspect(data, pretty: true)
    #    IO.inspect(MapDiff.diff(data, state[:gs]), pretty: true)
  end

  defp current_team_color(state) do
    case read(:csgo_team, state) do
      "T" -> @csgo_orange
      "CT" -> @csgo_blue
      nil -> @csgo_tan
    end
  end

  defp generate_fill(state, color, nil) do
    []
  end

  defp generate_fill(state, color, %{min: min, max: max}),
    do: generate_fill(state, color, min, max)

  # fill
  defp generate_fill(state, color, min) do
    []
  end

  defp generate_fill(state, {color_low, color_high}, min, max) do
#    IO.inspect({color_low, color_high, min, max, state[:count]})
    qty = (min / max * state[:count]) |> trunc
    rem = state[:count] - qty
    colored = color_high |> Stream.cycle() |> Enum.take(qty * 3)
    background = color_low |> Stream.cycle() |> Enum.take(rem * 3)
    colored ++ background
  end

  defp generate_fill(state, color, min, max) do
    #    IO.inspect({color, min, max, state[:count]})
    qty = (min / max * state[:count]) |> trunc
    rem = state[:count] - qty
    colored = color |> Stream.cycle() |> Enum.take(qty * 3)
    background = @blackish |> Stream.cycle() |> Enum.take(rem * 3)
    colored ++ background
  end

  defp generate_bright(state, {color_low, color_high}, min, max) do
    []
  end

  defp generate_bright(state, color, %{min: min, max: max}),
    do: generate_bright(state, color, min, max)

  defp generate_bright(state, color, min, max) do
    []
  end

  defp read(:csgo_team, state), do: state[:gs] |> get_in(["player", "team"])
  defp read(:csgo_health, state), do: state[:gs] |> get_in(["player", "state", "health"]) || 0
  defp read(:csgo_armor, state), do: state[:gs] |> get_in(["player", "state", "armor"]) || 0
  defp read(:csgo_money, state), do: state[:gs] |> get_in(["player", "state", "money"]) || 0
  defp read(:csgo_kills, state), do: state[:gs] |> get_in(["player", "match_stats", "kills"]) || 0

  defp read(:csgo_deaths, state),
    do: state[:gs] |> get_in(["player", "match_stats", "deaths"]) || 0

  defp read(:csgo_assists, state),
    do: state[:gs] |> get_in(["player", "match_stats", "assists"]) || 0

  defp read(:csgo_mvps, state), do: state[:gs] |> get_in(["player", "match_stats", "mvps"]) || 0
  defp read(:csgo_score, state), do: state[:gs] |> get_in(["player", "match_stats", "score"]) || 0
  defp read(:csgo_wins_t, state), do: state[:gs] |> get_in(["map", "team_t", "score"]) || 0
  defp read(:csgo_wins_ct, state), do: state[:gs] |> get_in(["map", "team_ct", "score"]) || 0
  defp read(:csgo_flash, state), do: state[:gs] |> get_in(["player", "state", "flashed"]) || 0
  defp read(:csgo_burn, state), do: state[:gs] |> get_in(["player", "state", "burning"]) || 0
  defp read(:csgo_smoke, state), do: state[:gs] |> get_in(["player", "state", "smoked"]) || 0

  # complexer
  defp read(:csgo_bullets, state) do
    case state[:gs] do
      val when map_size(val) == 0 ->
        %{min: 0, max: state[:count]}

      _otherwise ->
        {_idx, weapon} =
          state[:gs]
          |> get_in(["player", "weapons"])
          |> Enum.filter(fn {_k, v} -> Enum.member?(["active", "reloading"], v["state"]) end)
          |> List.first()

        cond do
          weapon == %{} ->
            %{min: 0, max: state[:count]}

          weapon["type"] == "Knife" ->
            %{min: 0, max: state[:count]}

          weapon["type"] == "C4" ->
            %{min: 1, max: 1}

          true ->
            %{min: weapon["ammo_clip"], max: weapon["ammo_clip_max"]}
        end
    end
  end

  defp read(:csgo_wins_curr, state) do
    case read(:csgo_team, state) do
      "T" -> read(:csgo_wins_t, state)
      "CT" -> read(:csgo_wins_ct, state)
      nil -> 0
    end
  end

  defp read(:csgo_bomb, state), do: state[:gs]

  defp read(:csgo, state) do
    %{
      health_fill:
        generate_fill(state, {@red, @whitish}, read(:csgo_health, state), @csgo_max_health),
      health_bright:
        generate_bright(state, {@red, @whitish}, read(:csgo_health, state), @csgo_max_health),
      armor_fill:
        generate_fill(state, {@red, @whitish}, read(:csgo_armor, state), @csgo_max_health),
      armor_bright:
        generate_bright(state, {@red, @whitish}, read(:csgo_armor, state), @csgo_max_health),
      money_fill: generate_fill(state, @csgo_money, read(:csgo_money, state), @csgo_max_money),
      money_bright:
        generate_bright(state, @csgo_money, read(:csgo_money, state), @csgo_max_money),
      bullets_fill: generate_fill(state, current_team_color(state), read(:csgo_bullets, state)),
      bullets_bright: generate_bright(state, @csgo_tan, read(:csgo_bullets, state)),
      kills_fill: generate_fill(state, current_team_color(state), read(:csgo_kills, state)),
      deaths_fill: generate_fill(state, current_team_color(state), read(:csgo_deaths, state)),
      assists_fill: generate_fill(state, current_team_color(state), read(:csgo_assists, state)),
      mvps_fill: generate_fill(state, current_team_color(state), read(:csgo_mvps, state)),
      score_fill: generate_fill(state, current_team_color(state), read(:csgo_score, state)),
      wins_t_fill: generate_fill(state, @csgo_orange, read(:csgo_wins_t, state), 13),
      wins_ct_fill: generate_fill(state, @csgo_blue, read(:csgo_wins_ct, state), 13),
      wins_curr_fill: generate_fill(state, @csgo_blue, read(:csgo_wins_curr, state), 13),
      round_wins_fill: [],
      team_fill: [],
      bomb_flash: [],
      flash_flash: generate_bright(state, @whitish, read(:csgo_flash, state), 1),
      burn_flash: generate_bright(state, @red, read(:csgo_burn, state), 1),
      smoke_flash: generate_bright(state, @csgo_tan, read(:csgo_smoke, state), 1),
      combined: []
    }
  end

  defp read(:dota, state) do
    %{
      health_fill: [],
      health_bright: [],
      mana_fill: [],
      mana_bright: [],
      money_fill: [],
      money_bright: []
    }
  end

  defp read(state) do
    case state[:gs] do
      nil ->
        %{}

      otherwise ->
        case state[:game] do
          :dota -> read(:dota, state)
          :csgo -> read(:csgo, state)
        end
    end
  end

  def handle_cast(:step, state) do
    # todo tick down flashers here
    {:noreply, state}
  end

  def handle_call(:read, _from, state) do
    {:reply, read(state), state}
  end

  def handle_info({name, path, data}, state) do
    IO.inspect({name, state[:name]})

    if name == state[:name] do
      #      IO.inspect(data)
      flashes = delta(data, state)
      {:noreply, state |> Map.put(:path, path) |> Map.put(:gs, data)}
    else
      {:noreply, state}
    end
  end
end
