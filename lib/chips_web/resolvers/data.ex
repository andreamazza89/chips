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
