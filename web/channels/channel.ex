defmodule SecureMessenger.Channel do
  use Phoenix.Channel
  use Guardian.Channel
  alias SecureMessenger.Repo
  alias SecureMessenger.Presence
  alias SecureMessenger.User
  alias SecureMessenger.Message

  import Logger

  def join("channels:" <> private_room_id, %{ claims: claims, resource: resource }, socket) do
    socket = assign(socket, :room_id, String.to_integer(private_room_id))
    socket = assign(socket, :user_id, current_resource(socket).id)

    send(self, :after_join)
    {:ok, socket}
  end

  def join("channels:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def terminate(topic, socket) do
    # if socket.assigns[:user_id] do
    #   changeset = Message.changeset(%Message{
    #     user_id: socket.assigns.user_id,
    #     body: "left the room",
    #     room_id: socket.assigns.room_id,
    #     generated: true
    #    }, %{})
    #
    #    case Repo.insert(changeset) do
    #      {:ok, message} ->
    #        html = Phoenix.View.render_to_string(SecureMessenger.MessageView, "message.html", conn: socket, message: message |> Repo.preload([:user] ))
    #        broadcast! socket, "new_msg", %{message: html}
    #        broadcast! socket, "member_leave", %{user_id: socket.assigns.user_id,}
    #      {:error, changeset} ->
    #    end
    # end
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    user = current_resource(socket)
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      name: user.name,
      id: socket.assigns.user_id,
      gravatar_url: user.gravatar_url,
      online_at: inspect(System.system_time(:seconds))
    })
    push socket, "presence_state", Presence.list(socket)


    # changeset = Message.changeset(%Message{
    #   user_id: socket.assigns.user_id,
    #   body: "joined the room",
    #   room_id: socket.assigns.room_id,
    #   generated: true
    #  }, %{})
    #
    #  case Repo.insert(changeset) do
    #    {:ok, message} ->
    #      html = Phoenix.View.render_to_string(SecureMessenger.MessageView, "message.html", conn: socket, message: message |> Repo.preload([:user] ))
    #      broadcast! socket, "new_msg", %{message: html}
    #      broadcast! socket, "member_joined", %{user_id: socket.assigns.user_id}
    #  {:error, changeset} ->
    #  end
     {:noreply, socket}
  end

  def handle_in("new_msg", %{"message" => message, "room_id" => room_id, "temp_id" => temp_id}, socket) do
    user = current_resource(socket)
    SecureMessenger.Delayed.schedule_removal(room_id, temp_id)
    broadcast! socket, "new_msg", %{message: message}

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
