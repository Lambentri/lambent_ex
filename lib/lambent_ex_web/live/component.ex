defmodule LambentEx.LiveEdit do

  use Phoenix.LiveEditableComponent

  # ----- event handlers -----

  def handle_event("rename", data, socket) do
    # send message to view
    socket
    |> Map.get(:assigns)
    |> Map.get(:ple_viewpid)
    |> send({:rename, data |> Map.put("id", socket.assigns.id)})

    {:noreply, assign(socket, :ple_mode, "anchor")}
  end

  def handle_event("reorder", data, socket) do
    # send message to view
    socket
    |> Map.get(:assigns)
    |> Map.get(:ple_viewpid)
    |> send({:reorder, data |> Map.put("id", socket.assigns.id)})

    {:noreply, assign(socket, :ple_mode, "anchor")}
  end
end