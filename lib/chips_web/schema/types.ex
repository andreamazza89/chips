defmodule ChipsWeb.Schema.Types do
  use Absinthe.Schema.Notation

  object :staker do
    field :id, :id
    field :email, :string
    field :name, :string

    field :staking_contracts, list_of(:staking_contract)
  end

  object :staking_contract do
    field :id, :id
    field :half_percents_sold, :id
    field :rate, :float

    field :staker, :staker
    field :tournament, :tournament
    field :user, :user
  end

  object :tournament do
    field :id, :id
    field :city, :string
    field :name, :string
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
