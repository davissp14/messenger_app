defmodule SecureMessenger.Channel do
  use Phoenix.Channel
  import Guardian.Phoenix.Socket

  def join("channels:" <> _private_room_id, _message, socket) do
    {:ok, socket}
  end
  #
  def join("channels:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    current_time = Timex.format!(Timex.now, "%l:%M%P", :strftime)
    # username = current_resource(socket).username
    broadcast! socket, "new_msg", %{username: "anonymous", body: body, time: current_time}
    {:noreply, socket}
  end

  # def handle_out("new_msg", payload, socket) do
  #   push socket, "new_msg", payload
  #   {:noreply, socket}
  # end

end
