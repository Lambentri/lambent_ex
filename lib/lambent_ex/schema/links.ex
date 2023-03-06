defmodule LambentEx.Schema.Links do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias LambentEx.Schema.Links

  embedded_schema do
    field(:name, :string)
    field(:source_id, :string)
    field(:source_type, Ecto.Enum, values: [:machine, :anchor], default: :machine)
    field(:target_id, :string)
    field(:target_type, Ecto.Enum, values: [:device, :group], default: :device)
  end

  def change_link(%Links{} = link, attrs \\ %{}) do
    Links.changeset(link, attrs)
  end

  def update_links(%Links{} = link, attrs) do
    res =
      link
      |> Links.changeset(attrs)

    case res.valid? do
      true ->
        {:ok,
         LambentEx.LinkSupervisor.start_child(
           res.changes[:name],
           res.changes[:source_id],
           res.changes[:target_id]
         )}

      false ->
        {:error, res}
    end
  end

  def changeset(source, params) do
    source
    |> cast(params, ~w(name source_id source_type target_id target_type)a)
    |> validate_required([:name, :source_id, :source_type, :target_id, :target_type])
  end
end

defmodule LambentEx.Schema.LinksB do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias LambentEx.Schema.LinksB

  embedded_schema do
    field(:name, :string)
    field(:source_id, :string)
    field(:source_type, Ecto.Enum, values: [:machine, :anchor], default: :machine)
    field(:target_ids, {:array, :string})
    field(:target_type, Ecto.Enum, values: [:device, :group], default: :device)
  end

  def change_link(%LinksB{} = link, attrs \\ %{}) do
    LinksB.changeset(link, attrs)
  end

  def get_name(mac, devices) do
    flatd =
      devices
      |> Enum.map(fn {iface, entries} ->
        entries
      end)
      |> List.flatten()
      |> List.first()

    case flatd |> Map.get(mac) do
      nil -> mac
      value -> value["name"] || mac
    end
  end

  def update_links(%LinksB{} = link, attrs, devices) do
    res =
      link
      |> LinksB.changeset(attrs)

    case res.valid? do
      true ->
        for id <- res.changes[:target_ids] do
          LambentEx.LinkSupervisor.start_child(
            "#{res.changes[:name]}|#{id |> get_name(devices)}",
            res.changes[:source_id],
            id
          )
        end

        {:ok, :ok}

      false ->
        IO.inspect(res)
        {:error, res}
    end
  end

  def changeset(source, params) do
    source
    |> cast(params, ~w(name source_id source_type target_ids target_type)a)
    |> validate_required([:name, :source_id, :source_type, :target_ids, :target_type])
  end
end
