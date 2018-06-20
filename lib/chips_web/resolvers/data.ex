defmodule ChipsWeb.Resolvers.Data do
  import Chips.AccessData

  def list_tournament_serieses(_parent, _args, _resolution) do
    {:ok, list_tournament_serieses()}
  end

  def list_tournaments(_parent, _args, _resolution) do
    {:ok, list_tournaments()}
  end

  def list_users(_parent, _args, _resolution) do
    {:ok, list_users()}
  end

  def moneis_for_user(_parent, args, _resolution) do
    {:ok,
     moneis_for_user(args.user_id)
     |> Enum.map(fn {user, balance} -> %{user: user, balance: balance} end)}
  end

  def create_action_sale(_parent, args, %{context: %{user: user}}) do
    create_action_sale(args, user)
    {:ok, list_tournament_serieses()}
  end

  def create_action_sale_result(_parent, args, %{context: %{user: user}}) do
    create_action_sale_result(args, user)
    {:ok, list_tournament_serieses()}
  end

  def create_action_purchase(_parent, args, %{context: %{user: user}}) do
    create_action_purchase(args, user)
    {:ok, list_tournament_serieses()}
  end

  def create_tournament_series(_parent, args, _resolution) do
    create_tournament_series(args)
    {:ok, list_tournament_serieses()}
  end

  def create_tournament(_parent, args, _resolution) do
    create_tournament(args)
    {:ok, list_tournament_serieses()}
  end

  def create_user(_parent, args, _resolution) do
    create_user(args)
    {:ok, list_users()}
  end

  def create_staking_contract(_parent, args, _resolution) do
    create_staking_contract(args)
    {:ok, list_tournament_serieses()}
  end
end
