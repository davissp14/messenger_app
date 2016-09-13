defmodule SecureMessenger.Repo.Migrations.AddRoomIdUserIdUniqueIndex do
  use Ecto.Migration

  def change do
    create unique_index(:users_rooms, [:room_id, :user_id], name: "multiple_join_prevention")
  end
end
