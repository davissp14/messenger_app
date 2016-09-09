defmodule SecureMessenger.Channel do
  use Phoenix.Channel

  def join("channels:" <> _private_room_id, _message, socket) do
    {:ok, socket}
  end
  #
  def join("channels:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast! socket, "new_msg", %{body: body, time: Timex.format!(Timex.now, "%l:%M%P", :strftime)}
    {:noreply, socket}
  end

  # def handle_out("new_msg", payload, socket) do
  #   push socket, "new_msg", payload
  #   {:noreply, socket}
  # end

end