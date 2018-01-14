defmodule Chips.Repo.Migrations.CreateStakers do
  use Ecto.Migration

  def change do
    create table(:stakers) do
      add :name, :string
      add :email, :string

      timestamps()
    end

  end
end
