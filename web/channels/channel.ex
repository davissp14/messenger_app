defmodule SecureMessenger.Channel do
  use Phoenix.Channel
  use Guardian.Channel
  alias SecureMessenger.Repo
  alias SecureMessenger.Message
  alias SecureMessenger.Presence
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

  def handle_in("new_msg", %{"body" => body, "room_id" => room_id, "incognito" => incognito}, socket) do
    user = current_resource(socket)
    temp_id = :rand.uniform(99999)

    timezone = Timex.Timezone.get(user.timezone, Timex.now)
    current_time = Timex.Timezone.convert(Timex.now, timezone)
    current_time = Timex.format!(current_time, "%l:%M%P", :strftime)
    if incognito do
      broadcast! socket, "new_msg", %{temp_id: temp_id, incognito: incognito, image: user.gravatar_url, name: user.name, body: body, time: current_time}
      SecureMessenger.Delayed.schedule_removal(room_id, temp_id)
    else
      changeset = Message.changeset(%Message{room_id: room_id, user_id: user.id, body: body}, %{})
      Repo.insert(changeset)
      broadcast! socket, "new_msg", %{temp_id: nil, incognito: incognito, image: user.gravatar_url, name: user.name, body: body, time: current_time}
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
