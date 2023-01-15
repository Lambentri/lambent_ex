defmodule LambentEx.Schema.Steps.Solid do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field(:h, :integer)
    field(:s, :integer, default: 255)
    field(:v, :integer, default: 255)
  end

  def changeset(source, params) do
    source
    |> cast(params, ~w(h s v)a)
    |> validate_required([:h, :s, :v])
  end
end
