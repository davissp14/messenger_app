defmodule SecureMessenger.UserController do
  use SecureMessenger.Web, :controller
  alias SecureMessenger.User

  plug :put_layout, "main.html"

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

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
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  # def update(conn, %{"id" => id, "user" => user_params}) do
  #   user = Repo.get(User, id)
  #   changeset = User.registration_changeset(user, user_params)
  #   cond do
  #     user == Guardian.Plug.current_resource(conn) ->
  #       case Repo.update(changeset) do
  #         {:ok, user} ->
  #           conn
  #           |> put_flash(:info, "User updated")
  #           |> redirect(to: session_path(conn, :new))
  #         {:error, changeset} ->
  #           conn
  #           |> render("show.html", user: user, changeset: changeset)
  #       end
  #     :error ->
  #       conn
  #       |> put_flash(:info, "No access")
  #       |> redirect(to: session_path(conn, :new))
  #   end
  # end

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