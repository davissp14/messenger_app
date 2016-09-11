defmodule SecureMessenger.Repo.Migrations.RenameUsernameToName do
  use Ecto.Migration

  def change do
    rename table(:users), :username, to: :name
  end
end
