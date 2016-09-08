defmodule SecureMessenger.Repo.Migrations.CreateRoom do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :name, :string

      timestamps()
    end

  end
end
