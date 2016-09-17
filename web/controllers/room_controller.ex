defmodule SecureMessenger.RoomController do
  use SecureMessenger.Web, :controller
  alias SecureMessenger.Room
  alias SecureMessenger.Repo
  alias SecureMessenger.UsersRooms


  def index(conn, _params) do
    rooms = Repo.all(user_rooms(current_user(conn)))
    rooms_to_join = Repo.all(Room) |> Repo.preload([:owner, :users])
    render(conn, "index.html", rooms: rooms, rooms_to_join: rooms_to_join,
      layout: {SecureMessenger.LayoutView, "app.html"})
  end

  def new(conn, _params) do
    rooms = Repo.all(user_rooms(current_user(conn)))
    changeset = Room.changeset(%Room{})
    render(conn, "new.html", changeset: changeset, rooms: rooms,
    layout: {SecureMessenger.LayoutView, "app.html"})
  end

  def create(conn, %{"room" => room_params}) do
    changeset = Room.changeset(%Room{owner_id: current_user(conn).id}, room_params)

    case Repo.insert(changeset) do
      {:ok, _room} ->
        conn
        |> put_flash(:info, "Room created successfully.")
        |> redirect(to: room_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Problem creating a new room.")
        |> redirect(to: room_path(conn, :new), changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    active_users = Phoenix.Presence.list(SecureMessenger.Presence, "channels:" <> id)
    rooms = Repo.all(user_rooms(current_user(conn)))
    room = Repo.get!(user_rooms(current_user(conn)), id)
    |> Repo.preload([:users, :messages, messages: [:user]])
    render(conn, "show.html", room: room, rooms: rooms,
                              active_users: active_users,
                              layout: {SecureMessenger.LayoutView, "chat.html"})
  end

  def edit(conn, %{"id" => id}) do
    room = Repo.get!(Room, id)
    changeset = Room.changeset(room)
    render(conn, "edit.html", room: room, changeset: changeset)
  end

  def update(conn, %{"id" => id, "room" => room_params}) do
    room = Repo.get!(Room, id)
    changeset = Room.changeset(room, room_params)

    case Repo.update(changeset) do
      {:ok, room} ->
        conn
        |> put_flash(:info, "Room updated successfully.")
        |> redirect(to: room_path(conn, :show, room))
      {:error, changeset} ->
        render(conn, "edit.html", room: room, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    room = Repo.get!(Room, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(room)

    conn
    |> put_flash(:info, "Room deleted successfully.")
    |> redirect(to: room_path(conn, :index))
  end

  def join(conn, %{"id" => id}) do
    user_room = UsersRooms.changeset(%UsersRooms{user_id: current_user(conn).id, room_id: String.to_integer(id)}, %{})

    case  SecureMessenger.Repo.insert(user_room) do
        {:ok, user_room} ->
          conn
          |> put_flash(:info, "Joined Room!")
          |> redirect(to: room_path(conn, :show, id))
        {:error, user_room} ->
          conn
          |> redirect(to: room_path(conn, :show, id))
    end
  end

  def user_rooms(user) do
    assoc(user, :rooms)
  end

  def current_user(conn) do
    Guardian.Plug.current_resource(conn)
  end
end
