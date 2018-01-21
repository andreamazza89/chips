defmodule Chips.Repo.Migrations.RemoveStakers do
  use Ecto.Migration

  def change do
    drop table("stakers")
  end
end
