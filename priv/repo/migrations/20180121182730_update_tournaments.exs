defmodule Chips.Repo.Migrations.UpdateTournaments do
  use Ecto.Migration

  def change do
    alter table("tournaments") do
      remove :city

      add :fee_in_cents, :integer
      add :tournament_series_id, references(:tournament_serieses, on_delete: :nothing)
    end
  end
end
