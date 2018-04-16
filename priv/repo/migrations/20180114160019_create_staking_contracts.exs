defmodule Chips.Repo.Migrations.CreateStakingContracts do
  use Ecto.Migration

  def change do
    create table(:staking_contracts) do
      add :rate, :float, null: false
      add :percents_sold, :float, null: false
      add :staker_id, references(:users, on_delete: :nothing), null: false
      add :tournament_id, references(:tournaments, on_delete: :nothing), null: false
      add :player_id, references(:users, on_delete: :nothing), null: false
    end

    create index(:staking_contracts, [:tournament_id])
    create index(:staking_contracts, [:player_id])
    create index(:staking_contracts, [:staker_id])
  end
end
