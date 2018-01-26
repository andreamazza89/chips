defmodule Chips.Repo.Migrations.RemoveUsersTournaments do
  use Ecto.Migration

  def change do
    drop table("users_tournaments")
  end
end
