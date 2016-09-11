defmodule SecureMessenger.User do
  use SecureMessenger.Web, :model

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string, virtual: true
    field :crypted_password, :string
    field :gravatar_url, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :email, :password], [:crypted_password])
    |> unique_constraint(:email)
    |> validate_required([:email, :password, :username])
    |> validate_length(:password, min: 5)
  end
end
