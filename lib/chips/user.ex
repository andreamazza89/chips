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
  def changeset(%User{} = user \\ %User{}, attrs) do
    user
    |> cast(attrs, [:email, :user_name, :password])
    |> validate_required([:email, :user_name, :password])
    |> unique_constraint(:email)
    |> unique_constraint(:user_name)
    |> hash_password
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password, Pbkdf2.hash_pwd_salt(pass))

      _ ->
        changeset
    end
  end
end
