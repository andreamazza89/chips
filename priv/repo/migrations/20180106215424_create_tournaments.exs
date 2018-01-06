defmodule Chips.Repo.Migrations.CreateTournaments do
  use Ecto.Migration

  def change do
    create table(:tournaments) do
      add :name, :string
      add :city, :string
      add :starts, :naive_datetime

      timestamps()
    end

  end
end
