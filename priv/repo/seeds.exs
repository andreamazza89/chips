# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Chips.Repo.insert!(%Chips.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


player = %Chips.User{ email: "sauro@gomme.com", name: "sauro" }
tournament = %Chips.Tournament{
  city: "vegas",
  name: "crazy cooler",
  starts: ~N[2017-09-04 09:00:00]
}
player_tournament_relation = %Chips.UserTournament{ user_id: 1, tournament_id: 1 }
staker = %Chips.Staker{ email: "paolo@pirro.com", name: "pirro" }
staking_contract = %Chips.StakingContract{
  half_percents_sold: 2,
  rate: 1.35,
  tournament_id: 1,
  user_id: 1,
  staker_id: 1
}

Chips.Repo.insert!(player)
Chips.Repo.insert!(tournament)
Chips.Repo.insert!(player_tournament_relation)
Chips.Repo.insert!(staker)
Chips.Repo.insert!(staking_contract)
