defmodule ChipsWeb.Schema.Types do
  use Absinthe.Schema.Notation

  object :moneis do
    field :user, :user
    field :balance, :float
  end

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

    field :action_sales, list_of(:action_sale)
    field :staking_contracts, list_of(:staking_contract)
    field :users, list_of(:user)
  end

  object :action_sale do
    field :id, :id
    field :markup, :float
    field :result, :integer
    field :user_name, :string
    field :units_on_sale, :integer

    field :action_purchases, list_of(:action_purchase)
  end

  object :action_purchase do
    field :user_name, :string
    field :units_bought, :integer
  end

  object :user do
    field :id, :id
    field :name, :string
    field :email, :string

    field :moneis, list_of(:moneis)
    field :tournaments, list_of(:tournament)
  end

  object :user_to_amount do
    field :user, :user
    field :amount, :integer
  end

end
