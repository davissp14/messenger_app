defmodule SecureMessenger.Channel do
  use Phoenix.Channel
  use Guardian.Channel
  alias SecureMessenger.Repo
  alias SecureMessenger.Message
  alias SecureMessenger.Presence
  alias SecureMessenger.User
  import Logger

  def join("channels:" <> _private_room_id, %{ claims: claims, resource: resource }, socket) do
    send(self, :after_join)
    {:ok, assign(socket, :user_id, current_resource(socket).id)}
  end

  def join("channels:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def terminate(topic, socket) do
    if socket.assigns[:user_id] do
      broadcast! socket, "member_leave", %{user_id: socket.assigns.user_id}
    end
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    push socket, "presence_state", Presence.list(socket)
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:seconds))
    })
    broadcast! socket, "member_joined", %{user_id: socket.assigns.user_id}
    {:noreply, socket}
  end

  def handle_in("new_msg", %{"html" => html, "icognito" => incognito, "room_id" => room_id}, socket) do
    user = current_resource(socket)
    temp_id = :rand.uniform(99999)

    if incognito do
      broadcast! socket, "new_msg", %{message: html, temp_id: temp_id}
      SecureMessenger.Delayed.schedule_removal(room_id, temp_id)
    else
      broadcast! socket, "new_msg", %{message: html}
    end

    {:noreply, socket}
  end

  def handle_in("destory_message", %{"message_id" => message_id}, socket) do
    user = current_resource(socket)
    current_time = Timex.format!(Timex.now, "%l:%M%P", :strftime)
    broadcast! socket, "destroy_message", %{image: user.gravatar_url, name: user.name, body: "joined the room", time: current_time}
    {:noreply, socket}
  end

  def handle_guardian_auth_failure(reason), do: { :error, %{ error: reason } }

end
