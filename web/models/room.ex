defmodule SecureMessenger.Room do
  use SecureMessenger.Web, :model

  schema "rooms" do
    field :name, :string

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
