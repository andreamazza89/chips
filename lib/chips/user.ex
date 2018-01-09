defmodule Chips.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chips.User


  schema "users" do
    field :email, :string
    field :name, :string

    many_to_many :tournaments, Chips.Tournament, join_through: "users_tournaments"

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
  end
end
