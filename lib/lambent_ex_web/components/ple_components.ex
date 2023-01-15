defmodule LambentEx.Phoenix.LiveEditable.Interface.Tailwind3 do
  require Phoenix.LiveEditable.Svg
  alias Phoenix.LiveEditable.Svg

  import Phoenix.HTML

  use Phoenix.Component
  use Phoenix.HTML

  def render(%{ple_type: "text", ple_mode: "anchor", ple_data: nil} = assigns) do
    ~H"""
    <span
      style="cursor: pointer; border-bottom: 1px dashed blue;"
      phx-click="ple-focus"
      phx-target={@myself}
    >
      <span style="color: red; font-style: italic;">Empty</span>
    </span>
    """
  end

  def render(%{ple_type: "text", ple_mode: "anchor"} = assigns) do
    ~H"""
    <span
      style="cursor: pointer; border-bottom: 1px dashed blue;"
      phx-click="ple-focus"
      phx-target={@myself}
    >
      <%= @ple_data %>
    </span>
    """
  end

  def render(%{ple_type: "text", ple_mode: "focus"} = assigns) do
    ~H"""
    <div class="inline-block">
      <form
        style="display: inline;"
        phx-submit={@ple_action}
        phx-target={@myself}
        phx-click-away="ple-blur"
      >
        <input style="width: 100px;" type="text" name="data" target={@myself} value={@ple_data} />
        <button class="button" style="margin-left: 5px" type="submit">
          <%= raw(Svg.inline("CircleOk")) %>
        </button>
      </form>
      <button class="button" style="margin-left: 5px">
        <%= raw(Svg.inline("CircleCancel")) %>
      </button>
    </div>
    """
  end

  def render(%{ple_type: "select", ple_mode: "anchor", ple_data: nil} = assigns) do
    ~H"""
    <span
      style="cursor: pointer; border-bottom: 1px dashed blue;"
      phx-click="ple-focus"
      phx-target={@myself}
    >
      <span style="color: red; font-style: italic;">rgb</span>
    </span>
    """
  end

  def render(%{ple_type: "select", ple_mode: "anchor"} = assigns) do
    ~H"""
    <span
      style="cursor: pointer; border-bottom: 1px dashed blue;"
      phx-click="ple-focus"
      phx-target={@myself}
    >
      <%= @ple_data %>
    </span>
    """
  end

  def render(%{ple_type: "select", ple_mode: "focus", ple_data: nil} = assigns) do
    ~H"""
    <div>
      <form
        style="display: inline;"
        phx-submit={@ple_action}
        phx-blur={@ple_action}
        phx-target={@myself}
        phx-click-away={@ple_action}
        phx-value-target="myfield"
      >
        <%= select(:ok, :ord, @ple_options, phx_change: "reorder", phx_target: @myself) %>
      </form>
    </div>
    """
  end

  def render(%{ple_type: "select", ple_mode: "focus"} = assigns) do
    ~H"""
    <div>
      <form
        style="display: inline;"
        phx-submit={@ple_action}
        phx-blur={@ple_action}
        phx-target={@myself}
        phx-click-away={@ple_action}
      >
        <%= select(:ok, :ord, @ple_options,
          phx_change: "reorder",
          phx_target: @myself,
          selected: @ple_data
        ) %>
      </form>
    </div>
    """
  end

  def render(assigns) do
    IO.inspect(assigns)

    ~H"""
    <div></div>
    """
  end
end
