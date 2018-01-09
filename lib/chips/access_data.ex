defmodule Chips.AccessData do

  alias Chips.{Repo, Tournament, User}

  def list_tournaments do
    Repo.all(Tournament)
      |> Repo.preload(:users)
  end

  def list_users do
    Repo.all(User)
      |> Repo.preload(:tournaments)
  end

  def create_tournament(args) do
    Repo.insert(%Tournament{city: args.city, name: args.name, starts: args.starts})
  end

  def create_user(args) do
    Repo.insert(%User{email: args.email, name: args.name})
  end

  def associate_user_to_tournament(args) do
    user = Repo.get(User, args.user_id)
      |> Repo.preload(:tournaments)
    tournament = Repo.get(Tournament, args.tournament_id)
    user_with_tournament = Ecto.Changeset.change(user)
      |> Ecto.Changeset.put_assoc(:tournaments, [tournament])
      |> Repo.update
  end
end
