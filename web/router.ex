defmodule SecureMessenger.Router do
  use SecureMessenger.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SecureMessenger do
    pipe_through :browser # Use the default browser stack

    resources "/", RoomController
  end

  # Other scopes may use custom stacks.
  # scope "/api", SecureMessenger do
  #   pipe_through :api
  # end
end
