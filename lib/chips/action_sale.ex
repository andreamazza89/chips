defmodule Chips.ActionSale do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chips.ActionSale


  schema "action_sales" do
    field :markup, :float
    field :units_on_sale, :integer
    field :user_name, :string

    belongs_to(:tournament, Chips.Tournament)

    timestamps()
  end

  def changeset(%ActionSale{} = action_sale, attrs) do
    action_sale
    |> cast(attrs, [:units_on_sale, :markup, :user_name, :tournament_id])
    |> validate_required([:units_on_sale, :markup, :user_name, :tournament_id])
  end
end
