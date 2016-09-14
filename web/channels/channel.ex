defmodule SecureMessenger.Channel do
  use Phoenix.Channel
  use Guardian.Channel
  alias SecureMessenger.Repo
  alias SecureMessenger.Message
  import Logger

  def join("channels:" <> _private_room_id, %{ claims: claims, resource: resource }, socket) do
    {:ok, socket}
  end

  def join("users:join:" <> _private_room_id, %{ claims: claims, resource: resource }, socket) do
    {:ok, socket}
  end
  #
  def join("channels:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def join("users:join:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body, "room_id" => room_id}, socket) do
    user = current_resource(socket)
    changeset = Message.changeset(%Message{room_id: room_id, user_id: user.id, body: body}, %{})
    Repo.insert(changeset)
    current_time = Timex.format!(Timex.now, "%l:%M%P", :strftime)
    broadcast! socket, "new_msg", %{image: user.gravatar_url, name: user.name, body: body, time: current_time}
    {:noreply, socket}
  end

  def handle_in("new_member", %{"room_id" => room_id}, socket) do
    user = current_resource(socket)
    current_time = Timex.format!(Timex.now, "%l:%M%P", :strftime)
    broadcast! socket, "new_member", %{image: user.gravatar_url, name: user.name, body: "joined the room", time: current_time}
    {:noreply, socket}
  end

  def handle_guardian_auth_failure(reason), do: { :error, %{ error: reason } }

end
