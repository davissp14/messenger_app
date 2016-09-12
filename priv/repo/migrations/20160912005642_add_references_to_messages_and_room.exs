defmodule SecureMessenger.Repo.Migrations.RemoveReferencesToMessagesAndRoom do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      remove :user_id
      remove :room_id
    end
  end
end
