defmodule Chips.AccessData do
  import Ecto.Query
  alias Chips.{ActionSale, Repo, Result, StakingContract, Tournament, TournamentSeries, User}

  # read
  ######
  def list_tournament_serieses do
    Repo.all(TournamentSeries)
    |> Repo.preload(tournaments: [:results, :action_sales, staking_contracts: [:staker]])
  end

  def list_tournaments do
    Repo.all(Tournament)
    |> Repo.preload(staking_contracts: [:staker])
  end

  def list_users do
    Repo.all(User)
  end

  def moneis_for_user(user_id) do
    Repo.all(moneis_query(user_id))
    |> Enum.group_by(fn {staker_id, _, _, _, _} -> staker_id end, &calculate_debit_and_credit/1)
    |> Enum.map(fn {staker_id, moneis} ->
      {Repo.get!(User, staker_id), Enum.sum(moneis)}
    end)
  end

  defp moneis_query(user_id) do
    from(
      contract in "staking_contracts",
      join: tourney in "tournaments",
      on: contract.tournament_id == tourney.id,
      left_join: result in "results",
      on: contract.tournament_id == result.tournament_id,
      where: contract.player_id == ^user_id,
      select: {
        contract.staker_id,
        tourney.fee_in_cents,
        contract.percents_sold,
        contract.rate,
        result.prize
      }
    )
  end

  defp calculate_debit_and_credit({_staker_id, fee, percents_sold, rate, nil}) do
    staker_owes_to_player = fee / 100 * percents_sold * rate
    staker_owes_to_player
  end

  defp calculate_debit_and_credit({_staker_id, fee, percents_sold, rate, prize}) do
    staker_owes_to_player = fee / 100 * percents_sold * rate
    player_owes_to_staker = prize / 100 * percents_sold
    staker_owes_to_player - player_owes_to_staker
  end

  # write
  #######

  def create_action_sale(args, user) do
    ActionSale.changeset(%Chips.ActionSale{}, Map.put(args, :user_name, user.user_name))
    |> Chips.Repo.insert()
  end

  def create_result(args) do
    tournament = Repo.get(Tournament, args.tournament_id)
    player = Repo.get(User, args.player_id)

    Result.changeset(%Result{}, args)
    |> Ecto.Changeset.put_assoc(:tournament, tournament)
    |> Ecto.Changeset.put_assoc(:player, player)
    |> Repo.insert()
  end

  def create_tournament_series(args) do
    TournamentSeries.changeset(%TournamentSeries{}, args)
    |> Repo.insert()
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
    |> Repo.insert()
  end
end
