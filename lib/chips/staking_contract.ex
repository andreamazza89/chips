defmodule Chips.StakingContract do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chips.StakingContract


  schema "staking_contracts" do
    field :percents_sold, :float
    field :rate, :float

    belongs_to :staker, Chips.User
    belongs_to :tournament, Chips.Tournament
    belongs_to :player, Chips.User
  end

  @doc false
  def changeset(%StakingContract{} = staking_contract, attrs) do
    staking_contract
    |> cast(attrs, [:rate, :percents_sold])
    |> validate_required([:rate, :percents_sold])
  end
end
