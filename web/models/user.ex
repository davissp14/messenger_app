defmodule SecureMessenger.User do
  use SecureMessenger.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :crypted_password, :string
    field :gravatar_url, :string

    many_to_many :rooms, SecureMessenger.Room, join_through: "users_rooms"
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :password], [:crypted_password])
    |> unique_constraint(:email)
    |> validate_required([:email, :password, :name])
    |> validate_length(:password, min: 5)
  end
end
