defmodule LambentEx.ServicesLive.HTTPFormComponent do
  use LambentExWeb, :live_component

  alias LambentEx.Schema.LinksB
  alias LambentEx.Names

  @impl true
  def update(assigns, socket) do
#    changeset = LinksB.change_link(link)

    {:ok,
      socket
      |> assign(assigns)
#      |> assign(:changeset, changeset)
    }
  end

  @impl true
  def handle_event("validate", %{"links_b" => links_params}, socket) do
    changeset =
      socket.assigns.link
      |> LinksB.change_link(links_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"links_b" => links_params}, socket) do
    case LinksB.update_links(socket.assigns.link, links_params, socket.assigns.devices) do
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
end