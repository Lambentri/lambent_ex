defmodule LambentEx.Machine do
  @moduledoc false
  use Parent.GenServer

  @registry :lambent

  @speeds %{
    # 1 => :THOU,
    # 5 => :FTHOU,
    10 => :HUNDREDTHS,
    50 => :FHUNDREDTHS,
    100 => :TENTHS,
    500 => :FTENTHS,
    1000 => :ONES,
    2000 => :TWOS,
    5000 => :FIVES,
    10000 => :TENS,
    20000 => :TWENTYS,
    30000 => :THIRTYS,
    60000 => :MINS
  }

  @brightness %{
    0 => :OFF,
    # 1 => :XDIM,
    3 => :SIXTYFOURTH,
    7 => :THIRTY2ND,
    15 => :SIXTEENTH,
    31 => :EIGHTH,
    63 => :QUARTER,
    127 => :HALF,
    # 191 => :THREEFOURTHS
    255 => :FULL
  }

  def start_link(_foo, opts) do
    Parent.GenServer.start_link(__MODULE__, opts, name: via_tuple("machine-#{opts[:name]}"))
  end

  def init(opts) do
    Process.send_after(self(), :step, 100)
    {:ok, opts} = Keyword.validate(opts, [:step, :step_opts, :name, count: 300])
    cnt = opts[:count]

    specs =
      1..cnt
      |> Enum.map(fn id ->
        Parent.child_spec({opts[:step], opts[:step_opts] |> Map.put(:id, id) |> Map.put(:name, opts[:name])})
      end)

    pids = specs |> Enum.map(fn x -> Parent.start_child(x)  |> IO.inspect end) |> Enum.filter(fn {status, pid} -> status == :ok end)
    pids = []

    {:ok,
     %{
       steps: pids,
       name: opts[:name],
       speed: 1000,
       bright_tgt: 255,
       bright_curr: 255,
       bright_delay: 0,
       bright_mvmul: 2,
       cnt: 0
     }}
    |> IO.inspect()
  end

  defp via_tuple(name), do: {:via, Registry, {@registry, name}}

  # public

  def faster(_id) do
    via_tuple("machine-opts-id") |> GenServer.cast(:faster)
  end

  def slower(_id) do
    via_tuple("machine-opts-id") |> GenServer.cast(:slower)
  end

  def brighter(_id) do
    via_tuple("machine-opts-id") |> GenServer.cast(:brighter)
  end

  def dimmer(_id) do
    via_tuple("machine-opts-id") |> GenServer.cast(:dimmer)
  end

  # impls

  @impl true
  def handle_info(:step, state) do
    Process.send_after(self(), :step, state.speed)
    #    IO.puts(state.cnt)
    {:noreply, bright_step(state) |> Map.put(:cnt, state.cnt + 1)}
  end

  defp do_slower(current_val) do
    sl = (@speeds |> Map.keys() |> length) - 1

    case @speeds |> Map.keys() |> Enum.find_index(fn x -> x == current_val end) do
      ^sl ->
        current_val

      otherwise ->
        @speeds |> Map.keys() |> Enum.fetch!(otherwise + 1)
    end
  end

  defp do_faster(current_val) do
    case @speeds |> Map.keys() |> Enum.find_index(fn x -> x == current_val end) do
      0 ->
        current_val

      otherwise ->
        @speeds |> Map.keys() |> Enum.fetch!(otherwise - 1)
    end
  end

  defp do_brighter(current_val) do
    sl = (@brightness |> Map.keys() |> length) - 1

    case @brightness |> Map.keys() |> Enum.find_index(fn x -> x == current_val end) do
      ^sl ->
        current_val

      otherwise ->
        @brightness |> Map.keys() |> Enum.fetch!(otherwise + 1)
    end
  end

  defp do_dimmer(current_val) do
    case @brightness |> Map.keys() |> Enum.find_index(fn x -> x == current_val end) do
      0 ->
        current_val

      otherwise ->
        @brightness |> Map.keys() |> Enum.fetch!(otherwise - 1)
    end
  end

  defp do_bright_step(tgt, curr) do
    IO.inspect({"Bs", tgt, curr})

    if curr < tgt do
      curr + 1
    else
      curr - 1
    end
  end

  defp bright_step(state) do
    case state.bright_tgt == state.bright_curr do
      true ->
        state

      false ->
        cond do
          state.speed < 100 ->
            case state.bright_delay do
              d when d in 1..(5 * state.bright_mvmul) ->
                state
                |> Map.put(:bright_delay, state.bright_delay + 1)

              _ ->
                state
                |> Map.put(:bright_curr, do_bright_step(state.bright_tgt, state.bright_curr))
                |> Map.put(:bright_delay, 0)
            end

          state.speed < 5000 ->
            case state.bright_delay do
              d when d in 1..(2 * state.bright_mvmul) ->
                state
                |> Map.put(:bright_delay, state.bright_delay + 1)

              _ ->
                state
                |> Map.put(:bright_curr, do_bright_step(state.bright_tgt, state.bright_curr))
                |> Map.put(:bright_delay, 0)
            end

          true ->
            state
            |> Map.put(:bright_curr, do_bright_step(state.bright_tgt, state.bright_curr))
        end
    end
  end

  @impl true
  def handle_cast(:faster, state) do
    {:noreply, state |> Map.put(:speed, do_faster(state.speed))}
  end

  @impl true
  def handle_cast(:slower, state) do
    {:noreply, state |> Map.put(:speed, do_slower(state.speed))}
  end

  @impl true
  def handle_cast(:brighter, state) do
    {:noreply, state |> Map.put(:bright_tgt, do_brighter(state.bright_tgt))}
  end

  @impl true
  def handle_cast(:dimmer, state) do
    {:noreply, state |> Map.put(:bright_tgt, do_dimmer(state.bright_tgt))}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end
