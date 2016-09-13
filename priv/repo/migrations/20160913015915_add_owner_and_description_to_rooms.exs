defmodule SecureMessenger.Repo.Migrations.AddOwnerAndDescriptionToRooms do
  use Ecto.Migration

  def change do
    alter table(:rooms) do
      add :description, :string
      add :owner_id, references(:users)
    end
  end
end
