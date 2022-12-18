defmodule LambentEx.LinksLive.FormComponent do
  use LambentExWeb, :live_component

  alias LambentEx.Schema.Links
  alias LambentEx.Names

  @impl true
  def update(%{link: link} = assigns, socket) do
    changeset = Links.change_link(link)

    {:ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"links" => links_params}, socket) do
    changeset =
      socket.assigns.link
      |> Links.change_link(links_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"links" => links_params}, socket) do
    case Links.update_links(socket.assigns.link, links_params) do
      {:ok, _link} ->
        {:noreply,
          socket
          |> put_flash(:info, "Link Created Successfully")
          |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
#    save_testyyyy(socket, socket.assigns.action, testyyyy_params)
#    :ok
  end

  def handle_event("new-name", _params, socket) do
    changeset = socket.assigns.changeset |> Ecto.Changeset.change(name: Names.name())
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def for_selectm(array) do
    array |> Enum.map(fn {k,v} -> {v[:id], v[:name]} end)
  end

  def for_selectd(array) do
    array |> Enum.map(fn {iface,entries} -> entries |> Enum.map(fn {k, v} -> {v["name"], k} end) end) |> List.flatten |> Enum.sort_by(fn {k, v} -> k end)
  end
end
