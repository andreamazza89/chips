defmodule Chips.Repo.Migrations.CreateActionSales do
  use Ecto.Migration

  def change do
    create table(:action_sales) do
      add :units_on_sale, :integer
      add :markup, :float
      add :user_name, references(:users, type: :string, column: :user_name, on_delete: :nothing)
      add :tournament_id, references(:tournaments, on_delete: :nothing)

      timestamps()
    end

    create index(:action_sales, [:user_name])
  end
end
