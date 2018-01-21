defmodule Chips.Repo.Migrations.AddTournamentSeriesTable do
  use Ecto.Migration

  def change do
    create table(:tournament_serieses) do
      add :city, :string
      add :name, :string
    end
  end
end
