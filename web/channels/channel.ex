defmodule SecureMessenger.Channel do
  use Phoenix.Channel
  use Guardian.Channel

  def join("channels:" <> _private_room_id, %{ claims: claims, resource: resource }, socket) do
    {:ok, socket}
  end
  #
  def join("channels:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    current_time = Timex.format!(Timex.now, "%l:%M%P", :strftime)
    user = current_resource(socket)
    image = Gravatar.gravatar_url(user.email, secure: false, s: 40)
    broadcast! socket, "new_msg", %{image: image, username: user.username, body: body, time: current_time}
    {:noreply, socket}
  end

  def handle_guardian_auth_failure(reason), do: { :error, %{ error: reason } }

  # def handle_out("new_msg", payload, socket) do
  #   push socket, "new_msg", payload
  #   {:noreply, socket}
  # end

end
