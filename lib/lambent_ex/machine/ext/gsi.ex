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

  def generate_flash(state, color, ticks, value) do
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

  # game state
  defp read(:dota_map_day, state), do: state[:gs] |> get_in(["map", "daytime"]) || false
  defp read(:dota_clock_time, state), do: state[:gs] |> get_in(["map", "clock_time"]) || 0
  defp read(:dota_game_time, state), do: state[:gs] |> get_in(["map", "game_time"]) || 0
  defp read(:dota_score_r, state), do: state[:gs] |> get_in(["map", "radiant_score"]) || 0
  defp read(:dota_score_d, state), do: state[:gs] |> get_in(["map", "dire_score"]) || 0
  defp read(:dota_paused, state), do: state[:gs] |> get_in(["map", "paused"]) || false
  defp read(:dota_team, state), do: state[:gs] |> get_in(["player", "team_name"])
  defp read(:dota_ward_purchase_cooldown, state), do: state[:gs] |> get_in(["map", "ward_purchase_cooldown"])
  # scoring
  defp read(:dota_player_kills, state), do: state[:gs] |> get_in(["player", "kills"]) || 0
  defp read(:dota_player_deaths, state), do: state[:gs] |> get_in(["player", "deaths"]) || 0
  defp read(:dota_player_assists, state), do: state[:gs] |> get_in(["player", "assists"]) || 0
  defp read(:dota_player_denies, state), do: state[:gs] |> get_in(["player", "denies"]) || 0
  defp read(:dota_player_last_hits, state), do: state[:gs] |> get_in(["player", "last_hits"]) || 0
  defp read(:dota_player_kill_streak, state), do: state[:gs] |> get_in(["player", "kill_streak"]) || 0
  # gold
  defp read(:dota_player_xpm, state), do: state[:gs] |> get_in(["player", "xpm"]) || 0
  defp read(:dota_player_gpm, state), do: state[:gs] |> get_in(["player", "gpm"]) || 0
  defp read(:dota_player_gold, state), do: state[:gs] |> get_in(["player", "gold"]) || 1
  defp read(:dota_player_gold_unreliable, state), do: state[:gs] |> get_in(["player", "gold_unreliable"]) || 1
  defp read(:dota_player_gold_reliable, state), do: state[:gs] |> get_in(["player", "gold_reliable"]) || 1
  defp read(:dota_player_gold_from_creep_kills, state), do: state[:gs] |> get_in(["player", "gold_from_creep_kills"]) || 0
  defp read(:dota_player_gold_from_hero_kills, state), do: state[:gs] |> get_in(["player", "gold_from_hero_kills"]) || 0
  defp read(:dota_player_gold_from_income, state), do: state[:gs] |> get_in(["player", "gold_from_income"]) || 0
  defp read(:dota_player_gold_from_shared, state), do: state[:gs] |> get_in(["player", "gold_from_shared"]) || 0
  # numbers
  defp read(:dota_mana, state), do: state[:gs] |> get_in(["hero", "mana"]) || 0
  defp read(:dota_mana_max, state), do: state[:gs] |> get_in(["hero", "max_mana"]) || 1
  defp read(:dota_mana_pct, state), do: state[:gs] |> get_in(["hero", "mana_percent"]) || 0
  defp read(:dota_health, state), do: state[:gs] |> get_in(["hero", "health"]) || 0
  defp read(:dota_health_max, state), do: state[:gs] |> get_in(["hero", "max_health"]) || 1
  defp read(:dota_health_pct, state), do: state[:gs] |> get_in(["hero", "health_percent"]) || 0
  # statuses
  defp read(:dota_hero_smoked, state), do: state[:gs] |> get_in(["hero", "smoked"]) ||false
  defp read(:dota_hero_alive, state), do: state[:gs] |> get_in(["hero", "alive"]) || false
  defp read(:dota_hero_muted, state), do: state[:gs] |> get_in(["hero", "muted"]) || false
  defp read(:dota_hero_break, state), do: state[:gs] |> get_in(["hero", "break"]) || false
  defp read(:dota_hero_hexed, state), do: state[:gs] |> get_in(["hero", "hexed"]) || false
  defp read(:dota_hero_silenced, state), do: state[:gs] |> get_in(["hero", "silenced"]) || false
  defp read(:dota_hero_has_debuff, state), do: state[:gs] |> get_in(["hero", "has_debuff"]) || false
  defp read(:dota_hero_disarmed, state), do: state[:gs] |> get_in(["hero", "disarmed"]) || false
  defp read(:dota_hero_stunned, state), do: state[:gs] |> get_in(["hero", "stunned"]) || false
  defp read(:dota_hero_magicimmune, state), do: state[:gs] |> get_in(["hero", "magicimmune"]) || false
  # hero
  defp read(:dota_hero_xpos, state), do: state[:gs] |> get_in(["map", "xpos"]) || 0
  defp read(:dota_hero_ypos, state), do: state[:gs] |> get_in(["map", "ypos"]) || 0
  defp read(:dota_hero_level, state), do: state[:gs] |> get_in(["hero", "level"]) || 0
  defp read(:dota_hero_xp, state), do: state[:gs] |> get_in(["hero", "xp"]) || 0
  defp read(:dota_hero_attributes_level, state), do: state[:gs] |> get_in(["hero", "attributes_level"]) || 0
  defp read(:dota_hero_respawn_seconds, state), do: state[:gs] |> get_in(["hero", "respawn_seconds"]) || 0
  defp read(:dota_hero_buyback_money, state), do: state[:gs] |> get_in(["hero", "buyback_cost"]) || 0
  defp read(:dota_hero_buyback_seconds, state), do: state[:gs] |> get_in(["hero", "buyback_cooldown"]) || 0
  # talents
  defp read(:dota_hero_aghs_scepter, state), do: state[:gs] |> get_in(["hero", "aghanims_scepter"]) || false
  defp read(:dota_hero_aghs_shard, state), do: state[:gs] |> get_in(["hero", "aghanims_shard"]) || false
  defp read(:dota_hero_talent_1, state), do: state[:gs] |> get_in(["hero", "talent_1"]) || false
  defp read(:dota_hero_talent_2, state), do: state[:gs] |> get_in(["hero", "talent_2"]) || false
  defp read(:dota_hero_talent_3, state), do: state[:gs] |> get_in(["hero", "talent_3"]) || false
  defp read(:dota_hero_talent_4, state), do: state[:gs] |> get_in(["hero", "talent_4"]) || false
  defp read(:dota_hero_talent_5, state), do: state[:gs] |> get_in(["hero", "talent_5"]) || false
  defp read(:dota_hero_talent_6, state), do: state[:gs] |> get_in(["hero", "talent_6"]) || false
  defp read(:dota_hero_talent_7, state), do: state[:gs] |> get_in(["hero", "talent_7"]) || false
  defp read(:dota_hero_talent_8, state), do: state[:gs] |> get_in(["hero", "talent_8"]) || false
  # abilities
  defp read(:dota_hero_ability_1, state), do: state[:gs] |> get_in(["hero", "ability_1"]) || %{}
  defp read(:dota_hero_ability_2, state), do: state[:gs] |> get_in(["hero", "ability_2"]) || %{}
  defp read(:dota_hero_ability_3, state), do: state[:gs] |> get_in(["hero", "ability_3"]) || %{}
  defp read(:dota_hero_ability_4, state), do: state[:gs] |> get_in(["hero", "ability_4"]) || %{}
  defp read(:dota_hero_ability_5, state), do: state[:gs] |> get_in(["hero", "ability_5"]) || %{}
  defp read(:dota_hero_ability_6, state), do: state[:gs] |> get_in(["hero", "ability_6"]) || %{}
  defp read(:dota_hero_ability_7, state), do: state[:gs] |> get_in(["hero", "ability_7"]) || %{}
  defp read(:dota_hero_ability_8, state), do: state[:gs] |> get_in(["hero", "ability_8"]) || %{}
  ## these are passed in the result of above eg; read(:dota_hero_ability_active, read(:dota_hero_ability_1, state))
  defp read(:dota_hero_ability_active, state), do: state |> Map.get("ability_active") || false
  defp read(:dota_hero_ability_can_cast, state), do: state |> Map.get("can_cast") || false
  defp read(:dota_hero_ability_charge_cooldown, state), do: state |> Map.get("charge_cooldown") || 0
  defp read(:dota_hero_ability_charges, state), do: state |> Map.get("charges") || 0
  defp read(:dota_hero_ability_cooldown, state), do: state |> Map.get("cooldown") || 0
  defp read(:dota_hero_ability_level, state), do: state |> Map.get("level") || 0
  defp read(:dota_hero_ability_max_charges, state), do: state |> Map.get("max_charges") || 0
  defp read(:dota_hero_ability_name, state), do: state |> Map.get("name")
  defp read(:dota_hero_ability_passive, state), do: state |> Map.get("passive") || false
  defp read(:dota_hero_ability_ultimage, state), do: state |> Map.get("ultimate") || false
  # building statuses # todo
  # items # todo
  # wearables # todo

  defp read(:dota, state) do
    %{
      health_fill: generate_fill(state, {@green, @whitish}, read(:dota_health, state), read(:dota_health_max, state)),
      health_bright: [],
      mana_fill: generate_fill(state, {@blue, @whitish}, read(:dota_mana, state), read(:dota_mana_max, state)),
      mana_bright: [],
      money_reliable_fill: generate_fill(state, {@yellow, @whitish}, read(:dota_player_gold_reliable, state), read(:dota_player_gold, state)),
      money_reiiable_bright: []
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
    if name == state[:name] do
      flashes = delta(data, state)
      {:noreply, state |> Map.put(:path, path) |> Map.put(:gs, data)}
    else
      {:noreply, state}
    end
  end
end
