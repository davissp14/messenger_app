defmodule SecureMessenger.ViewHelper do
  def current_user(conn), do: Guardian.Plug.current_resource(conn)
  def logged_in?(conn), do: Guardian.Plug.authenticated?(conn)
  def gravatar_img(conn, size), do: current_user(conn).gravatar_url <> "?s=#{size}"

end
