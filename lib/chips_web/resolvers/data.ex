defmodule ChipsWeb.Resolvers.Data do

  def list_tournaments(_parent, _args, _resolution) do
    {:ok, Chips.AccessData.list_tournaments()}
  end

  def create_tournament(_parent, args, _resolution) do
    Chips.AccessData.create_tournament(args)
  end

end
