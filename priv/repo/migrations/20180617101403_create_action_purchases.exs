defmodule Chips.Repo.Migrations.CreateActionPurchases do
  use Ecto.Migration

  def change do
    create table(:action_purchases) do
      add :units_bought, :integer
      add :user_name, references(:users, type: :string, column: :user_name, on_delete: :nothing)
      add :action_sale_id, references(:action_sales, on_delete: :nothing)

      timestamps()
    end

    create index(:action_purchases, [:user_name])
    create index(:action_purchases, [:action_sale_id])
  end
end
