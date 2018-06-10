defmodule Chips.AccessDataTest do
  use ExUnit.Case

  import Chips.{AccessData}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Chips.Repo)
  end

  test "a new user has no debit/credit" do
    new_user = create_user_helper(%{user_name: "John"})

    assert moneis_for_user(new_user.id) == []
  end

  test "stakers Gigi and Viola back John and Mario in tournaments and owe them money for it" do
    player_john  = create_user_helper(%{user_name: "John"})
    player_mario = create_user_helper(%{user_name: "Mario"})
    staker_gigi  = create_user_helper(%{user_name: "Gigi"})
    staker_viola = create_user_helper(%{user_name: "Viola"})

    {:ok, tournament_one} = create_tournament(%{name: "Best tourney eva", fee_in_cents: 200})
    {:ok, tournament_two} = create_tournament(%{name: "High roller", fee_in_cents: 11_111_100})

    {:ok, _staking_contract_gigi_backs_john_tournament_one} =
      create_staking_contract(%{
        staker_id: staker_gigi.id,
        player_id: player_john.id,
        tournament_id: tournament_one.id,
        percents_sold: 2.0,
        rate: 1.3
      })

    {:ok, _staking_contract_gigi_backs_mario_tournament_one} =
      create_staking_contract(%{
        staker_id: staker_gigi.id,
        player_id: player_mario.id,
        tournament_id: tournament_one.id,
        percents_sold: 3.5,
        rate: 1.5
      })

    {:ok, _staking_contract_viola_backs_mario_tournament_one} =
      create_staking_contract(%{
        staker_id: staker_viola.id,
        player_id: player_mario.id,
        tournament_id: tournament_one.id,
        percents_sold: 1.2,
        rate: 1.3
      })

    {:ok, _staking_contract_viola_backs_mario_tournament_two} =
      create_staking_contract(%{
        staker_id: staker_viola.id,
        player_id: player_mario.id,
        tournament_id: tournament_two.id,
        percents_sold: 3,
        rate: 1.25
      })

    moneis_for_john = moneis_for_user(player_john.id)
    assert moneis_for_john == [{staker_gigi, 5.2}]

    moneis_for_mario = moneis_for_user(player_mario.id)
    assert moneis_for_mario == [{staker_gigi, 10.5}, {staker_viola, 416_669.37}]
  end

  test "Staker Gino backs Silvia, who wins a prize, so Silvia owes Gino " do
    player_silvia = create_user_helper(%{user_name: "Silvia"})
    staker_gino   = create_user_helper(%{user_name: "Gino"})

    {:ok, tournament} = create_tournament(%{name: "Best tourney eva", fee_in_cents: 100})

    {:ok, _staking_contract_gino_backs_silvia} =
      create_staking_contract(%{
        staker_id: staker_gino.id,
        player_id: player_silvia.id,
        tournament_id: tournament.id,
        percents_sold: 3.0,
        rate: 2
      })

    {:ok, _tournament_result} =
      create_result(%{
        tournament_id: tournament.id,
        player_id: player_silvia.id,
        prize: 1000
      })

    moneis_for_silvia = moneis_for_user(player_silvia.id)
    assert moneis_for_silvia == [{staker_gino, -24}]
  end

  defp create_user_helper(%{user_name: user_name}) do
    {:ok, user} = create_user(%{user_name: user_name, email: user_name <> "@a.b", password: "monkey"})
    user
  end
end
