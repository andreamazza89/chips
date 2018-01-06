defmodule Chips.Tournament do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chips.Tournament


  schema "tournaments" do
    field :city, :string
    field :name, :string
    field :starts, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(%Tournament{} = tournament, attrs) do
    tournament
    |> cast(attrs, [:name, :city, :starts])
    |> validate_required([:name, :city, :starts])
  end
end
