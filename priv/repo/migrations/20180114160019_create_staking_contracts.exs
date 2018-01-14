defmodule Chips.Repo.Migrations.CreateStakingContracts do
  use Ecto.Migration

  def change do
    create table(:staking_contracts) do
      add :rate, :float
      add :half_percents_sold, :integer
      add :tournament_id, references(:tournaments, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      add :staker_id, references(:stakers, on_delete: :nothing)

      timestamps()
    end

    create index(:staking_contracts, [:tournament_id])
    create index(:staking_contracts, [:user_id])
    create index(:staking_contracts, [:staker_id])
  end
end
