defmodule ExSlackExampleWeb.Router do
  use ExSlackExampleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    #plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExSlackExampleWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/thanks", PageController, :thanks
    post "/slack", PageController, :slack
    post "/event", PageController, :event
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExSlackExampleWeb do
  #   pipe_through :api
  # end
end
