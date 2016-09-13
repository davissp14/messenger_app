defmodule SecureMessenger.Room do
  use SecureMessenger.Web, :model

  schema "rooms" do
    field :name, :string
    field :description, :string

    belongs_to :owner, SecureMessenger.User
    has_many :messages, SecureMessenger.Message
    many_to_many :users, SecureMessenger.User, join_through: "users_rooms"

    timestamps()
  end

  # defimpl Phoenix.Param do
  #   def to_param(%{name: name}) do
  #     name |> String.downcase |> String.replace(" ", "-")
  #   end
  # end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
