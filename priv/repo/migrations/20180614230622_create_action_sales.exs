defmodule Chips.Repo.Migrations.CreateActionSales do
  use Ecto.Migration

  def change do
    create table(:action_sales) do
      add :markup, :float
      add :result, :integer
      add :tournament_id, references(:tournaments, on_delete: :nothing)
      add :user_name, references(:users, type: :string, column: :user_name, on_delete: :nothing)
      add :units_on_sale, :integer

      timestamps()
    end

    create index(:action_sales, [:user_name])
    create index(:action_sales, [:tournament_id])
  end
end
