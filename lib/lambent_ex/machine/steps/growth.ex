defmodule LambentEx.Machine.Steps.Growth.Cfg do
  #   @enforce_keys [:h]
  defstruct h_g: [0, 128],
            h_d: [0, 128],
            min_g: 10,
            max_g: 50,
            min_d: 5,
            max_d: 25,
            lb_min: 30,
            lb_max: 130,
            s: 255,
            v: 255,
            id: 0,
            status: 0
end

defmodule LambentEx.Machine.Steps.Growth do
  @moduledoc false
  use GenServer
  #  @behaviour LambentEx.Machine.Steps

  @registry :lambent_steps
  @cls :growth

  alias LambentEx.Machine.Steps.Growth.Cfg
  alias LambentEx.Utils.Color

  defp n(opts) do
    "#{@cls}-#{opts[:name]}-#{opts[:id]}"
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: via_tuple(n(opts)))
  end

  def init(opts) do
    opts = opts |> Map.put(:status, opts.id)
    cfg = struct(%LambentEx.Machine.Steps.Growth.Cfg{}, opts) |> Map.from_struct()

    {:ok,
     cfg
     |> Map.put(:hues, generate_hues(cfg))}
  end

  defp via_tuple(name) do
    {:via, Registry, {@registry, name}}
  end

  defp read(state) do
    List.pop_at(state[:hues], 0)
  end

  def handle_cast(:step, state) do
    state = case state[:hues] |> length do
      0 -> %{state | hues: generate_hues(state)}
      _otherwise -> state
    end
    {:noreply, state}
  end

  defp listy(v) when is_tuple(v) do
    v |> Tuple.to_list
  end

  defp listy(v) do
    v
  end

  def handle_call(:read, _from, state) do
    {reply, hues} = read(state)
    reply = case reply do
      nil -> [0,0,0]
      val -> reply |> listy |> Color.hsv2rgb
    end
    {:reply, reply, %{state | hues: hues}}
  end

  defp expand(values) do
    values
    |> Enum.map(fn {val, lingerd} ->
      expanded = multier(val, lingerd)
    end)
    |> List.flatten()
  end

  defp multier(v, qty), do: [] ++ for(_i <- 0..qty, do: v)

  def generate_hues(state) do
    growths =
      state[:h_g]
      |> Enum.map(fn x -> {x, Enum.random(state[:min_g]..state[:max_g])} end)
      |> expand

    deaths =
      state[:h_d]
      |> Enum.map(fn x -> {x, Enum.random(state[:min_d]..state[:max_d])} end)
      |> expand

    lingerd = Enum.random(state[:lb_min]..state[:lb_max])

    {g,d} = {growths |> List.last, deaths |> List.first}
    intermediate = cond do
      {g == d} -> multier(d, lingerd)
      {g != d} ->
        l0 = multier(g, div(lingerd, 3))
        l1 = multier(d, div(lingerd, 3))
        lbt = g..d
        l0 ++ lbt ++ l1
    end

    final_hues =  growths ++ intermediate ++ deaths
    v_first = final_hues |> List.first
    v_last = final_hues |> List.last

    intro_hues = multier(v_first, state[:v])
    intro_sats = multier(state[:s], state[:v])
    intro_vals = [] ++ 0..state[:v]

    outro_hues = multier(v_last, state[:v])
    outro_sats = multier(state[:s], state[:v])
    outro_vals = [] ++ state[:v]..0

    intro_trips = Enum.zip([intro_hues, intro_sats, intro_vals])
    outro_trips = Enum.zip([outro_hues, outro_sats, outro_vals])
    intermediate = final_hues |> Enum.map(fn h -> [h, state[:s], state[:v]] end)

    intro_trips ++ intermediate ++ outro_trips ++ multier([0,0,0], lingerd)
  end
end
