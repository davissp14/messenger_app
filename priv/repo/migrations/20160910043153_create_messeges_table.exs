defmodule SecureMessenger.Repo.Migrations.CreateMessegesTable do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :body, :text
      add :room_id, :string
      add :user_id, :string

      timestamps()
    end
  end
end
