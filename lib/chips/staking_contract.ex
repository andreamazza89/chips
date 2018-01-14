defmodule Chips.StakingContract do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chips.StakingContract


  schema "staking_contracts" do
    field :half_percents_sold, :integer
    field :rate, :float
    field :tournament_id, :id
    field :user_id, :id

    belongs_to :staker, Chips.Staker

    timestamps()
  end

  @doc false
  def changeset(%StakingContract{} = staking_contract, attrs) do
    staking_contract
    |> cast(attrs, [:rate, :half_percents_sold])
    |> validate_required([:rate, :half_percents_sold])
  end
end
