defmodule LambentEx.Schema.Cronos do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:name, :string)

    field(:action, :string)
    field(:targets, {:array, :string})
  end

  def changeset(source, params) do
    source
    |> cast(params, ~w(name action targets)a)
    |> validate_required([:name, :action, :targets])
  end
end