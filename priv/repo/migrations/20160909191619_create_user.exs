defmodule SecureMessenger.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :email, :string
      add :password, :string
      add :gravatar_url, :string

      timestamps()
    end

  end
end
