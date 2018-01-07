defmodule Chips.AccessData do

  alias Chips.{Repo, Tournament}

  def list_tournaments do
    Repo.all(Tournament)
  end

  def create_tournament(args) do
    Repo.insert(%Tournament{city: args.city, name: args.name, starts: args.starts})
  end

end
