defmodule LambentExWeb.Router do
  use LambentExWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LambentExWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LambentExWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/cfg/devices", DevicesLive.Index, :index
    live "/cfg/devices/:id", DevicesLive.Show, :show
    live "/cfg/devices/:id/show/edit", DevicesLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", LambentExWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:lambent_ex, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LambentExWeb.Telemetry
    end
  end
end
