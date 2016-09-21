defmodule SecureMessenger.MessageController do
  use SecureMessenger.Web, :controller
  alias SecureMessenger.Repo
  alias SecureMessenger.Message
  import Ecto.Changeset, only: [put_change: 3]
  import Logger

  def create(conn, %{"type" => type, "message" => message_params}) do
    user = Guardian.Plug.current_resource(conn)
    Logger.debug(type)
    if Enum.member?(["normal", "generated"], type) do
        changeset = Message.changeset(%Message{user_id: user.id}, message_params)
        |> put_change(:generated, (message_params["generated"] == "true"))

        case Repo.insert(changeset) do
          {:ok, message} ->
            conn
            |> json %{
                message: Phoenix.View.render_to_string(SecureMessenger.MessageView, "message.html", conn: conn, message: message |> (Repo.preload([:user]))),
                room_id: message_params["room_id"],
                temp_id: nil
               }
          {:error, changeset} ->
            conn
        end
    else
        temp_id = :rand.uniform(9999)
        conn
        |> json %{
            message: Phoenix.View.render_to_string(SecureMessenger.MessageView, "secure_message.html", conn: conn, temp_id: temp_id, user: user, message: message_params["body"]),
            temp_id: temp_id,
            room_id: message_params["room_id"]
          }
    end
  end
end
