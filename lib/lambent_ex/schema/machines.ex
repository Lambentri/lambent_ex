defmodule LambentEx.Schema.Machines do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

    alias LambentEx.Schema.Machines

  embedded_schema do
    field :name, :string
  end

  def changeset(source, params) do
    source
    |> cast(params, ~w(name)a)
    |> validate_required([:name])
  end

  def change_machine(%Machines{} = machine, attrs \\ %{}) do
    Machines.changeset(machine, attrs)
  end
end
