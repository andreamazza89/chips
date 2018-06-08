defmodule Chips.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chips.User

  schema "users" do
    field(:email, :string)
    field(:user_name, :string)
    field(:password, :string)
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :user_name, :password])
    |> validate_required([:email, :user_name, :password])
    |> unique_constraint(:email)
    |> unique_constraint(:user_name)
  end
end
