defmodule Chips.Tournament do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chips.Tournament


  schema "tournaments" do
    field :fee_in_cents, :integer
    field :name, :string
    field :starts, :naive_datetime

    belongs_to :tournament_series, Chips.TournamentSeries
    has_many :staking_contracts, Chips.StakingContract

    timestamps()
  end

  @doc false
  def changeset(%Tournament{} = tournament, attrs) do
    tournament
    |> cast(attrs, [:name, :city, :starts])
    |> validate_required([:name, :city, :starts])
  end
end
