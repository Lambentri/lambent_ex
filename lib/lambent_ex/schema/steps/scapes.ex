defmodule LambentEx.Schema.Steps.Scape do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :h_h, :integer
    field :h_l, :integer
    field :s, :integer, default: 255
    field :v, :integer, default: 255
    field :linger, :integer, default: 1000
    field :dark, :boolean, default: true
  end

  def changeset(source, params) do
    source
    |> cast(params, ~w(h_h h_l s v linger dark)a)
    |> validate_required([:h_h, :h_l, :s, :v, :linger, :dark])
  end
end
