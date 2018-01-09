defmodule Chips.UserTournament do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chips.UserTournament


  schema "users_tournaments" do
    field :user_id, :id
    field :tournament_id, :id
  end

  def changeset(%UserTournament{} = user_tournament, attrs) do
    user_tournament
    |> cast(attrs, [])
    |> validate_required([])
  end
end
