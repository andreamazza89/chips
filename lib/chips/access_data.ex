defmodule Chips.AccessData do

  alias Chips.{Repo, StakingContract, Tournament, TournamentSeries, User}

  def list_tournament_serieses do
    Repo.all(TournamentSeries)
    |> Repo.preload(tournaments: [:results, staking_contracts: [:staker]])
  end

  def list_tournaments do
    Repo.all(Tournament)
    |> Repo.preload(staking_contracts: [:staker])
  end

  def list_users do
    Repo.all(User)
  end

  def create_tournament_series(args) do
    TournamentSeries.changeset(%TournamentSeries{}, args)
    |> Repo.insert
  end

  def create_tournament(args) do
    Tournament.changeset(%Tournament{}, args)
    |> Repo.insert()
  end

  def create_user(args) do
    User.changeset(%User{}, args)
    |> Repo.insert()
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
  end
end
