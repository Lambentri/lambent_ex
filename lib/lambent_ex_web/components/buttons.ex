defmodule LambentEx.Components.Buttons do
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  # icon-text-button
  def itb(assigns) do
    assigns =
      assigns
      |> assign_new(:icon, fn -> "fa-poo-storm" end)
      |> assign_new(:what, fn -> "Poop" end)

    ~H"""
    <%= live_patch to: @to, class: "btn gap-2 float-right" do %>
      <i class={"fa-solid #{@icon}"}></i>

      <%= adj(@what) %> <%= @what %>
    <% end %>
    """
  end

  def ib(assigns) do
    assigns =
      assigns
      |> assign_new(:icon, fn -> "fa-poo-storm" end)
      |> assign_new(:function, fn -> :live_patch end)

    ~H"""
    <%= case @function do %>
      <% :live_patch -> %>
        <%= live_patch to: @to, class: "btn btn-square btn-xs" do %>
          <i class={"fa-solid #{@icon}"}></i>
        <% end %>
      <% :live_redirect -> %>
        <%= live_redirect to: @to, class: "btn btn-square btn-xs" do %>
          <i class={"fa-solid #{@icon}"}></i>
        <% end %>
    <% end %>
    """
  end

  defp adj(what) do
    case what do
      "Edit" -> ""
      "Back" -> "Go"
      _ -> "New"
    end
  end
end
