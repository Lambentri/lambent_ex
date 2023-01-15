defmodule LambentEx.Schema.Steps.Firefly do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field(:h, {:array, :integer}, default: [])
    field(:h_sel, :integer)
    field(:mult, :integer, default: 1000)
    field(:s, :integer, default: 255)
    field(:v, :integer, default: 255)
  end

  def changeset(source, params) do
    source
    |> cast(params, ~w(h h_sel mult s v)a)
    |> validate_required([:h, :h_sel, :mult, :s, :v])
  end
end
