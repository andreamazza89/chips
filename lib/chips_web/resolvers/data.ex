defmodule ChipsWeb.Resolvers.Data do
  import Chips.AccessData
  import Chips.ProcessData

  def list_tournament_serieses(_parent, _args, _resolution) do
    {:ok, list_tournament_serieses() |> add_result_to_tournaments}
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

  def create_result(_parent, args, _resolution) do
    create_result(args)
    {:ok, list_tournament_serieses() |> add_result_to_tournaments}
  end

  def create_tournament_series(_parent, args, _resolution) do
    create_tournament_series(args)
    {:ok, list_tournament_serieses() |> add_result_to_tournaments}
  end

  def create_tournament(_parent, args, _resolution) do
    create_tournament(args)
    {:ok, list_tournament_serieses() |> add_result_to_tournaments}
  end

  def create_user(_parent, args, _resolution) do
    create_user(args)
    {:ok, list_users()}
  end

  def create_staking_contract(_parent, args, _resolution) do
    create_staking_contract(args)
    {:ok, list_tournament_serieses() |> add_result_to_tournaments}
  end
end
