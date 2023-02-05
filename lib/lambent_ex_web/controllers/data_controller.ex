defmodule LambentExWeb.DataController do
  use LambentExWeb, :controller

  alias LambentEx.API
  @pubsub_name LambentEx.PubSub
  @pubsub_topic "http_pubs"

  action_fallback LambentExWeb.FallbackController

  require Logger

  def index(conn, data) do
    {path, data} = data |> Map.pop("path")

    LambentEx.Meta.get_http()
    |> Enum.map(fn {name, hpath} ->
      case {name, hpath} do
        {name, ^path} -> Phoenix.PubSub.broadcast(@pubsub_name, @pubsub_topic, {name, path, data})
        {name, _path} -> :ok
      end
    end)

    text(conn, :ok)
  end

  def create(conn, data) do
    {path, data} = data |> Map.pop("path")

    LambentEx.Meta.get_http()
    |> Enum.map(fn {name, hpath} ->
      case {name, hpath} do
        {name, ^path} -> Phoenix.PubSub.broadcast(@pubsub_name, @pubsub_topic, {name, path, data})
        {name, _path} -> :ok
      end
    end)

    text(conn, :ok)
  end
end
