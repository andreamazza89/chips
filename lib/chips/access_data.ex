defmodule Chips.AccessData do

  alias Chips.{Repo, StakingContract, Tournament, TournamentSeries, User}

  def list_tournament_serieses do
    Repo.all(TournamentSeries)
      |> Repo.preload(tournaments: [staking_contracts: [:staker]])
  end

  def list_tournaments do
    Repo.all(Tournament)
      |> Repo.preload(staking_contracts: [:staker])
  end

  def list_users do
    Repo.all(User)
  end

  def create_tournament_series(args) do
    Repo.insert(%TournamentSeries{city: args.city, name: args.name})

    list_tournament_serieses()
  end

  def create_tournament(args) do
    tournament_data = %{
      fee_in_cents: args.fee_in_cents,
      name: args.name,
      tournament_series_id: args.tournament_series_id,
    }

    Tournament.changeset(%Tournament{}, tournament_data)
    |> Repo.insert()

    list_tournament_serieses()
  end

  def create_user(args) do
    Repo.insert(%User{email: args.email, name: args.name})

    list_users()
  end

  def associate_user_to_tournament(args) do
    user = Repo.get(User, args.user_id)
      |> Repo.preload(:tournaments)
    tournament = Repo.get(Tournament, args.tournament_id)

    Ecto.Changeset.change(user)
      |> Ecto.Changeset.put_assoc(:tournaments, [tournament])
      |> Repo.update()
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

    list_tournament_serieses()
  end
end
