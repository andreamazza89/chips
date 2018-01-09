defmodule Chips.Repo.Migrations.CreateUsersTournaments do
  use Ecto.Migration

  def change do
    create table(:users_tournaments) do
      add :user_id, references(:users, on_delete: :nothing)
      add :tournament_id, references(:tournaments, on_delete: :nothing)
    end

    create unique_index(:users_tournaments, [:user_id, :tournament_id])
  end
end
