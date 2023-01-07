defmodule LambentEx.Schema.Machines do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import PolymorphicEmbed, only: [cast_polymorphic_embed: 3]

  alias LambentEx.Schema.Machines

  @values %{
    gen_solid: "Solid", #
    gen_solid_h: "Solid (HSV)", #
    gen_color_cycle: "Color Cycler", #
    gen_chaser: "Chaser", #
    gen_chaser_h: "Chaser (HSV)", #
    gen_chaser_m: "Multi-Chaser",
    gen_chaser_mh: "Multi-Chaser (HSV)",
    gen_growth: "Growth",
    gen_rocker: "Rocker", #
    gen_rocker_s: "Rocker (Solid)", #
    gen_rainbow: "Rainbow", #
    gen_rainbow_s: "Rainbow (Solid)", #
    gen_scape: "Scape", #
    gen_scape_s: "Scape (Solid)", #
    gen_twinkler: "LA3PortTwinler",
    rcv_fft: "FFT Receiver",
    rcv_gsi: "GSI Receiver",
    rcv_hyp: "Hyperion Receiver"
  }

  @steps %{
    #    gen_solid: "Solid",
    gen_solid_h: LambentEx.Machine.Steps.Solid,
    #    gen_color_cycle: "Color Cycler",
    #    gen_chaser: "Chaser",
    gen_chaser_h: LambentEx.Machine.Steps.Chase,
    gen_rainbow: LambentEx.Machine.Steps.Rainbow,
    gen_rainbow_s: LambentEx.Machine.Steps.Rainbow,
    gen_rocker: LambentEx.Machine.Steps.Rocker,
    gen_rocker_s: LambentEx.Machine.Steps.Rocker,
    gen_scape: LambentEx.Machine.Steps.Scape,
    gen_scape_s: LambentEx.Machine.Steps.Scape,
  }

  embedded_schema do
    field(:name, :string)

    field(:type, Ecto.Enum, values: @values |> Map.keys())

    field(:class, PolymorphicEmbed,
      types: [
        #        gen_solid: LambentEx.Schema.Steps.Solid,
        gen_solid_h: LambentEx.Schema.Steps.Solid,
        gen_chaser: LambentEx.Schema.Steps.Chaser,
        gen_chaser_h: LambentEx.Schema.Steps.Chaser,
        gen_rocker: LambentEx.Schema.Steps.Rocker,
        gen_rocker_s: LambentEx.Schema.Steps.Rocker,
        gen_scape: LambentEx.Schema.Steps.Scape,
        gen_scape_s: LambentEx.Schema.Steps.Scape,
        gen_rainbow: LambentEx.Schema.Steps.Rainbow,
        gen_rainbow_s: LambentEx.Schema.Steps.Rainbow
      ],
      on_type_not_found: :raise,
      on_replace: :update
    )
  end

  def values do
    @values
  end

  def changeset(source, params) do
    source
    |> cast(params, ~w(name type)a)
    |> cast_polymorphic_embed(:class, required: true)
    |> validate_required([:name, :type])
  end

  def change_machine(%Machines{} = machine, attrs \\ %{}) do
    Machines.changeset(machine, attrs)
  end

  def update_machines(%Machines{} = machines, attrs) do
    res = machines |> Machines.changeset(attrs)
    IO.inspect(res)

    opts =
      case res.changes[:type] do
        :gen_solid -> [single: true]
        :gen_solid_h -> [single: true]
        :gen_rainbow_s -> [single: true]
        :gen_rocker_s -> [single: true]
        :gen_scape_s -> [single: true]
        _otherwise -> []
      end |> IO.inspect()

    case res.valid? do
      true ->
        {:ok,
         LambentEx.MachineSupervisor.start_child(
           Map.get(@steps, res.changes[:type]),
           res.changes[:class] |> Map.from_struct(),
           res.changes[:name],
           opts
         )}

      false ->
        {:error, res}
    end
  end
end
