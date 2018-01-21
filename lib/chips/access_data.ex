defmodule Chips.AccessData do

  alias Chips.{Repo, StakingContract, Tournament, User}

  def list_tournaments do
    Repo.all(Tournament)
      |> Repo.preload(:users)
      |> Repo.preload(staking_contracts: [:staker, :player])
  end

  def list_users do
    Repo.all(User)
  end

  def create_tournament(args) do
    Repo.insert(%Tournament{city: args.city, name: args.name, starts: args.starts})
  end

  def create_user(args) do
    Repo.insert(%User{email: args.email, name: args.name})

    list_users
  end

  def associate_user_to_tournament(args) do
    user = Repo.get(User, args.user_id)
      |> Repo.preload(:tournaments)
    tournament = Repo.get(Tournament, args.tournament_id)
    user_with_tournament = Ecto.Changeset.change(user)
      |> Ecto.Changeset.put_assoc(:tournaments, [tournament])
      |> Repo.update
  end

  def create_staking_contract(args) do
    staker = Repo.get(User, args.staker_id)
    tournament = Repo.get(Tournament, args.tournament_id)
    player = Repo.get(User, args.player_id)

    %StakingContract{}
    |> StakingContract.changeset(args)
    |> Ecto.Changeset.put_assoc(:staker, staker)
    |> Ecto.Changeset.put_assoc(:tournament, tournament)
    |> Ecto.Changeset.put_assoc(:player, player)
    |> Repo.insert

    list_tournaments
  end
end
