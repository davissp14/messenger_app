defmodule SecureMessenger.Auth do
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  import Plug.Conn
  import Logger

  def login(conn, user) do
    conn
    |> Guardian.Plug.sign_in(user, :access)
  end

  def login_by_email_and_pass(conn, email, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(SecureMessenger.User, email: email)

    cond do
      user && checkpw(given_pass, user.crypted_password) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        {:error, :not_found, conn}
    end
  end
end
