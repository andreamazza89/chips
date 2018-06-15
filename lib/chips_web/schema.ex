defmodule ChipsWeb.Schema do
  use Absinthe.Schema

  import_types(Absinthe.Type.Custom)
  import_types(ChipsWeb.Schema.Types)

  alias ChipsWeb.Resolvers

  query do
    field :tournament_serieses, list_of(:tournament_series) do
      resolve(&Resolvers.Data.list_tournament_serieses/3)
    end

    field :tournaments, list_of(:tournament) do
      resolve(&Resolvers.Data.list_tournaments/3)
    end

    field :users, list_of(:user) do
      resolve(&Resolvers.Data.list_users/3)
    end

    field :moneis_for_user, list_of(:moneis) do
      arg(:user_id, non_null(:integer))
      resolve(&Resolvers.Data.moneis_for_user/3)
    end
  end

  mutation do
    field :create_result, type: list_of(:tournament_series) do
      arg(:player_id, non_null(:string))
      arg(:prize, non_null(:integer))
      arg(:tournament_id, non_null(:string))

      resolve(&Resolvers.Data.create_result/3)
    end

    field :create_tournament_series, type: list_of(:tournament_series) do
      arg(:city, non_null(:string))
      arg(:name, non_null(:string))

      resolve(&Resolvers.Data.create_tournament_series/3)
    end

    field :create_tournament, type: list_of(:tournament_series) do
      arg(:fee_in_cents, non_null(:integer))
      arg(:name, non_null(:string))
      arg(:starts, :naive_datetime)
      arg(:tournament_series_id, non_null(:string))

      resolve(&Resolvers.Data.create_tournament/3)
    end

    # the user reference for the sale is extracted from the token
    field :create_action_sale, type: list_of(:tournament_series) do
      arg(:tournament_id, non_null(:string))
      arg(:units_on_sale, non_null(:integer))
      arg(:markup, non_null(:float))

      resolve(&Resolvers.Data.create_action_sale/3)
    end

    field :create_user, type: list_of(:user) do
      arg(:email, non_null(:string))
      arg(:name, non_null(:string))

      resolve(&Resolvers.Data.create_user/3)
    end

    field :create_staking_contract, type: list_of(:tournament_series) do
      arg(:percents_sold, non_null(:float))
      arg(:rate, non_null(:float))
      arg(:staker_id, non_null(:integer))
      arg(:tournament_id, non_null(:integer))
      arg(:player_id, non_null(:integer))

      resolve(&Resolvers.Data.create_staking_contract/3)
    end
  end
end
