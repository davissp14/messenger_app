defmodule SecureMessenger.Repo.Migrations.RenamePasswordFieldToCryptedPassword do
  use Ecto.Migration

  def change do
    rename table(:users), :password, to: :crypted_password
  end
end
