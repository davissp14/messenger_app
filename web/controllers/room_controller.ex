defmodule SecureMessenger.RoomController do
  use SecureMessenger.Web, :controller
  alias SecureMessenger.Room
  alias SecureMessenger.User
  alias SecureMessenger.Repo
  alias SecureMessenger.UsersRooms

  def index(conn, _params) do
    rooms_to_join = Repo.all(Room) |> Repo.preload([:owner, :users])
    user = Guardian.Plug.current_resource(conn) |> Repo.preload([:rooms, rooms: [:owner, :users]])
    render(conn, "index.html", rooms: user.rooms, rooms_to_join: rooms_to_join)
  end

  def new(conn, _params) do
    user = Guardian.Plug.current_resource(conn) |> Repo.preload([:rooms])
    changeset = Room.changeset(%Room{})
    render(conn, "new.html", changeset: changeset, rooms: user.rooms)
  end

  def create(conn, %{"room" => room_params}) do
    changeset = Room.changeset(%Room{owner_id: Guardian.Plug.current_resource(conn).id}, room_params)

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
    user = Guardian.Plug.current_resource(conn) |> Repo.preload([:rooms])
    room = Repo.get!(Room, id) |> Repo.preload([:users, :messages, messages: [:user]])
    render(conn, "show.html", room: room, rooms: user.rooms)
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
    user = Guardian.Plug.current_resource(conn)
    user_room = UsersRooms.changeset(%UsersRooms{user_id: user.id, room_id: String.to_integer(id)}, %{})
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
end
