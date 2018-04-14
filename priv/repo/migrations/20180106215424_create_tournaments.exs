defmodule Chips.Repo.Migrations.CreateTournaments do
  use Ecto.Migration

  def change do
    create table(:tournaments) do
      add :fee_in_cents, :integer
      add :name, :string
      add :starts, :naive_datetime
      add :tournament_series_id, references(:tournament_serieses, on_delete: :nothing)
    end

  end
end
