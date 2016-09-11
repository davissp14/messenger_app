defmodule SecureMessenger.SessionController do
  use SecureMessenger.Web, :controller
  alias SecureMessenger.Room
  plug :put_layout, "login.html"

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => user,
                                    "password" => pass}}) do
    case SecureMessenger.Auth.login_by_email_and_pass(conn, user, pass,
                                           repo: Repo) do
      {:ok, conn} ->
        # Route to general channel by default.
        general_channel = Repo.get_by!(Room, name: "general")
        logged_in_user = Guardian.Plug.current_resource(conn)
        conn
        |> put_flash(:info, "Welcome!")
        |> redirect(to: room_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Wrong username/password")
        |> render("new.html")
     end
  end

  def delete(conn, _) do
    conn
    |> Guardian.Plug.sign_out
    |> redirect(to: "/")
  end

end
