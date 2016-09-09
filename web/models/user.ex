defmodule SecureMessenger.User do
  use SecureMessenger.Web, :model

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string
    field :gravatar_url, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :email, :password])
    |> validate_required([:email, :password, :username])
  end
end
