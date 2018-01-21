defmodule Chips.StakingContract do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chips.StakingContract


  schema "staking_contracts" do
    field :half_percents_sold, :integer
    field :rate, :float

    belongs_to :staker, Chips.User
    belongs_to :tournament, Chips.Tournament
    belongs_to :player, Chips.User

    timestamps()
  end

  @doc false
  def changeset(%StakingContract{} = staking_contract, attrs) do
    staking_contract
    |> cast(attrs, [:rate, :half_percents_sold])
    |> validate_required([:rate, :half_percents_sold])
  end
end
