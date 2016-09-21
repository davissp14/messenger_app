defmodule SecureMessenger.Message do
  use SecureMessenger.Web, :model

  schema "messages" do
    field :body, :string
    field :generated, :boolean
    belongs_to :room, SecureMessenger.Room
    belongs_to :user, SecureMessenger.User

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
    |> cast(params, [:body, :user_id, :room_id])
    |> validate_required([:body, :user_id, :room_id])
  end
end
