defmodule LambentEx.Schema.Links do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias LambentEx.Schema.Links


  embedded_schema do
    field :name, :string
    field :source_id, :string
    field :source_type, Ecto.Enum, values: [:machine, :anchor]
    field :target_id, :string
    field :target_type, Ecto.Enum, values: [:device, :group]
  end

  def change_link(%Links{} = link, attrs \\ %{}) do
    Links.changeset(link, attrs)
  end

  def update_links(%Links{} = link, attrs) do
    IO.puts("actual write")

    link
    |> Links.changeset(attrs)
    |> IO.inspect
  end
  
  def changeset(source, params) do
    source
    |> cast(params, ~w(name source_id source_type target_id target_type)a)
    |> validate_required([:name, :source_id, :source_type, :target_id, :target_type])
  end
end
