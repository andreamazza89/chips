defmodule Chips.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:user_name, :string, null: false)
      add(:email, :string, null: false)
      add(:password, :string, null: false)
    end

    create(unique_index(:users, [:email]))
    create(unique_index(:users, [:user_name]))
  end
end
