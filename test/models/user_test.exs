defmodule SecureMessenger.UserTest do
  use SecureMessenger.ModelCase

  alias SecureMessenger.User

  @valid_attrs %{email: "some content", encrypted_password: "some content", gravatar_url: "some content", username: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
