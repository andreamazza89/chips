defmodule Chips.Repo.Migrations.CreateResults do
  use Ecto.Migration

  def change do
    create table(:results) do
      add :player_id, references(:users, on_delete: :nothing)
      add :prize, :integer
      add :tournament_id, references(:tournaments, on_delete: :nothing)
    end

    create index(:results, [:tournament_id])
    create index(:results, [:player_id])
  end
end
