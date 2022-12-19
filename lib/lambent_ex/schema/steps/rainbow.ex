defmodule LambentEx.Schema.Steps.Rainbow do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :modulo, :integer
  end

  def changeset(source, params) do
    source
    |> cast(params, ~w(modulo)a)
    |> validate_required([:modulo])
  end
end
