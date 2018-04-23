defmodule Chips.AccessDataTest do
  use ExUnit.Case

  import Chips.{AccessData}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Chips.Repo)
  end

  test "a new user has no debit/credit" do
    {:ok, new_user} = create_user(%{name: "John", email: "asdf@bob.com"})

    assert moneis_for_user(new_user.id) == []
  end

  test "stakers Gigi and Viola back John and Mario in tournaments and owe them money for it" do
    {:ok, player_john} = create_user(%{name: "John", email: "asdf@bob.com"})
    {:ok, player_mario} = create_user(%{name: "Mario", email: "mario@rab.com"})
    {:ok, staker_gigi} = create_user(%{name: "Gigi", email: "lol@cats.com"})
    {:ok, staker_viola} = create_user(%{name: "Viola", email: "bla@blerg.com"})

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
    {:ok, player_silvia} = create_user(%{name: "Silvia", email: "silvia@rab.com"})
    {:ok, staker_gino} = create_user(%{name: "Gino", email: "gino@cats.com"})

    {:ok, tournament} = create_tournament(%{name: "Best tourney eva", fee_in_cents: 100})

    {:ok, _staking_contract_gino_backs_silvia} =
      create_staking_contract(%{
        staker_id: staker_gino.id,
        player_id: player_silvia.id,
        tournament_id: tournament.id,
        percents_sold: 3.0,
        rate: 2
      })

    {:ok, _tournament_result} = create_result(%{
        tournament_id: tournament.id,
        player_id: player_silvia.id,
        prize: 1000
    })

    moneis_for_silvia = moneis_for_user(player_silvia.id)
    assert moneis_for_silvia == [{staker_gino, -24}]
  end
end
