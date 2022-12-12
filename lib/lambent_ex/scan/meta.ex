defmodule LambentEx.Meta do
  use GenServer

  @table :lex_metadata

  def init(arg) do
    {:ok, table} = :dets.open_file(@table, [type: :set])

    {:ok, %{table: table}}
  end

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def get_name(mac) do
    case :dets.lookup(@table, "name-#{mac}") do
      [] ->
        nil

      [{_key, value}] ->
        value
    end
  end

  def get_ord(mac) do
    case :dets.lookup(@table, "ord-#{mac}") do
      [] ->
        nil

      [{_key, value}] ->
        value
    end
  end

  def put_name(key, value) do
    :dets.insert(@table, {"name-#{key}", value})
  end

  def put_ord(key, value) do
    :dets.insert(@table, {"ord-#{key}", value})
  end
end