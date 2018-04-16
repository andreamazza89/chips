defmodule ChipsWeb.Schema.Types do
  use Absinthe.Schema.Notation

  object :staking_contract do
    field :id, :id
    field :percents_sold, :float
    field :rate, :float

    field :staker, :user
    field :tournament, :tournament
    field :player, :user
  end

  object :tournament_series do
    field :city, :string
    field :id, :id
    field :name, :string

    field :tournaments, list_of(:tournament)
  end

  object :tournament do
    field :id, :id
    field :city, :string
    field :fee_in_cents, :integer
    field :name, :string
    field :result, :integer
    field :starts, :naive_datetime

    field :staking_contracts, list_of(:staking_contract)
    field :users, list_of(:user)
  end

  object :user do
    field :id, :id
    field :name, :string
    field :email, :string

    field :tournaments, list_of(:tournament)
  end

end
