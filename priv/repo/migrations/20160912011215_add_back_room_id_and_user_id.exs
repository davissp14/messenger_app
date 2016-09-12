defmodule SecureMessenger.Repo.Migrations.AddBackRoomIdAndUserId do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :room_id, references(:rooms, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
