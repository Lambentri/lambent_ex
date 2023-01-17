defmodule LambentEx.LinksLive.BulkFormComponent do
  use LambentExWeb, :live_component

  alias LambentEx.Schema.LinksB
  alias LambentEx.Names



  @impl true
  def update(%{link: link} = assigns, socket) do
    changeset = LinksB.change_link(link)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
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

  def handle_event("new-name", _params, socket) do
    changeset = socket.assigns.changeset |> Ecto.Changeset.change(name: Names.name())
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def for_selectm(array) do
    array |> Enum.map(fn {k, v} -> {v[:id], v[:name]} end)
  end

  defp ipp(ip), do: ip |> Tuple.to_list |> Enum.join(".")


  def for_selectd(array) do
    array
    |> Enum.map(fn {iface, entries} ->
      entries
      |> Enum.map(fn {k, v} ->
        if v["name"] == nil do
                            {v["ip"] |> ipp, k}
        else
          {v["name"], k}
        end

      end)
    end)
          |> List.flatten()
          |> Enum.sort_by(fn {k, v} -> k end)
#    |> IO.inspect
  end

#  def for_selectd(array) do
#    array
#    |> Enum.map(fn {iface, entries} ->
#      entries
#      |> Enum.map(fn {k, v} ->
#        if v["name"] == nil do
#            %{label: v["ip"] |> ipp, id: k, selected: false}
#          else
#            %{label: v["name"], id: k, selected: false}
#        end
#
#      end)
#    end)
##    |> List.flatten()
##    |> Enum.sort_by(fn {k, v} -> k end)
#    |> IO.inspect
#  end

  #     <.live_component
  #    id="target_ids"
  #    module={LambentExWeb.MultiSelectComponent}
  #    options={for_selectd(@devices)}
  #    form={f}
  #    selected={fn opts -> send(self(), {:updated_bulk_options, opts}) end}
  #    />
end
