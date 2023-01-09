defmodule LambentEx.Schema.Steps.Growth do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :h_g, {:array, :integer}, default: []
    field :h_d, {:array, :integer}, default: []
    field :h_sel, :integer
    field :min_g, :integer, default: 10
    field :max_g, :integer, default: 50
    field :min_d, :integer, default: 5
    field :max_d, :integer, default: 25
    field :lb_min, :integer, default: 30
    field :lb_max, :integer, default: 130
  end

  def changeset(source, params) do
    source
    |> cast(params, ~w(h_g, h_d, h_sel, min_g, max_g, min_d, max_d, lb_min, lb_max)a)
    |> validate_required([:h_g, :h_d, :h_sel, :min_g, :max_G, :min_d, :max_d, :lb_min, :lb_max])
  end
end
