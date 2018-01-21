defmodule Chips.Repo.Migrations.UpdateStakingContract do
  use Ecto.Migration

  def change do
    alter table("staking_contracts") do
      remove :user_id
      add :player_id, references(:users, on_delete: :nothing)

      remove :staker_id
      add :staker_id, references(:users, on_delete: :nothing)
    end
  end
end
