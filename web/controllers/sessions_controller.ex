defmodule SecureMessenger.SessionController do
  use SecureMessenger.Web, :controller
  plug :put_layout, "main.html"

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => user,
                                    "password" => pass}}) do
    case SecureMessenger.Auth.login_by_email_and_pass(conn, user, pass,
                                           repo: Repo) do
      {:ok, conn} ->
        logged_in_user = Guardian.Plug.current_resource(conn)
        conn
        |> put_flash(:info, "Innlogget")
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
