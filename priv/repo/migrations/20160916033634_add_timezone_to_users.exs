defmodule SecureMessenger.Repo.Migrations.AddTimezoneToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :timezone, :string, default: "America/Chicago"
    end
  end
end
