defmodule SecureMessenger.Repo.Migrations.CreateUserRoomsJoinTable do
  use Ecto.Migration

  def change do
    create table(:users_rooms) do
      add :user_id, references(:users)
      add :room_id, references(:rooms)

      timestamps()
    end
  end
end
