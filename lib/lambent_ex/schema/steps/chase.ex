defmodule LambentEx.Schema.Steps.Chaser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field(:h, :integer)
    field(:s, :integer, default: 255)
    field(:v, :integer, default: 255)
    field(:spacing, :integer, default: 30)
    field(:fadeby, :integer, default: 15)
  end

  def changeset(source, params) do
    source
    |> cast(params, ~w(h s v spacing fadeby)a)
    |> validate_required([:h, :s, :v, :spacing, :fadeby])
  end
end
