defmodule ChipsWeb.Resolvers.Data do

  def list_tournaments(_parent, _args, _resolution) do
    {:ok, Chips.AccessData.list_tournaments()}
  end

  def list_users(_parent, _args, _resolution) do
    {:ok, Chips.AccessData.list_users()}
  end

  def create_tournament(_parent, args, _resolution) do
    Chips.AccessData.create_tournament(args)
  end

  def create_user(_parent, args, _resolution) do
    Chips.AccessData.create_user(args)
  end

  def associate_user_to_tournament(_parent, args, _resolution) do
    Chips.AccessData.associate_user_to_tournament(args)
  end

end
