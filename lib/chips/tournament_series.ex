defmodule Chips.TournamentSeries do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chips.TournamentSeries


  schema "tournament_serieses" do
    field :city, :string
    field :name, :string

    has_many :tournaments, Chips.Tournament
  end

  @doc false
  def changeset(%TournamentSeries{} = series, attrs) do
    series
    |> cast(attrs, [:name, :city])
    |> validate_required([:name, :city])
  end
end
