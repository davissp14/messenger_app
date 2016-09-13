defmodule SecureMessenger.UsersRooms do
  use SecureMessenger.Web, :model

  schema "users_rooms" do
    belongs_to :user, SecureMessenger.User
    belongs_to :room, SecureMessenger.Room

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:room_id, :user_id])
    |> unique_constraint(:unique, name: "multiple_join_prevention")
  end
end
