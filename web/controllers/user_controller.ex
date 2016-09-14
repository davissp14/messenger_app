defmodule SecureMessenger.UserController do
  use SecureMessenger.Web, :controller
  import Ecto.Changeset, only: [put_change: 3]
  alias SecureMessenger.User
  alias SecureMessenger.Room

  plug :put_layout, "login.html"

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    gravatar_url =
    changeset = User.changeset(%User{}, user_params)
    |> put_change(:crypted_password, Comeonin.Bcrypt.hashpwsalt(user_params["password"]))
    |> put_change(:gravatar_url, Gravatar.gravatar_url(user_params["email"], secure: true))

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> SecureMessenger.Auth.login(user)
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: room_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(User, id)
    changeset = User.changeset(user)
    cond do
      user == Guardian.Plug.current_resource(conn) ->
        conn
        |> render("show.html", user: user, changeset: changeset)
      :error ->
        conn
        |> put_flash(:info, "No access")
        |> redirect(to: session_path(conn, :new))
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    rooms = Repo.all(assoc(user, :rooms))
    changeset = User.update_changeset(user)
    render(conn, "edit.html", user: user, rooms: rooms, changeset: changeset, layout: {SecureMessenger.LayoutView, "app.html"})
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get(User, id)
    rooms = Repo.all(assoc(user, :rooms))
    changeset = User.update_changeset(user, user_params)
    cond do
      user == Guardian.Plug.current_resource(conn) ->
        case Repo.update(changeset) do
          {:ok, user} ->
            conn
            |> put_flash(:info, "User updated")
            |> render("edit.html", user: user, changeset: changeset, rooms: rooms,
                                   layout: {SecureMessenger.LayoutView, "app.html"})
            # |> redirect(to: user_path(conn, :edit, user))
          {:error, changeset} ->
            conn
            |> put_flash(:error, "Failed to update your profile. See errors below.")
            |> render("edit.html", user: user, changeset: changeset, rooms: rooms,
                                   layout: {SecureMessenger.LayoutView, "app.html"})
        end
      :error ->
        conn
        |> put_flash(:info, "No access")
        |> redirect(to: session_path(conn, :new))
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end

end
