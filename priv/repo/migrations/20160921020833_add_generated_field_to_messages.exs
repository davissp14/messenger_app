defmodule SecureMessenger.Repo.Migrations.AddGeneratedFieldToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :generated, :boolean, default: false
    end
  end
end
