defmodule Chips.Result do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chips.Result


  schema "results" do
    field :prize, :integer

    belongs_to :tournament, Chips.Tournament
    belongs_to :player, Chips.User
  end

  @doc false
  def changeset(%Result{} = result, attrs) do
    result
    |> cast(attrs, [:prize])
    |> validate_required([:prize])
  end
end
