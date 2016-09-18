defmodule SecureMessenger.ViewHelper do
  def current_user(conn), do: Guardian.Plug.current_resource(conn)
  def logged_in?(conn), do: Guardian.Plug.authenticated?(conn)
  def gravatar_img(conn, size), do: current_user(conn).gravatar_url <> "?s=#{size}"


  def convert_time(conn, created_at) do
    timezone = Timex.Timezone.get(current_user(conn).timezone, created_at)
    current_time = Timex.Timezone.convert(created_at, timezone)
    Timex.format!(current_time, "%l:%M%P", :strftime)
  end

end
