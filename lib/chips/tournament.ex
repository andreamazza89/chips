defmodule Chips.Tournament do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chips.Tournament


  schema "tournaments" do
    field :city, :string
    field :name, :string
    field :starts, :naive_datetime

    has_many :staking_contracts, Chips.StakingContract
    many_to_many :users, Chips.User, join_through: "users_tournaments"

    timestamps()
  end

  @doc false
  def changeset(%Tournament{} = tournament, attrs) do
    tournament
    |> cast(attrs, [:name, :city, :starts])
    |> validate_required([:name, :city, :starts])
  end
end
