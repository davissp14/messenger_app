defmodule SecureMessenger.Router do
  use SecureMessenger.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.EnsureAuthenticated, handler: SecureMessenger.Token
    plug Guardian.Plug.LoadResource
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SecureMessenger do
    pipe_through :browser
    resources "/users", UserController, only: [:new, :create, :edit, :update]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  scope "/", SecureMessenger do
    pipe_through [:browser, :browser_auth] # Use the default browser stack
    resources "/", RoomController
    get "/:id/join", RoomController, :join
    resources "/messages", MessageController
  end

  # Other scopes may use custom stacks.
  # scope "/api", SecureMessenger do
  #   pipe_through :api
  # end
end
