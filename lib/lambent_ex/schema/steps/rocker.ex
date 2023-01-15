defmodule LambentEx.Schema.Steps.Rocker do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field(:h, {:array, :integer}, default: [])
    field(:h_sel, :integer)
    field(:s, :integer, default: 255)
    field(:v, :integer, default: 255)
    field(:linger, :integer, default: 1000)
    field(:dark, :boolean, default: true)
  end

  def changeset(source, params) do
    source
    |> cast(params, ~w(h h_sel s v linger dark)a)
    |> validate_required([:h, :h_sel, :s, :v, :linger, :dark])
  end
end
