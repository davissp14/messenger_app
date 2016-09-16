defmodule SecureMessenger.RoomView do
  use SecureMessenger.Web, :view

  def convert_time(conn, created_at) do
    timezone = Timex.Timezone.get(current_user(conn).timezone, created_at)
    current_time = Timex.Timezone.convert(created_at, timezone)
    Timex.format!(current_time, "%l:%M%P", :strftime)
  end

end
