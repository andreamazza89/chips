defmodule Chips.Staker do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chips.Staker


  schema "stakers" do
    field :email, :string
    field :name, :string

    has_many :staking_contracts, Chips.StakingContract
    timestamps()
  end

  @doc false
  def changeset(%Staker{} = staker, attrs) do
    staker
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
  end
end
